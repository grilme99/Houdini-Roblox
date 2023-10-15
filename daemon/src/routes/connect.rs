use axum::{http::StatusCode, response::IntoResponse, Extension, Json};
use serde::Serialize;

use crate::session::{AMSessionRegistry, RobloxSession, SessionInfo};

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct ConnectResponse {
    id: String,
    session_info: SessionInfo,
}

pub async fn connect(Extension(registry): Extension<AMSessionRegistry>) -> impl IntoResponse {
    let roblox_session = RobloxSession::new().unwrap();
    let session_id = roblox_session.id.to_string();

    let hapi = &roblox_session.houdini_session;
    let session_info = hapi.session_info().unwrap();

    let mut registry = registry.lock().await;
    registry.add_session(roblox_session);

    log::debug!("Created new session with ID {}", session_id);

    (
        StatusCode::CREATED,
        Json(ConnectResponse {
            id: session_id,
            session_info,
        }),
    )
}
