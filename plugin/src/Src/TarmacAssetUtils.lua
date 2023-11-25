local DpiProvider = require("@Utils/DpiProvider")

export type ResolvedImage = {
	Image: string,
	ImageRectOffset: Vector2?,
	ImageRectSize: Vector2?,
}

export type TarmacAsset = string | ResolvedImage | (dpi: number) -> string | ResolvedImage

local TarmacAssetUtils = {}

function TarmacAssetUtils.ResolveTarmacAsset(asset: TarmacAsset, dpiOverride: number?): ResolvedImage
	if type(asset) == "string" then
		return {
			Image = asset,
		}
	elseif type(asset) == "table" then
		return asset
	else
		local dpi = dpiOverride or DpiProvider.GetDpiScale()
		return TarmacAssetUtils.ResolveTarmacAsset(asset(dpi))
	end
end

return TarmacAssetUtils
