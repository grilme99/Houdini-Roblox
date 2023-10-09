use std::sync::Arc;

use futures::lock::Mutex;

use uuid::Uuid;

use super::RobloxSession;

pub type AMSessionRegistry = Arc<Mutex<SessionRegistry>>;

#[derive(Debug)]
pub struct SessionRegistry {
    sessions: Vec<RobloxSession>,
}

impl SessionRegistry {
    pub fn new() -> Self {
        Self { sessions: vec![] }
    }

    pub fn add_session(&mut self, session: RobloxSession) {
        self.sessions.push(session);
    }

    pub fn remove_session(&mut self, session_id: &Uuid) {
        self.sessions.retain(|i| &i.id != session_id);
    }

    pub fn get_session(&self, session_id: &Uuid) -> Option<&RobloxSession> {
        self.sessions.iter().find(|i| &i.id == session_id)
    }

    pub fn get_session_mut(&mut self, session_id: &Uuid) -> Option<&mut RobloxSession> {
        self.sessions.iter_mut().find(|i| &i.id == session_id)
    }
}
