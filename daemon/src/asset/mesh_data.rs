/// This module handles generating mesh data for cooked asset geometry.

use std::time::Instant;

use glam::Vec3;
use hapi_rs::{attribute::NumericAttr, node::Geometry, session::AttributeOwner};
use serde::Serialize;
use thiserror::Error;

#[derive(Debug, Error, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum MeshDataError {
    #[error("Failed to get geometry partition info")]
    GetPartitionInfo,
    #[error("Geometry partition has no partition")]
    NoPartition,

    #[error("Failed to get position attribute")]
    GetPositionAttribute,
    #[error("Failed to get face counts")]
    GetFaceCounts,
    #[error("Failed to get vertex list")]
    GetVertexList,

    #[error("Failed to get uv attribute")]
    GetUVAttribute,
    #[error("Failed to convert uv attribute")]
    ConvertUVAttribute,

    #[error("Failed to get vertex normal attribute")]
    GetVertexNormalAttribute,
    #[error("Failed to get point normal attribute")]
    GetPointNormalAttribute,
    #[error("Failed to convert normal attribute")]
    ConvertNormalAttribute,

    #[error("Failed to get vertex color attribute")]
    GetVertexColorAttribute,
    #[error("Failed to get point color attribute")]
    GetPointColorAttribute,
    #[error("Failed to convert color attribute")]
    ConvertColorAttribute,
}

type Result<T> = std::result::Result<T, MeshDataError>;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Stats {
    hapi_time: f64,
    vertex_processing_time: f64,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct MeshData {
    num_vertices: i32,
    vertex_array: Vec<Vec3>,

    positions: Vec<f32>,
    normals: Option<Vec<f32>>,
    colors: Option<Vec<f32>>,
    uvs: Option<Vec<f32>>,

    stats: Stats,
}

impl MeshData {
    pub fn from_houdini_geo(geo: &Geometry) -> Result<Self> {
        let start = Instant::now();

        // Note: This implementation only supports one partition per geo. This
        //  will need to be revisited later, but I'm unsure how partitions
        //  work and when multiple partitions would be used.
        let partition = geo
            .part_info(0)
            .map_err(|_| MeshDataError::GetPartitionInfo)?
            .ok_or(MeshDataError::NoPartition)?;
        let partition_id = partition.part_id();

        // Step 1. Extract mesh data from hapi API

        let positions = geo
            .get_position_attribute(partition_id)
            .map_err(|_| MeshDataError::GetPositionAttribute)?
            .get(partition_id)
            .map_err(|_| MeshDataError::GetPositionAttribute)?;
        let face_counts = geo
            .get_face_counts(Some(&partition))
            .map_err(|_| MeshDataError::GetFaceCounts)?;
        let vertex_list = geo
            .vertex_list(Some(&partition))
            .map_err(|_| MeshDataError::GetVertexList)?;

        let uv_attr = geo
            .get_attribute(partition_id, AttributeOwner::Vertex, "uv")
            .map_err(|_| MeshDataError::GetUVAttribute)?;
        let uvs = match uv_attr {
            Some(uv_attr) => Some(
                uv_attr
                    .downcast::<NumericAttr<f32>>()
                    .expect("uv is NumericAttribute")
                    .get(partition_id)
                    .map_err(|_| MeshDataError::ConvertUVAttribute)?,
            ),
            None => None,
        };

        let (normals, is_point_normal) = {
            let mut is_point_normal = false;
            let mut vertex_attr = geo
                .get_attribute(partition_id, AttributeOwner::Vertex, "N")
                .map_err(|_| MeshDataError::GetVertexNormalAttribute)?;

            if vertex_attr.is_none() {
                is_point_normal = true;
                vertex_attr = geo
                    .get_attribute(partition_id, AttributeOwner::Point, "N")
                    .map_err(|_| MeshDataError::GetPointNormalAttribute)?;
            }

            let normals = match vertex_attr {
                Some(n_attr) => Some(
                    n_attr
                        .downcast::<NumericAttr<f32>>()
                        .expect("N is NumericAttribute")
                        .get(partition_id)
                        .map_err(|_| MeshDataError::ConvertNormalAttribute)?,
                ),
                None => None,
            };

            (normals, is_point_normal)
        };

        let (colors, is_point_color) = {
            let mut is_point_color = false;
            let mut clr_attr = geo
                .get_attribute(partition_id, AttributeOwner::Vertex, "Cd")
                .map_err(|_| MeshDataError::GetVertexColorAttribute)?;

            if clr_attr.is_none() {
                is_point_color = true;
                clr_attr = geo
                    .get_attribute(partition_id, AttributeOwner::Point, "Cd")
                    .map_err(|_| MeshDataError::GetPointColorAttribute)?;
            }

            let colors = match clr_attr {
                Some(cd_attr) => Some(
                    cd_attr
                        .downcast::<NumericAttr<f32>>()
                        .expect("Cd is NumericAttribute")
                        .get(partition_id)
                        .map_err(|_| MeshDataError::ConvertColorAttribute)?,
                ),
                None => None,
            };

            (colors, is_point_color)
        };

        let hapi_time = Instant::now().duration_since(start);
        let start = Instant::now();

        // Step 2. Process vertices

        let mut num_vertices = (face_counts.iter().sum::<i32>() / 2) * 3;
        num_vertices *= 3; // Position
        if normals.is_some() {
            num_vertices *= 3;
        }
        if colors.is_some() {
            num_vertices *= 3;
        }
        if uvs.is_some() {
            num_vertices *= 3;
        }

        // pig head:
        //  bound checked:         200 us
        //  unsafe unchecked Rust: 180 us

        let mut vertex_array = Vec::with_capacity(num_vertices as usize);
        let mut offset = 0;

        for vertex_count_per_face in face_counts {
            let num_triangles = (vertex_count_per_face - 2) as usize;
            for i in 0..num_triangles {
                let off0 = offset + 0;
                let off1 = offset + i + 1;
                let off2 = offset + i + 2;

                let point_0_index = unsafe { *vertex_list.get_unchecked(off0) as usize };
                let point_1_index = unsafe { *vertex_list.get_unchecked(off1) as usize };
                let point_2_index = unsafe { *vertex_list.get_unchecked(off2) as usize };

                let pos_a = unsafe {
                    Vec3::new(
                        *positions.get_unchecked(point_0_index * 3 + 0),
                        *positions.get_unchecked(point_0_index * 3 + 1),
                        *positions.get_unchecked(point_0_index * 3 + 2),
                    )
                };
                let pos_b = unsafe {
                    Vec3::new(
                        *positions.get_unchecked(point_1_index * 3 + 0),
                        *positions.get_unchecked(point_1_index * 3 + 1),
                        *positions.get_unchecked(point_1_index * 3 + 2),
                    )
                };
                let pos_c = unsafe {
                    Vec3::new(
                        *positions.get_unchecked(point_2_index * 3 + 0),
                        *positions.get_unchecked(point_2_index * 3 + 1),
                        *positions.get_unchecked(point_2_index * 3 + 2),
                    )
                };

                // VTX 1
                vertex_array.push(pos_a);

                // Normals
                if let Some(ref normals) = normals {
                    let idx = if is_point_normal { point_0_index } else { off0 };
                    vertex_array.push(unsafe {
                        Vec3::new(
                            *normals.get_unchecked(idx * 3 + 0),
                            *normals.get_unchecked(idx * 3 + 1),
                            *normals.get_unchecked(idx * 3 + 2),
                        )
                    });
                }

                // Color
                if let Some(ref colors) = colors {
                    let idx = if is_point_color { point_0_index } else { off0 };
                    vertex_array.push(unsafe {
                        Vec3::new(
                            *colors.get_unchecked(idx * 3 + 0),
                            *colors.get_unchecked(idx * 3 + 1),
                            *colors.get_unchecked(idx * 3 + 2),
                        )
                    });
                }

                // UV
                if let Some(ref uvs) = uvs {
                    vertex_array.push(Vec3::new(uvs[off0 * 3 + 0], 1.0 - uvs[off0 * 3 + 1], 0.0));
                }

                // VTX 2
                vertex_array.push(pos_b);

                // Normal
                if let Some(ref normals) = normals {
                    let idx = if is_point_normal { point_1_index } else { off1 };
                    vertex_array.push(unsafe {
                        Vec3::new(
                            *normals.get_unchecked(idx * 3 + 0),
                            *normals.get_unchecked(idx * 3 + 1),
                            *normals.get_unchecked(idx * 3 + 2),
                        )
                    });
                }

                // Color
                if let Some(ref colors) = colors {
                    let idx = if is_point_color { point_1_index } else { off1 };
                    vertex_array.push(unsafe {
                        Vec3::new(
                            *colors.get_unchecked(idx * 3 + 0),
                            *colors.get_unchecked(idx * 3 + 1),
                            *colors.get_unchecked(idx * 3 + 2),
                        )
                    });
                }

                // UV
                if let Some(ref uvs) = uvs {
                    vertex_array.push(Vec3::new(uvs[off1 * 3 + 0], 1.0 - uvs[off1 * 3 + 1], 0.0));
                }

                // VTX 3
                vertex_array.push(pos_c);

                // Normal
                if let Some(ref normals) = normals {
                    let idx = if is_point_normal { point_2_index } else { off2 };
                    vertex_array.push(unsafe {
                        Vec3::new(
                            *normals.get_unchecked(idx * 3 + 0),
                            *normals.get_unchecked(idx * 3 + 1),
                            *normals.get_unchecked(idx * 3 + 2),
                        )
                    });
                }

                // Color
                if let Some(ref colors) = colors {
                    let idx = if is_point_color { point_2_index } else { off2 };
                    vertex_array.push(unsafe {
                        Vec3::new(
                            *colors.get_unchecked(idx * 3 + 0),
                            *colors.get_unchecked(idx * 3 + 1),
                            *colors.get_unchecked(idx * 3 + 2),
                        )
                    });
                }

                // UV
                if let Some(ref uvs) = uvs {
                    vertex_array.push(Vec3::new(uvs[off2 * 3 + 0], 1.0 - uvs[off2 * 3 + 1], 0.0));
                }
            }

            offset += vertex_count_per_face as usize;
        }

        let vertex_processing_time = Instant::now().duration_since(start);

        Ok(Self {
            num_vertices,
            vertex_array,

            positions,
            normals,
            colors,
            uvs,

            stats: Stats {
                hapi_time: hapi_time.as_secs_f64(),
                vertex_processing_time: vertex_processing_time.as_secs_f64(),
            },
        })
    }
}
