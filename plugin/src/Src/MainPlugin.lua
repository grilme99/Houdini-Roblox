local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local Toolbar = require("@Components/Plugin/Toolbar")
local ToolbarButton = require("@Components/Plugin/ToolbarButton")
local DockWidget = require("@Components/Plugin/DockWidget")

local StudioTheme = require("@Contexts/StudioTheme")
local useStudioTheme = StudioTheme.useStudioTheme

local ThemeUtils = require("@Utils/ThemeUtils")

local AppContainer = require("@Src/AppContainer")
local ContextProvider = require("@Src/ContextProvider")
local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

local useI18n = require("@Hooks/useI18n")

local e = React.createElement
local useState = React.useState

type HoudiniToolbarProps = {
	plugin: Plugin,
	enabled: boolean,
	toggleEnabled: () -> (),
}

local function HoudiniToolbar(props: HoudiniToolbarProps)
	local plugin = props.plugin
	local enabled = props.enabled
	local toggleEnabled = props.toggleEnabled

	local pluginName = useI18n("General.HoudiniEngine")
	local tooltip = useI18n("General.ToolbarButtonTooltip")

	local theme = useStudioTheme()
	local isDark = ThemeUtils.IsDarkerTheme(theme)

	local icon = if isDark
		then TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.EngineBadge_DarkTheme).Image
		else TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.EngineBadge_LightTheme).Image

	return e(Toolbar, {
		plugin = plugin,
		title = pluginName,
		renderButtons = function(toolbar)
			return {
				Toggle = e(ToolbarButton, {
					plugin = plugin,
					toolbar = toolbar,
					active = enabled,
					title = pluginName,
					tooltip = tooltip,
					clickableWhenViewportHidden = true,
					icon = icon,
					onClick = toggleEnabled,
				}),
			}
		end,
	})
end

export type Props = {
	plugin: Plugin,
}

local function MainPlugin(props: Props)
	local plugin = props.plugin

	local enabled, setEnabled = useState(false)
	local function toggleEnabled()
		setEnabled(function(enabled)
			return not enabled
		end)
	end

	local pluginName = useI18n("General.HoudiniEngine")

	return e(ContextProvider, {
		plugin = plugin,
	}, {
		HoudiniToolbar = e(HoudiniToolbar, {
			plugin = plugin,
			enabled = enabled,
			toggleEnabled = toggleEnabled,
		}),

		HoudiniWidget = e(DockWidget, {
			plugin = plugin,
			enabled = enabled,
			title = pluginName,
			id = plugin.Name,
			zIndexBehavior = Enum.ZIndexBehavior.Sibling,
			initialDockState = Enum.InitialDockState.Right,
			size = Vector2.new(400, 600),
			minSize = Vector2.new(250, 200),
			onClose = function()
				setEnabled(false)
			end,
			shouldRestore = true,
			onWidgetRestored = function(enabled)
				setEnabled(enabled)
			end,
			[ReactRoblox.Change.Enabled] = function(rbx: DockWidgetPluginGui)
				setEnabled(rbx.Enabled)
			end,
		}, {
			AppContainer = e(AppContainer, {}),
		}),
	})
end

return MainPlugin
