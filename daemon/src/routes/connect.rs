use axum::{http::StatusCode, response::IntoResponse, Extension, Json};
use serde_json::json;

use crate::session::{AMSessionRegistry, RobloxSession};

pub async fn connect(Extension(registry): Extension<AMSessionRegistry>) -> impl IntoResponse {
    let session = RobloxSession::new().unwrap();
    let session_id = session.id.to_string();

    let mut registry = registry.lock().unwrap();
    registry.add_session(session);

    log::debug!("Created new session with ID {}", session_id);

    (
        StatusCode::CREATED,
        Json(json!({
            "id": session_id,
        })),
    )
}
