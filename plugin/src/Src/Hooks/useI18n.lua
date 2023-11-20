local StudioService = game:GetService("StudioService")

local React = require("@Packages/React")

local useProperty = require("@Hooks/useProperty")

local PluginRoot = script:FindFirstAncestor("HoudiniEngineForRoblox")
local SourceStrings = PluginRoot.Localization.SourceStrings

local useMemo = React.useMemo

local function useI18n(key: string, ...): string
	local localeId: string = useProperty(StudioService, "StudioLocaleId")
	local translator = useMemo(function()
		return SourceStrings:GetTranslator(localeId)
	end, { localeId })

	return translator:FormatByKey(key, ...)
end

return useI18n
