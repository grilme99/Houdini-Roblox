use axum::{http::StatusCode, response::IntoResponse, Json};
use serde_json::json;

pub async fn get_message() -> impl IntoResponse {
    (
        StatusCode::CREATED,
        Json(json!({
            "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
        })),
    )
}
