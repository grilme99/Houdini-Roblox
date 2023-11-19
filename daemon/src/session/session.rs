use std::{
    collections::HashMap,
    fs,
    net::SocketAddrV4,
    path::{Path, PathBuf},
};

use anyhow::Context;
use hapi_rs::session::{
    self, ConnectionType, License, Session as HoudiniSession, SessionOptionsBuilder,
    SessionType as HapiSessionType, StatusVerbosity,
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
    #[error("Failed to set HAPI environment variables")]
    SetHAPIEnvError,

    #[error("Failed to start Houdini pipe server")]
    StartPipeServerError,
    #[error("Failed to connect to Houdini pipe server")]
    ConnectToPipeError,

    #[error("Failed to start Houdini socket server")]
    StartSocketServerError,
    #[error("Failed to connect to Houdini socket server")]
    ConnectToSocketError,

    #[error(transparent)]
    NewAssetError(AssetError),
}

type Result<T> = std::result::Result<T, SessionError>;

pub enum SessionType {
    Pipe(String),
    Socket(u16),
}

pub struct Options<'a> {
    pub session_type: SessionType,
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
    pub pipe_path: Option<PathBuf>,
}

pub struct Session {
    pub session_id: Uuid,

    houdini_session: HoudiniSession,
    pipe_path: Option<PathBuf>,
    asset_db: HashMap<Uuid, Asset>,
}

impl Session {
    pub fn new(options: Options) -> Result<Self> {
        set_hapi_env_variables().map_err(|_| SessionError::SetHAPIEnvError)?;

        let session_id = Uuid::new_v4();
        log::debug!("Starting session with ID {}", session_id);

        let mut pipe_path = None;
        let houdini_session = match &options.session_type {
            SessionType::Pipe(pipe_name) => {
                let temp = std::env::temp_dir();
                let pipe_path_ = temp.join(&pipe_name);

                pipe_path = Some(pipe_path_.clone());

                log::debug!(
                    "Starting pipe server with name {pipe_name} at path {}",
                    pipe_path_.display()
                );

                let server_pid = session::start_engine_pipe_server(
                    &pipe_path_,
                    options.auto_close,
                    options.timeout,
                    options.verbosity,
                    options.log_file,
                )
                .map_err(|_| SessionError::StartPipeServerError)?;

                log::debug!("Started pipe server with PID {server_pid}");

                let session_options = SessionOptionsBuilder::default().build();
                session::connect_to_pipe(&pipe_path_, Some(&session_options), None)
                    .map_err(|_| SessionError::ConnectToPipeError)?
            }
            SessionType::Socket(port) => {
                log::debug!("Starting socket server on port {}", port);

                let server_pid = session::start_engine_socket_server(
                    *port,
                    options.auto_close,
                    options.timeout as i32,
                    options.verbosity,
                    options.log_file,
                )
                .map_err(|_| SessionError::StartSocketServerError)?;

                log::debug!("Started socket server with PID {}", server_pid);

                let session_options = SessionOptionsBuilder::default().build();
                session::connect_to_socket(
                    SocketAddrV4::new([127, 0, 0, 1].into(), *port),
                    Some(&session_options),
                )
                .map_err(|_| SessionError::ConnectToSocketError)?
            }
        };

        log::debug!("Connected to hapi session");

        Ok(Self {
            session_id,

            houdini_session,
            pipe_path,
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
            HapiSessionType::Inprocess => "In-process",
            HapiSessionType::Thrift => "Thrift",
            HapiSessionType::Max => "Max",
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
            pipe_path: self.pipe_path.clone(),
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
