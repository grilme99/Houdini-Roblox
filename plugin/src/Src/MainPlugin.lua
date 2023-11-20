local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local Toolbar = require("@Components/Plugin/Toolbar")
local ToolbarButton = require("@Components/Plugin/ToolbarButton")
local DockWidget = require("@Components/Plugin/DockWidget")

local ContextProvider = require("@Src/ContextProvider")
local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

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

	return e(ContextProvider, {
		plugin = plugin,
	}, {
		HoudiniToolbar = e(Toolbar, {
			plugin = plugin,
			title = "Houdini Engine",
			renderButtons = function(toolbar)
				return {
					Toggle = e(ToolbarButton, {
						plugin = plugin,
						toolbar = toolbar,
						active = enabled,
						title = "Houdini Engine",
						icon = TarmacAssetUtils.resolveTarmacAsset(TarmacAssets.HoudiniEngineBadge).image,
						onClick = toggleEnabled,
					}),
				}
			end,
		}, {}),

		HoudiniWidget = e(DockWidget, {
			plugin = plugin,
			enabled = enabled,
			title = "Houdini Engine",
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
			Frame = e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
			}),
		}),
	})
end

return MainPlugin
