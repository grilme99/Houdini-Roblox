local DpiProvider = require("@Utils/DpiProvider")

export type ResolvedImage = {
	Image: string,
	ImageRectOffset: Vector2?,
	ImageRectSize: Vector2?,
}

export type TarmacAsset = string | ResolvedImage | (dpi: number) -> string | ResolvedImage

local TarmacAssetUtils = {}

function TarmacAssetUtils.ResolveTarmacAsset(asset: TarmacAsset): ResolvedImage
	if type(asset) == "string" then
		return {
			Image = asset,
		}
	elseif type(asset) == "table" then
		return asset
	else
		return TarmacAssetUtils.ResolveTarmacAsset(asset(DpiProvider.GetDpiScale()))
	end
end

return TarmacAssetUtils
