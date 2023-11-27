mod close;
mod connect;
mod create_folder;
mod delete_file;
mod list_files;
mod open_asset;
mod rename_file;

pub use close::close;
pub use connect::connect;
pub use create_folder::create_folder;
pub use delete_file::delete_file;
pub use list_files::list_files;
pub use open_asset::{open_asset, OpenAssetError};
pub use rename_file::rename_file;

use axum::{http::StatusCode, Json};

use crate::error::AppError;

pub type AppResponse<T> = Result<(StatusCode, Json<T>), AppError>;
