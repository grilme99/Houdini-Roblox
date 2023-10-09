use axum::{http::StatusCode, response::IntoResponse, Extension, Json};
use serde_json::json;

use crate::{session::AMSessionRegistry, utils::ExtractSessionId};

pub async fn close(
    Extension(registry): Extension<AMSessionRegistry>,
    ExtractSessionId(session_id): ExtractSessionId,
) -> impl IntoResponse {
    let mut registry = registry.lock().await;

    let session = registry.get_session(&session_id).unwrap();
    session.houdini_session.cleanup().unwrap();

    registry.remove_session(&session_id);
    
    (StatusCode::OK, Json(json!({})))
}
