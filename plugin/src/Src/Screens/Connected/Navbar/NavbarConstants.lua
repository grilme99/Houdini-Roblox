local TarmacAssets = require("@Src/TarmacAssets")

local PluginConstants = require("@Src/PluginConstants")
local ConnectedScreens = PluginConstants.ConnectedScreens

local NavbarConstants = {}

NavbarConstants.Height = 35

NavbarConstants.Buttons = {
	{
		icon = TarmacAssets.Navbar.Assets,
		iconSize = Vector2.new(18, 14),
		text = "Assets",
		routeName = ConnectedScreens.Assets,
	},
	{
		icon = TarmacAssets.Navbar.Properties,
		iconSize = Vector2.new(16, 16),
		text = "Properties",
		routeName = ConnectedScreens.Properties,
	},
	{
		icon = TarmacAssets.Navbar.Settings,
		iconSize = Vector2.new(15, 16),
		text = "Settings",
		routeName = ConnectedScreens.Settings,
	},
}

return NavbarConstants
