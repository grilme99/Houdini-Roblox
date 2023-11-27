use std::path::PathBuf;

use axum::{http::StatusCode, Json};
use serde::Deserialize;

use crate::error::AppError;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RenameFileRequest {
    pub path: PathBuf,
    pub new_name: String,
}

pub async fn rename_file(
    Json(body): Json<RenameFileRequest>,
) -> Result<(StatusCode, Json<()>), AppError> {
    crate::asset_dir::rename_file(&body.path, &body.new_name)?;
    Ok((StatusCode::OK, Json(())))
}
