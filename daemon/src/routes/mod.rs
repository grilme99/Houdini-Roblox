mod close;
mod connect;
mod open_asset;

pub use close::close;
pub use connect::connect;
pub use open_asset::{open_asset, OpenAssetError};

use axum::{http::StatusCode, Json};

use crate::error::AppError;

pub type AppResponse<T> = Result<(StatusCode, Json<T>), AppError>;
