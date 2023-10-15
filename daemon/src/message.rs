use std::{path::PathBuf, sync::Arc};

use futures::lock::Mutex;
use serde::{Deserialize, Serialize};

#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
#[serde(rename_all = "PascalCase")]
pub enum OutgoingMessage {}

#[derive(Debug)]
pub struct OpenFileSelectorOptions {
    pub name: &'static str,
    pub filters: Vec<(&'static str, &'static [&'static str])>,
    pub directory: PathBuf,
}

pub type AppMsgTransmitter = tokio::sync::mpsc::Sender<ApplicationMessage>;
pub type AppMsgReceiver = Arc<Mutex<tokio::sync::mpsc::Receiver<ApplicationMessage>>>;

/// Messages that send between threads internally in the application
#[derive(Debug)]
pub enum ApplicationMessage {
    OpenFileSelector(OpenFileSelectorOptions),
    FileSelected(Option<PathBuf>),
}
