use anyhow::Context;
use hapi_rs::session::StatusVerbosity;
use uuid::Uuid;

use crate::message::OutgoingMessage;

use super::HoudiniSession;

pub type MessageQueue = Vec<OutgoingMessage>;

#[derive(Debug)]
pub struct RobloxSession {
    pub id: Uuid,
    pub message_queue: MessageQueue,
    pub houdini_session: HoudiniSession,
}

impl RobloxSession {
    pub fn new() -> anyhow::Result<Self> {
        let id = Uuid::new_v4();

        let options = crate::session::Options {
            auto_close: true,
            timeout: 3000.0,
            verbosity: StatusVerbosity::Statusverbosity2,
            log_file: None,
        };

        let pipe_name = format!("hapi_rbx_{id}");
        let houdini_session = HoudiniSession::new_pipe(pipe_name, options)
            .context("Failed to create Houdini session")?;

        Ok(Self {
            id,
            message_queue: Vec::new(),
            houdini_session,
        })
    }
}
