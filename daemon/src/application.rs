use std::{net::SocketAddr, sync::Arc};

use axum::{
    routing::{get, post},
    Extension, Router,
};
use futures::lock::Mutex;

use crate::{
    routes::{close, connect, get_messages, send_message},
    session::SessionRegistry,
};

pub async fn start_application() -> anyhow::Result<()> {
    // TODO: Allow users to configure the address and port.
    let socket_addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    let address = socket_addr.ip().to_string();
    let port = socket_addr.port();

    log::info!("Starting application on {}:{}", address, port);

    let session_registry = Arc::new(Mutex::new(SessionRegistry::new()));

    let app = Router::new()
        .route("/close", post(close))
        .route("/connect", post(connect))
        .route("/messages", get(get_messages))
        .route("/message", post(send_message))
        .layer(Extension(session_registry));

    axum::Server::bind(&socket_addr)
        .serve(app.into_make_service())
        .await
        .map_err(|error| anyhow::anyhow!("Failed to start server: {}", error))?;

    Ok(())
}
