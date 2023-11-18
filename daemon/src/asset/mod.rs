mod asset_param;
mod mesh_data;

use std::{path::Path, time::Instant};

use hapi_rs::{
    node::{AssetInfo, Geometry},
    session::{CookOptions, HoudiniNode, Session},
};
use serde::Serialize;
use thiserror::Error;

pub use self::{asset_param::SerializableParameter, mesh_data::MeshData};

#[derive(Debug, Error, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum AssetError {
    #[error("Failed to load asset file")]
    LoadAssetFile,
    #[error("Failed to create first asset from asset library")]
    CreateAsset,
    #[error("Failed to get geometry for asset")]
    GetGeometry,
    #[error("Failed to get asset info")]
    GetAssetInfo,
    #[error("Asset has no geometry")]
    NoGeometry,

    #[error("Failed to get asset parameters")]
    GetParameters,
    #[error("Failed to serialize asset parameter")]
    SerializeParameter(asset_param::AssetParamError),

    #[error("Failed to cook asset")]
    CookAsset,
    #[error("Failed to get mesh data from asset geometry")]
    GetMeshData(mesh_data::MeshDataError),
}

type Result<T> = std::result::Result<T, AssetError>;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SerializableAssetInfo {
    label: String,
    name: String,
    file_path: String,
    version: String,
    help_text: String,
    help_url: String,
}

impl From<AssetInfo> for SerializableAssetInfo {
    fn from(asset_info: AssetInfo) -> Self {
        Self {
            label: asset_info.label().unwrap(),
            name: asset_info.name().unwrap(),
            file_path: asset_info.file_path().unwrap(),
            version: asset_info.version().unwrap(),
            help_text: asset_info.help_text().unwrap(),
            help_url: asset_info.help_url().unwrap(),
        }
    }
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CookStats {
    cook_time: f64,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CookResult {
    mesh_data: MeshData,
    stats: CookStats,
}

/// Wraps a low-level Houdini Digital Asset (HDA) and provides a higher-level
/// interface for interacting with it.
pub struct Asset {
    internal_asset: HoudiniNode,
    geometry: Geometry,
}

impl Asset {
    /// Load an asset from a file. This loads the asset into memory, but does
    /// not cook it or create any meshes.
    pub fn new_from_path<P: AsRef<Path>>(session: &Session, path: &P) -> Result<Self> {
        let asset_library = session
            .load_asset_file(path)
            .map_err(|_| AssetError::LoadAssetFile)?;

        // Note: This implementation only supports one asset per HDA. May need
        //  revisiting later. Are there any use-cases for multiple assets per
        //  HDA?
        let asset = asset_library
            .try_create_first()
            .map_err(|_| AssetError::CreateAsset)?;

        // Note: This implementation only supports assets with geometry.
        let geometry = asset
            .geometry()
            .map_err(|_| AssetError::GetGeometry)?
            .ok_or(AssetError::NoGeometry)?;

        Ok(Self {
            internal_asset: asset,
            geometry,
        })
    }

    /// Returns a list of the asset's parameters and their current values.
    /// The result is serialisable and suitable to return to the client.
    pub fn get_asset_parameters(&self) -> Result<Vec<SerializableParameter>> {
        let internal_params = self
            .internal_asset
            .parameters()
            .map_err(|_| AssetError::GetParameters)?;

        let mut serializable_params = Vec::new();
        for param in internal_params {
            let serializable_param =
                SerializableParameter::try_from(param).map_err(AssetError::SerializeParameter)?;

            serializable_params.push(serializable_param);
        }

        Ok(serializable_params)
    }

    /// Returns simple information about the HDA.
    pub fn get_asset_info(&self) -> Result<SerializableAssetInfo> {
        let asset_info = self
            .internal_asset
            .asset_info()
            .map_err(|_| AssetError::GetAssetInfo)?;

        Ok(asset_info.into())
    }

    /// Cook the asset and return the resulting mesh data. This can be used to
    /// either create an `EditableMesh` on Roblox, or bake to a final mesh
    /// in the Daemon.
    pub fn cook_asset(&self) -> Result<CookResult> {
        let start_time = Instant::now();

        let cook_options = CookOptions::default();
        self.geometry
            .node
            .cook_with_options(&cook_options, true)
            .map_err(|_| AssetError::CookAsset)?;
        let cook_time = Instant::now().duration_since(start_time);

        let mesh_data =
            MeshData::from_houdini_geo(&self.geometry).map_err(AssetError::GetMeshData)?;

        Ok(CookResult {
            mesh_data,
            stats: CookStats {
                cook_time: cook_time.as_secs_f64(),
            },
        })
    }
}
