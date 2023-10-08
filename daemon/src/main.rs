#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::try_init()?;

    daemon::application::start_application().await?;

    Ok(())
}
