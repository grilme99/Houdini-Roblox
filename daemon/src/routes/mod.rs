mod close;
mod connect;
mod create_folder;
mod list_files;
mod open_asset;

pub use close::close;
pub use connect::connect;
pub use create_folder::create_folder;
pub use list_files::list_files;
pub use open_asset::{open_asset, OpenAssetError};

use axum::{http::StatusCode, Json};

use crate::error::AppError;

pub type AppResponse<T> = Result<(StatusCode, Json<T>), AppError>;
