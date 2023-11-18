use axum::{http::StatusCode, response::IntoResponse, Json};
use serde::Serialize;
use serde_json::json;
use thiserror::Error;

use crate::{asset::AssetError, routes::OpenAssetError, session::SessionError};

#[derive(Debug, Error, Serialize)]
#[serde(untagged)]
#[error(transparent)]
pub enum AppError {
    AssetError(AssetError),
    OpenAssetError(OpenAssetError),
    SessionError(SessionError),
}

/// Macro to automate the implementation of the `From` trait for variants of the
/// `AppError` enum.
///
/// # Usage
///
/// Given an enum `AppError` with variants that each wrap a different error
/// type, this macro will generate an implementation of the `From` trait for
/// each error type.
macro_rules! from_variant {
    ($($variant:ident),*) => {
        $(
            impl From<$variant> for AppError {
                fn from(e: $variant) -> Self {
                    Self::$variant(e)
                }
            }
        )*
    };
}

from_variant!(AssetError, OpenAssetError, SessionError);

impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let status = match self {
            Self::AssetError(_) => StatusCode::INTERNAL_SERVER_ERROR,
            Self::OpenAssetError(_) => StatusCode::BAD_REQUEST,
            Self::SessionError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        };

        let body = Json(json!({
            "error": self,
            "message": self.to_string(),
        }));

        (status, body).into_response()
    }
}
