use std::path::Path;

use anyhow::Context;
use hapi_rs::{asset::AssetParameters, session::HoudiniNode};

use super::HoudiniSession;

pub struct Asset {
    asset_name: String,
    asset_params: AssetParameters,
    node: HoudiniNode,
}

impl Asset {
    pub fn new_from_file<P: AsRef<Path>>(
        session: &HoudiniSession,
        path: P,
    ) -> anyhow::Result<Self> {
        let asset_library = session
            .load_asset_file(path)
            .context("Failed to load asset file")?;

        let asset_name = asset_library
            .get_first_name()
            .context("Failed to get first asset name")?
            .context("Asset library contains no assets")?;

        let asset_params = asset_library
            .get_asset_parms(&asset_name)
            .context("Failed to get asset parameters")?;

        let node = asset_library
            .try_create_first()
            .context("Failed to create node for asset")?;

        log::debug!("Loaded asset {}", asset_name);

        Ok(Self {
            asset_name,
            asset_params,
            node,
        })
    }
}
