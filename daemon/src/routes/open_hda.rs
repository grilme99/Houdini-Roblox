use axum::{http::StatusCode, response::IntoResponse, Extension, Json};
use serde_json::json;

use crate::{
    message::{AppMsgReceiver, AppMsgTransmitter, ApplicationMessage, OpenFileSelectorOptions},
    session::{AMSessionRegistry, Asset},
    utils::ExtractSessionId,
};

pub async fn open_hda(
    Extension(tx_in): Extension<AppMsgTransmitter>,
    Extension(rx_out): Extension<AppMsgReceiver>,
    Extension(registry): Extension<AMSessionRegistry>,
    ExtractSessionId(session_id): ExtractSessionId,
) -> impl IntoResponse {
    let registry = registry.lock().await;
    let mut rx_out = rx_out.lock().await;

    if let Some(session) = registry.get_session(&session_id) {
        let options = OpenFileSelectorOptions {
            name: "Open HDA",
            filters: vec![("HDAs", &["otl", "hda", "otllc", "otlnc", "hdanc"])],
            directory: "/".into(),
        };

        tx_in
            .send(ApplicationMessage::OpenFileSelector(options))
            .await
            .unwrap();

        if let ApplicationMessage::FileSelected(Some(file)) = rx_out.recv().await.unwrap() {
            let _asset = Asset::new_from_file(&session.houdini_session, &file).unwrap();

            (StatusCode::OK, Json(json!({})))
        } else {
            (
                StatusCode::BAD_REQUEST,
                Json(json!({
                    "message": "No file was selected"
                })),
            )
        }
    } else {
        (
            StatusCode::BAD_REQUEST,
            Json(json!({
                "message": "Session does not exist"
            })),
        )
    }
}
