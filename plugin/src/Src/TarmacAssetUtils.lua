local DpiProvider = require("@Utils/DpiProvider")

export type Image = {
    image: string,
}

type TarmacAsset = string | Image | (dpi: number) -> (string | Image)

local TarmacAssetUtils = {}

function TarmacAssetUtils.resolveTarmacAsset(asset: TarmacAsset): Image
    if type(asset) == "string" then
        return {
            image = asset,
        }
    elseif type(asset) == "table" then
        return asset
    else
        return TarmacAssetUtils.resolveTarmacAsset(asset(DpiProvider.GetDpiScale()))
    end
end

return TarmacAssetUtils
