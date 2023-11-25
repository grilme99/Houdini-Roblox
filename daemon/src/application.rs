use std::{net::SocketAddr, sync::Arc};

use axum::{routing::post, Extension, Router};
use futures::lock::Mutex;
use tokio::sync::mpsc;

use crate::{
    message::ApplicationMessage,
    routes::{close, connect, open_asset, list_files, create_folder},
    session::SessionRegistry,
};

pub async fn start_application() -> anyhow::Result<()> {
    // TODO: Allow users to configure the address and port.
    let socket_addr = SocketAddr::from(([127, 0, 0, 1], 3030));
    let address = socket_addr.ip().to_string();
    let port = socket_addr.port();

    log::info!("Starting application on {}:{}", address, port);

    let (tx_in, mut rx_in) = mpsc::channel::<ApplicationMessage>(32);
    let (tx_out, rx_out) = mpsc::channel::<ApplicationMessage>(32);

    let session_registry = Arc::new(Mutex::new(SessionRegistry::new()));

    let app = Router::new()
        .route("/close", post(close))
        .route("/connect", post(connect))
        .route("/open-asset", post(open_asset))
        .route("/list-files", post(list_files))
        .route("/create-folder", post(create_folder))
        .layer(Extension(session_registry))
        .layer(Extension(tx_in))
        .layer(Extension(Arc::new(Mutex::new(rx_out))));

    // Spawn Axum server as a detached task
    tokio::spawn(async move {
        if let Err(error) = axum::Server::bind(&socket_addr)
            .serve(app.into_make_service())
            .await
        {
            eprintln!("Failed to start server: {}", error);
        }
    });

    // Some code MUST run on the main thread, so we handle that here with
    // message passing.
    while let Some(message) = rx_in.recv().await {
        match message {
            ApplicationMessage::OpenFileSelector(options) => {
                log::debug!("Opening file selector with options {:?}", options);

                let mut dialog = rfd::FileDialog::new()
                    .set_directory(options.directory)
                    .set_title(options.name);

                for (name, extensions) in options.filters {
                    dialog = dialog.add_filter(name, extensions);
                }

                let res = dialog.pick_file();
                tx_out.send(ApplicationMessage::FileSelected(res)).await?;
            }
            _ => {}
        }
    }

    Ok(())
}
