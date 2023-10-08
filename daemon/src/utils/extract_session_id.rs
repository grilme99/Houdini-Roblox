use axum::{
    async_trait,
    extract::FromRequest,
    http::{Request, StatusCode},
    Json,
};
use serde_json::{json, Value};
use uuid::Uuid;

pub struct ExtractSessionId(pub Uuid);

#[async_trait]
impl<S: Send + Sync, B: Send + 'static> FromRequest<S, B> for ExtractSessionId {
    type Rejection = (StatusCode, Json<Value>);

    async fn from_request(req: Request<B>, _state: &S) -> Result<Self, Self::Rejection> {
        if let Some(session_id) = req.headers().get("x-session-id") {
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
