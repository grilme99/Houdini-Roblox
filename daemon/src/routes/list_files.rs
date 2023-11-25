use axum::{http::StatusCode, Json};
use serde::Serialize;

use crate::{asset_dir::FileConfig, error::AppError};

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ListFilesResponse {
    pub files: Vec<FileConfig>,
}

pub async fn list_files() -> Result<(StatusCode, Json<ListFilesResponse>), AppError> {
    let files = crate::asset_dir::list_files()?;
    Ok((StatusCode::OK, Json(ListFilesResponse { files })))
}
