use axum::{http::StatusCode, response::IntoResponse, Extension, Json};
use serde_json::json;

use crate::{session::AMSessionRegistry, utils::ExtractSessionId};

#[axum::debug_handler]
pub async fn get_messages(
    Extension(registry): Extension<AMSessionRegistry>,
    ExtractSessionId(session_id): ExtractSessionId,
) -> impl IntoResponse {
    let mut registry = registry.lock().await;

    if let Some(session) = registry.get_session_mut(&session_id) {
        // Loop some amount of time until a new message comes in
        for _ in 0..100 {
            if session.message_queue.len() > 0 {
                let messages = session.message_queue.drain(..).collect::<Vec<_>>();
                session.message_queue.clear();
                return (StatusCode::OK, Json(json!({ "messages": messages })));
            }

            tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
        }

        (StatusCode::OK, Json(json!({ "messages": [] })))
    } else {
        (
            StatusCode::BAD_REQUEST,
            Json(json!({
                "message": "Session does not exist"
            })),
        )
    }
}
