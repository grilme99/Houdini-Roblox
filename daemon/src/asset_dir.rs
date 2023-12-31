use std::{
    fs,
    path::{Path, PathBuf},
};

use chrono::{DateTime, Utc};
use nanoid::nanoid;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::state::get_config_dir;

#[derive(Debug, Error, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum AssetDirError {
    #[error("An unknown file system error occurred")]
    FsError(String),
    #[error("A config file could not be serialized or deserialized")]
    SerdeError(String),
    #[error("The parent directory {0} does not exist")]
    BadParent(String),
    #[error("The file {0} does not exist")]
    FileDoesNotExist(String),
}

type Result<T> = std::result::Result<T, AssetDirError>;

#[derive(Debug, Serialize, Deserialize)]
pub enum AssetType {
    /// Old format for HDAs, primarily used in earlier versions of Houdini.
    #[serde(rename = "OTL")]
    Otl,
    /// The standard HDA file type used to store node networks that can be
    /// reused.
    #[serde(rename = "HDA")]
    Hda,
    /// Stands for Houdini Digital Asset Non-Commercial. It is the same as `Hda`
    /// but is only usable in non-commercial versions of Houdini.
    #[serde(rename = "HDA (Non-Commercial)")]
    Hdanc,
    /// Stands for Houdini Digital Asset Locked Commercial. It is a non-editable
    /// version of an asset that can be used in commercial versions of Houdini.
    #[serde(rename = "HDA (Locked Commercial)")]
    Hdalc,
    /// A locked Houdini Digital Asset that is not editable and is typically
    /// used for sharing without exposing the underlying network or parameters
    /// for editing.
    #[serde(rename = "HDA (Locked)")]
    Hdal,
    /// Houdini Digital Asset Template, a file type meant for HDAs that are
    /// intended to be templates for other assets.
    #[serde(rename = "HDA (Template)")]
    Hdat,
    /// An unrecognized asset file.
    Unknown,
}

impl From<&Path> for AssetType {
    fn from(path: &Path) -> Self {
        // Match the extension of the file to determine the asset type.
        match path.extension().and_then(|ext| ext.to_str()) {
            Some("otl") => Self::Otl,
            Some("hda") => Self::Hda,
            Some("hdanc") => Self::Hdanc,
            Some("hdalc") => Self::Hdalc,
            Some("hdal") => Self::Hdal,
            Some("hdat") => Self::Hdat,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum FileType {
    Folder(FolderConfig),
    Asset(AssetConfig),
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FolderConfig {
    pub children: Option<Vec<FileConfig>>,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AssetConfig {
    pub asset_type: AssetType,
    /// Points to the actual Houdini asset file that isn't directly managed by
    /// the daemon.
    pub asset_path: PathBuf,
    /// The asset file could have been deleted or moved, so this field is used
    /// to indicate whether the asset file still exists.
    pub asset_exists: bool,
}

/// Each daemon-managed asset has a corresponding config file that contains
/// information and metadata about the asset. This struct is directly serialized
/// and deserialized to and from the config file.
#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct FileConfig {
    pub id: String,
    pub display_name: String,
    pub date_modified: DateTime<Utc>,
    pub meta: FileType,
}

fn get_root_dir() -> Result<PathBuf> {
    let config_dir = get_config_dir().map_err(|err| AssetDirError::FsError(err.to_string()))?;
    let root_dir = config_dir.join("Assets");

    if !root_dir.exists() {
        fs::create_dir_all(&root_dir).map_err(|err| AssetDirError::FsError(err.to_string()))?;
    }

    Ok(root_dir)
}

/// Creates a daemon-managed folder.
pub fn create_folder(directory: &Path, display_name: &str) -> Result<String> {
    let root_dir = get_root_dir()?;
    let dir = root_dir.join(directory);

    if !dir.exists() {
        return Err(AssetDirError::BadParent(
            directory.to_string_lossy().to_string(),
        ));
    }

    let id = nanoid!(10);
    let folder_path = dir.join(&id);
    let config_path = dir.join(format!("{id}.json"));

    let folder_config = FileConfig {
        id: id.to_owned(),
        display_name: display_name.to_string(),
        date_modified: Utc::now(),
        meta: FileType::Folder(FolderConfig { children: None }),
    };

    fs::create_dir_all(&folder_path).map_err(|err| AssetDirError::FsError(err.to_string()))?;
    fs::write(
        &config_path,
        serde_json::to_string_pretty(&folder_config).unwrap(),
    )
    .map_err(|err| AssetDirError::FsError(err.to_string()))?;

    log::debug!("Created folder {folder_path:?}");

    Ok(id)
}

/// Saves an asset pointer to the daemon-managed asset directory.
pub fn save_asset(directory: &Path, asset_path: &Path, display_name: &str) -> Result<String> {
    let root_dir = get_root_dir()?;
    let dir = root_dir.join(directory);

    if !dir.exists() {
        return Err(AssetDirError::BadParent(
            directory.to_string_lossy().to_string(),
        ));
    }

    let id = nanoid!(10);
    let asset_config_path = dir.join(format!("{id}.json"));

    let asset_config = FileConfig {
        id: id.to_owned(),
        display_name: display_name.to_string(),
        date_modified: Utc::now(),
        meta: FileType::Asset(AssetConfig {
            asset_type: asset_path.into(),
            asset_path: asset_path.to_owned(),
            asset_exists: asset_path.exists(),
        }),
    };

    fs::write(
        &asset_config_path,
        serde_json::to_string_pretty(&asset_config).unwrap(),
    )
    .map_err(|err| AssetDirError::FsError(err.to_string()))?;

    log::debug!("Saved asset {asset_path:?}");

    Ok(id)
}

fn list_files_recursive(current_dir: &Path) -> Result<Vec<FileConfig>> {
    let mut files = Vec::new();

    // Iterate over the entries in the current directory.
    for entry in fs::read_dir(current_dir).map_err(|err| AssetDirError::FsError(err.to_string()))? {
        let entry = entry.map_err(|err| AssetDirError::FsError(err.to_string()))?;
        let path = entry.path();

        // Skip the entry if it's not a file or if it doesn't have a .json extension.
        if path.is_file() && path.extension().and_then(|s| s.to_str()) == Some("json") {
            // Read and deserialize the .json file into a FileConfig.
            let mut file_config: FileConfig = serde_json::from_reader(
                fs::File::open(&path).map_err(|err| AssetDirError::FsError(err.to_string()))?,
            )
            .map_err(|err| AssetDirError::SerdeError(err.to_string()))?;

            if let FileType::Folder(_) = file_config.meta {
                // If it's a folder configuration, read its children.
                let folder_path = path.with_extension("");
                if folder_path.is_dir() {
                    // Recursively list the files in the subdirectory.
                    let children = list_files_recursive(&folder_path)?;
                    if let FileType::Folder(folder_config) = &mut file_config.meta {
                        folder_config.children = Some(children);
                    }
                }
            } else if let FileType::Asset(asset_config) = &mut file_config.meta {
                // If it's an asset configuration, check if the asset file exists.
                asset_config.asset_exists = asset_config.asset_path.exists();

                let asset_modified: DateTime<Utc> = fs::metadata(&asset_config.asset_path)
                    .map_err(|err| AssetDirError::FsError(err.to_string()))?
                    .modified()
                    .map_err(|err| AssetDirError::FsError(err.to_string()))?
                    .into();

                if asset_modified > file_config.date_modified {
                    file_config.date_modified = asset_modified;
                }
            }

            files.push(file_config);
        }
    }

    Ok(files)
}

pub fn delete_file(path: &Path) -> Result<()> {
    let root_dir = get_root_dir()?;
    let file_path = root_dir.join(path);

    let mut deleted_something = false;
    if file_path.exists() {
        deleted_something = true;
        if file_path.is_file() {
            fs::remove_file(&file_path).map_err(|err| AssetDirError::FsError(err.to_string()))?;
        } else if file_path.is_dir() {
            fs::remove_dir_all(&file_path)
                .map_err(|err| AssetDirError::FsError(err.to_string()))?;
        } else {
            log::warn!("Path {file_path:?} is neither a file nor a directory",)
        }
    }

    // Delete the corresponding .json file.
    let config_path = file_path.with_extension("json");
    if config_path.exists() {
        deleted_something = true;
        fs::remove_file(&config_path).map_err(|err| AssetDirError::FsError(err.to_string()))?;
    }

    if !deleted_something {
        return Err(AssetDirError::FileDoesNotExist(
            path.to_string_lossy().to_string(),
        ));
    }

    log::debug!("Deleted file {file_path:?}");
    Ok(())
}

pub fn rename_file(path: &Path, new_name: &str) -> Result<()> {
    let root_dir = get_root_dir()?;
    let file_path = root_dir.join(path).with_extension("json");

    if !file_path.exists() {
        return Err(AssetDirError::FileDoesNotExist(
            file_path.to_string_lossy().to_string(),
        ));
    }

    let mut file_config: FileConfig = serde_json::from_reader(
        fs::File::open(&file_path).map_err(|err| AssetDirError::FsError(err.to_string()))?,
    )
    .map_err(|err| AssetDirError::SerdeError(err.to_string()))?;

    file_config.display_name = new_name.to_string();
    file_config.date_modified = Utc::now();

    fs::write(
        &file_path,
        serde_json::to_string_pretty(&file_config).unwrap(),
    )
    .map_err(|err| AssetDirError::FsError(err.to_string()))?;

    log::debug!("Renamed file {file_path:?} to {new_name}");
    Ok(())
}

pub fn list_files() -> Result<Vec<FileConfig>> {
    let root_dir = get_root_dir()?;
    log::debug!("Listing files in {root_dir:?}");

    if !root_dir.exists() {
        return Ok(Vec::new());
    }

    let children = list_files_recursive(&root_dir)?;
    Ok(children)
}
