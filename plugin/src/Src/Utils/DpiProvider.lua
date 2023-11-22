local StudioService = game:GetService("StudioService")

local DpiProvider = {}

local _cachedDpi: number?

function DpiProvider.GetDpiScale(): number
	if _cachedDpi then
		return _cachedDpi
	end

	-- A disgusting hack that pattern matches the DPI out of Roblox's new SVG
	-- class icon names.
	local dpi = StudioService:GetClassIcon("Part").Image:match("(@.-)%.png$")
		or StudioService:GetClassIcon("Part").Image:match("(@.-)%.PNG$")
		or ""

	_cachedDpi = tonumber(dpi) or 2
	return _cachedDpi :: any
end

return DpiProvider
