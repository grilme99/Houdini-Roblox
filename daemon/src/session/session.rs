use std::{
    collections::HashMap,
    fs,
    net::SocketAddrV4,
    path::{Path, PathBuf},
};

use anyhow::Context;
use hapi_rs::session::{
    self, ConnectionType, License, Session as HoudiniSession, SessionOptionsBuilder, SessionType,
    StatusVerbosity,
};
use serde::Serialize;
use thiserror::Error;
use uuid::Uuid;

use crate::{
    asset::{Asset, AssetError},
    utils::set_hapi_env_variables,
};

#[derive(Debug, Error, Serialize)]
pub enum SessionError {
    #[error(transparent)]
    NewAssetError(AssetError),
}

type Result<T> = std::result::Result<T, SessionError>;

pub struct Options<'a> {
    pub auto_close: bool,
    pub timeout: f32,
    pub verbosity: StatusVerbosity,
    pub log_file: Option<&'a str>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SessionInfo {
    pub license_type: String,
    pub session_type: String,
    pub connection_type: String,
}

pub struct Session {
    pub session_id: Uuid,

    houdini_session: HoudiniSession,
    pipe_path: Option<PathBuf>,
    asset_db: HashMap<Uuid, Asset>,
}

impl Session {
    /// Creates and connects to a Houdini Engine pipe server.
    pub fn new_pipe<S: AsRef<Path>>(pipe_name: S, options: Options) -> anyhow::Result<Self> {
        set_hapi_env_variables().context("Failed to set Houdini environment variables")?;

        // Store the pipe file in the temp directory
        let temp = std::env::temp_dir();
        let pipe_path = temp.join(&pipe_name);

        log::debug!(
            "Starting pipe server with name {} at path {}",
            pipe_name.as_ref().display(),
            pipe_path.display()
        );

        let server_pid = session::start_engine_pipe_server(
            &pipe_path,
            options.auto_close,
            options.timeout,
            options.verbosity,
            options.log_file,
        )
        .context("Failed to start pipe server")?;

        log::debug!("Started pipe server with PID {server_pid}");

        let session_options = SessionOptionsBuilder::default().build();
        let session = session::connect_to_pipe(&pipe_path, Some(&session_options), None)
            .context("Failed to connect to Houdini pipe server")?;

        log::debug!("Connected to pipe server");

        Ok(Self {
            session_id: Uuid::new_v4(),

            houdini_session: session,
            pipe_path: Some(pipe_path),
            asset_db: HashMap::new(),
        })
    }

    /// Creates and connects to a Houdini Engine socket server.
    pub fn new_socket(port: u16, options: Options) -> anyhow::Result<Self> {
        set_hapi_env_variables().context("Failed to set Houdini environment variables")?;

        log::debug!("Starting socket server on port {}", port);

        let server_pid = session::start_engine_socket_server(
            port,
            options.auto_close,
            options.timeout as i32,
            options.verbosity,
            options.log_file,
        )
        .context("Failed to start socket server")?;

        log::debug!("Started socket server with PID {}", server_pid);

        let session_options = SessionOptionsBuilder::default().build();
        let session = session::connect_to_socket(
            SocketAddrV4::new([127, 0, 0, 1].into(), port),
            Some(&session_options),
        )
        .context("Failed to connect to Houdini socket server")?;

        log::debug!("Connected to socket server");

        Ok(Self {
            session_id: Uuid::new_v4(),

            houdini_session: session,
            pipe_path: None,
            asset_db: HashMap::new(),
        })
    }

    pub fn session_info(&self) -> anyhow::Result<SessionInfo> {
        let license_type = match self.houdini_session.get_license_type()? {
            License::LicenseNone => "None",
            License::HoudiniEngine => "Houdini Engine",
            License::LicenseHoudini => "Houdini",
            License::HoudiniFx => "Houdini FX",
            License::EngineIndie => "Houdini Engine Indie",
            License::HoudiniIndie => "Houdini Indie",
            License::UnityUnreal => "Unity/Unreal",
            License::LicenseMax => "Max",
            _ => "Unknown",
        };

        let session_type = match self.houdini_session.session_type() {
            SessionType::Inprocess => "In-process",
            SessionType::Thrift => "Thrift",
            SessionType::Max => "Max",
            _ => "Unknown",
        };

        let connection_type = match self.houdini_session.connection_type() {
            ConnectionType::Custom => "Custom",
            ConnectionType::InProcess => "In-process",
            ConnectionType::ThriftPipe(_) => "Thrift-pipe",
            ConnectionType::ThriftSocket(_) => "Thrift-socket",
        };

        Ok(SessionInfo {
            license_type: license_type.to_string(),
            session_type: session_type.to_string(),
            connection_type: connection_type.to_string(),
        })
    }

    /// Cleans up the session, closing the HAPI session and removing any temporary files.
    pub fn cleanup(&self) -> anyhow::Result<()> {
        self.houdini_session
            .cleanup()
            .context("Failed to cleanup HAPI session")?;

        if let Some(pipe_path) = &self.pipe_path {
            if pipe_path.exists() {
                fs::remove_file(pipe_path).context("Failed to remove pipe file")?;
            }
        }

        Ok(())
    }

    pub fn get_asset(&self, asset_id: Uuid) -> Option<&Asset> {
        self.asset_db.get(&asset_id)
    }

    pub fn load_asset_file<P: AsRef<Path>>(&mut self, path: &P) -> Result<Uuid> {
        let asset = Asset::new_from_path(&self.houdini_session, path)
            .map_err(SessionError::NewAssetError)?;

        let asset_id = Uuid::new_v4();
        self.asset_db.insert(asset_id, asset);

        Ok(asset_id)
    }
}
