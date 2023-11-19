use axum::{http::StatusCode, Extension, Json};
use hapi_rs::session::StatusVerbosity;
use serde::Serialize;
use uuid::Uuid;

use crate::session::{AMSessionRegistry, Session, SessionInfo, SessionType};

use super::AppResponse;

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ConnectResponse {
    id: Uuid,
    session_info: SessionInfo,
}

pub async fn connect(
    Extension(registry): Extension<AMSessionRegistry>,
) -> AppResponse<ConnectResponse> {
    let id = Uuid::new_v4();

    let options = crate::session::Options {
        session_type: SessionType::Pipe(format!("hapi_rbx_{id}")),
        auto_close: true,
        timeout: 3000.0,
        verbosity: StatusVerbosity::Statusverbosity0,
        log_file: None,
    };

    let session = Session::new(options)?;
    let session_id = session.session_id;

    let session_info = session.session_info()?;

    let mut registry = registry.lock().await;
    registry.add_session(session);

    log::debug!("Created new session with ID {}", session_id);

    Ok((
        StatusCode::CREATED,
        Json(ConnectResponse {
            id: session_id,
            session_info,
        }),
    ))
}
