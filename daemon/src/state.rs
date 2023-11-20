use std::{fs, path::PathBuf};

use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Error, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum StateError {
    #[error("Config directory not found")]
    ConfigDirNotFound,
    #[error("State file could not be serialized or deserialized")]
    SerdeError,
    #[error("An unknown file system error occurred")]
    FsError,
}

type Result<T> = std::result::Result<T, StateError>;

fn get_config_dir() -> Result<PathBuf> {
    let config_dir = dirs::config_dir().ok_or(StateError::ConfigDirNotFound)?;
    Ok(config_dir.join("HoudiniEngineForRoblox"))
}

fn get_config_path() -> Result<PathBuf> {
    Ok(get_config_dir()?.join("state.json"))
}

/// Provides facilities for persisting the state of the daemon across sessions.
#[derive(Debug, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase", default)]
pub struct DaemonState {
    /// The last directory used to open an asset. Used to open the same
    /// directory when the asset prompt is opened again.
    last_opened_directory: Option<PathBuf>,
}

impl DaemonState {
    pub fn new() -> Result<Self> {
        let config_path = get_config_path()?;
        if config_path.exists() {
            let state = fs::read_to_string(config_path).map_err(|_| StateError::FsError)?;
            let state = serde_json::from_str(&state).map_err(|_| StateError::SerdeError)?;
            Ok(state)
        } else {
            Ok(Self::default())
        }
    }

    fn save_state(&self) -> Result<()> {
        let config_dir = get_config_dir()?;
        fs::create_dir_all(&config_dir).map_err(|_| StateError::FsError)?;

        let config_path = get_config_path()?;
        let state = serde_json::to_string_pretty(self).map_err(|_| StateError::SerdeError)?;
        fs::write(&config_path, &state).map_err(|_| StateError::FsError)?;

        log::debug!("Saved daemon state to {config_path:?}");

        Ok(())
    }

    pub fn last_opened_directory(&self) -> Option<&PathBuf> {
        self.last_opened_directory.as_ref()
    }

    pub fn set_last_opened_directory(&mut self, path: PathBuf) -> Result<()> {
        self.last_opened_directory = Some(path);
        self.save_state()
    }
}
