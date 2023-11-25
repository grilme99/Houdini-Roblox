use std::path::PathBuf;

use axum::{http::StatusCode, Json};
use serde::{Deserialize, Serialize};

use crate::error::AppError;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateFolderRequest {
    pub directory: PathBuf,
    pub display_name: String,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CreateFolderResponse {
    pub id: String,
}

pub async fn create_folder(
    Json(body): Json<CreateFolderRequest>,
) -> Result<(StatusCode, Json<CreateFolderResponse>), AppError> {
    let id = crate::asset_dir::create_folder(&body.directory, &body.display_name)?;
    let response = CreateFolderResponse { id };
    Ok((StatusCode::OK, Json(response)))
}
