use axum::{http::StatusCode, response::IntoResponse, Extension, Json};
use hapi_rs::session::StatusVerbosity;
use serde::Serialize;
use uuid::Uuid;

use crate::session::{AMSessionRegistry, SessionInfo, Session};

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct ConnectResponse {
    id: String,
    session_info: SessionInfo,
}

pub async fn connect(Extension(registry): Extension<AMSessionRegistry>) -> impl IntoResponse {
    let id = Uuid::new_v4();
    let options = crate::session::Options {
        auto_close: true,
        timeout: 3000.0,
        verbosity: StatusVerbosity::Statusverbosity2,
        log_file: None,
    };

    let pipe_name = format!("hapi_rbx_{id}");
    let session = Session::new_pipe(pipe_name, options).unwrap();
    let session_id = id.to_string();

    let session_info = session.session_info().unwrap();

    let mut registry = registry.lock().await;
    registry.add_session(session);

    log::debug!("Created new session with ID {}", session_id);

    (
        StatusCode::CREATED,
        Json(ConnectResponse {
            id: session_id,
            session_info,
        }),
    )
}
