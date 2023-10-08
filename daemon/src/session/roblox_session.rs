use anyhow::Context;
use hapi_rs::session::Session;
use uuid::Uuid;

use crate::message::IncomingMessage;

pub type MessageQueue = Vec<IncomingMessage>;

fn create_houdini_session(_id: &Uuid) -> anyhow::Result<Session> {
    // let pipe_path = env::temp_dir().join(format!("rbx_hapi_{}", id));

    // let socket_pid = hapi_rs::session::start_engine_pipe_server(
    //     &pipe_path,
    //     true,
    //     10.0,
    //     StatusVerbosity::Statusverbosity1,
    //     None,
    // )
    // .context("Failed to start Houdini Engine pipe server")?;

    // log::debug!("Started pipe server with PID {socket_pid}");

    // let session = hapi_rs::session::connect_to_pipe(&pipe_path, None, None)
    //     .context("Failed to connect to Houdini Engine pipe server")?;

    // log::debug!("Connected to pipe server");

    // TODO: Work out why IPC-based sessions won't work
    let session = hapi_rs::session::new_in_process(None)
        .context("Failed to create in-process Houdini session")?;

    Ok(session)
}

#[derive(Debug)]
pub struct RobloxSession {
    pub id: Uuid,
    pub message_queue: MessageQueue,
    pub houdini_session: Session,
}

impl RobloxSession {
    pub fn new() -> anyhow::Result<Self> {
        let id = Uuid::new_v4();

        let houdini_session =
            create_houdini_session(&id).context("Failed to create Houdini session")?;

        Ok(Self {
            id,
            message_queue: Vec::new(),
            houdini_session,
        })
    }
}
