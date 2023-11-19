use std::path::PathBuf;

use anyhow::Context;

#[cfg(any(target_os = "windows", target_os = "linux"))]
compile_error!("Windows and Linux are not supported yet");

#[cfg(target_os = "macos")]
pub const HOUDINI_INSTALL_PATH: &str = "/Applications/Houdini/Current";
#[cfg(target_os = "macos")]
pub const HOUDINI_FRAMEWORKS_PATH: &str = "./Frameworks/Houdini.framework/Versions/Current";

#[cfg(target_os = "macos")]
pub const HFS_PATH: &str = "./Resources";
#[cfg(target_os = "macos")]
pub const HAPI_BIN_PATH: &str = "./Resources/bin";
#[cfg(target_os = "macos")]
pub const HAPI_LIBRARY_PATH: &str = "./Libraries";

#[cfg(target_os = "macos")]
fn get_houdini_install() -> PathBuf {
    if let Ok(hapi_path) = std::env::var("HAPI_PATH") {
        PathBuf::from(hapi_path)
    } else {
        PathBuf::from(HOUDINI_INSTALL_PATH)
    }
}

/// HAPI expects some environment variables to be set in order to work properly.
/// It also requires some libraries to exist on the PATH, so PATH is updated
/// also.
pub fn set_hapi_env_variables() -> anyhow::Result<()> {
    println!("AAAA");
    #[cfg(target_os = "macos")]
    {
        println!("bbbbb");
        let install_path = get_houdini_install()
            .canonicalize()
            .context("Failed to canonicalize install path")?;
        let frameworks_path = install_path
            .join(HOUDINI_FRAMEWORKS_PATH)
            .canonicalize()
            .context("Failed to canonicalize frameworks path")?;

        let hfs_path = frameworks_path.join(HFS_PATH);
        let hapi_bin_path = frameworks_path.join(HAPI_BIN_PATH);
        let hapi_library_path = frameworks_path.join(HAPI_LIBRARY_PATH);

        let houdini_path = hfs_path.join("./houdini");
        let hsb_path = houdini_path.join("./sbin");

        std::env::set_var("H", &hfs_path);
        std::env::set_var("HB", &hapi_bin_path);
        std::env::set_var("HDSO", &hapi_library_path);
        std::env::set_var("HH", &hfs_path.join(&houdini_path));
        std::env::set_var("HHC", &houdini_path.join("./config"));
        std::env::set_var("HHP", &houdini_path.join("./python3.9libs"));
        std::env::set_var("HT", &hfs_path.join("./toolkit"));
        std::env::set_var("HSB", &hsb_path);

        std::env::set_var("DYLD_LIBRARY_PATH", &hapi_library_path);

        let path = std::env::var("PATH").unwrap_or_default();
        std::env::set_var(
            "PATH",
            format!("{}:{}:{path}", hapi_bin_path.display(), hsb_path.display()),
        );
    }

    Ok(())
}
