local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local Toolbar = require("@Components/Plugin/Toolbar")
local ToolbarButton = require("@Components/Plugin/ToolbarButton")
local DockWidget = require("@Components/Plugin/DockWidget")

local MainView = require("@Components/App/MainView")

local ContextProvider = require("@Src/ContextProvider")
local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

local useI18n = require("@Hooks/useI18n")

local e = React.createElement
local useState = React.useState

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
	local tooltip = useI18n("General.ToolbarButtonTooltip")

	return e(ContextProvider, {
		plugin = plugin,
	}, {
		HoudiniToolbar = e(Toolbar, {
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
						icon = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.HoudiniEngineBadge).image,
						onClick = toggleEnabled,
					}),
				}
			end,
		}, {}),

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
			MainView = e(MainView, {})
		}),
	})
end

return MainPlugin
