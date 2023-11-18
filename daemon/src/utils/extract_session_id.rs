use axum::{
    async_trait,
    extract::FromRequestParts,
    http::{request::Parts, StatusCode},
    Json,
};
use serde_json::{json, Value};
use uuid::Uuid;

pub struct ExtractSessionId(pub Uuid);

#[async_trait]
impl<S: Sized> FromRequestParts<S> for ExtractSessionId {
    type Rejection = (StatusCode, Json<Value>);

    async fn from_request_parts(parts: &mut Parts, _state: &S) -> Result<Self, Self::Rejection> {
        if let Some(session_id) = parts.headers.get("x-session-id") {
            let session_id = session_id.to_str().unwrap();

            if let Ok(session_id) = Uuid::parse_str(session_id) {
                Ok(ExtractSessionId(session_id))
            } else {
                Err((
                    StatusCode::BAD_REQUEST,
                    Json(json!({
                        "message": "`x-session-id` header is not a valid UUID"
                    })),
                ))
            }
        } else {
            Err((
                StatusCode::BAD_REQUEST,
                Json(json!({
                    "message": "`x-session-id` header is missing"
                })),
            ))
        }
    }
}
