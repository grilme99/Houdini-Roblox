use std::sync::Arc;

use futures::lock::Mutex;

use uuid::Uuid;

use super::Session;

pub type AMSessionRegistry = Arc<Mutex<SessionRegistry>>;

pub struct SessionRegistry {
    sessions: Vec<Session>,
}

impl SessionRegistry {
    pub fn new() -> Self {
        Self { sessions: vec![] }
    }

    pub fn add_session(&mut self, session: Session) {
        self.sessions.push(session);
    }

    pub fn remove_session(&mut self, session_id: &Uuid) {
        self.sessions.retain(|i| &i.session_id != session_id);
    }

    pub fn get_session(&self, session_id: &Uuid) -> Option<&Session> {
        self.sessions.iter().find(|i| &i.session_id == session_id)
    }

    pub fn get_session_mut(&mut self, session_id: &Uuid) -> Option<&mut Session> {
        self.sessions.iter_mut().find(|i| &i.session_id == session_id)
    }
}
