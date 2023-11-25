use std::{path::PathBuf, str::FromStr};

use axum::{http::StatusCode, Extension, Json};
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::{
    asset_dir::save_asset,
    error::AppError,
    message::{AppMsgReceiver, AppMsgTransmitter, ApplicationMessage, OpenFileSelectorOptions},
    session::AMSessionRegistry,
    state::StateError,
    utils::ExtractSessionId,
};

#[derive(Debug, Error, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum OpenAssetError {
    #[error("No session found")]
    NoSession,
    #[error("No file selected")]
    NoFileSelected,
    #[error(transparent)]
    StateError(StateError),
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OpenAssetRequest {
    pub directory: PathBuf,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct OpenAssetResponse {
    pub id: String,
}

#[axum::debug_handler]
pub async fn open_asset(
    Extension(tx_in): Extension<AppMsgTransmitter>,
    Extension(rx_out): Extension<AppMsgReceiver>,
    Extension(registry): Extension<AMSessionRegistry>,
    ExtractSessionId(session_id): ExtractSessionId,
    Json(body): Json<OpenAssetRequest>,
) -> Result<(StatusCode, Json<OpenAssetResponse>), AppError> {
    let mut registry = registry.lock().await;
    let mut rx_out = rx_out.lock().await;

    if let Some(session) = registry.get_session_mut(&session_id) {
        log::debug!("Opening new asset");

        let default = PathBuf::from_str("/").unwrap();
        let last_directory = session
            .state
            .last_opened_directory()
            .unwrap_or_else(|| &default);

        let options = OpenFileSelectorOptions {
            name: "Open HDA",
            filters: vec![("HDAs", &["otl", "hda", "hdanc", "hdalc", "hdal", "hdat"])],
            directory: last_directory.to_owned(),
        };

        tx_in
            .send(ApplicationMessage::OpenFileSelector(options))
            .await
            .unwrap();

        if let ApplicationMessage::FileSelected(Some(file)) = rx_out.recv().await.unwrap() {
            if let Some(parent) = file.parent() {
                session
                    .state
                    .set_last_opened_directory(parent.to_owned())
                    .map_err(OpenAssetError::StateError)?;
            }

            let display_name = file.file_name().unwrap().to_string_lossy().to_string();
            let id = save_asset(&body.directory, &file, &display_name)?;

            Ok((StatusCode::OK, Json(OpenAssetResponse { id })))
        } else {
            Err(OpenAssetError::NoFileSelected.into())
        }
    } else {
        Err(OpenAssetError::NoSession.into())
    }
}
