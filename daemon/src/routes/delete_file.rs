use std::path::PathBuf;

use axum::{http::StatusCode, Json};
use serde::Deserialize;

use crate::error::AppError;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DeleteFileRequest {
    pub path: PathBuf,
}

pub async fn delete_file(
    Json(body): Json<DeleteFileRequest>,
) -> Result<(StatusCode, Json<()>), AppError> {
    crate::asset_dir::delete_file(&body.path)?;
    Ok((StatusCode::OK, Json(())))
}
