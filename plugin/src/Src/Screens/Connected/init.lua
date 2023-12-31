local React = require("@Packages/React")
local ReactErrorBoundary = require("@Packages/ReactErrorBoundary")
local ReactNavigation = require("@Vendor/ReactNavigation/init")

local PluginConstants = require("@Src/PluginConstants")
local ConnectedScreens = PluginConstants.ConnectedScreens

local DaemonBridge = require("@Systems/DaemonBridge")

local FileSystem = require("@Contexts/FileSystem")

local WidgetBackground = require("@Components/Studio/WidgetBackground")

local AssetsScreen = require("@Src/Screens/Connected/Screens/Assets/init")
local PropertiesScreen = require("@Src/Screens/Connected/Screens/Properties/init")
local SettingsScreen = require("@Src/Screens/Connected/Screens/Settings/init")

local Navbar = require("@Src/Screens/Connected/Navbar/Navbar")
local InfoBar = require("@Src/Screens/Connected/InfoBar/InfoBar")

local NavbarConstants = require("@Src/Screens/Connected/Navbar/NavbarConstants")

local e = React.createElement

local ConnectedSwitchNavigator = ReactNavigation.createRobloxSwitchNavigator({
	{ [ConnectedScreens.Assets] = AssetsScreen },
	{ [ConnectedScreens.Properties] = PropertiesScreen },
	{ [ConnectedScreens.Settings] = SettingsScreen },
}, {
	initialRouteName = ConnectedScreens.Assets,
})

local ConnectedScreenNavigator = React.Component:extend("ConnectedScreenNavigator")
ConnectedScreenNavigator.router = ConnectedSwitchNavigator.router

function ConnectedScreenNavigator:render()
	local navigation = self.props.navigation

	local navbarHeight = NavbarConstants.Height
	local infoBarHeight = 28

	return e(ReactErrorBoundary.ErrorBoundary :: any, {
		FallbackComponent = WidgetBackground,
		onError = function(error)
			pcall(DaemonBridge.CloseConnection)
			navigation.navigate(PluginConstants.RootScreen.Error, {
				errorMessage = "An unrecoverable error occurred, and the plugin must be reset. See the console for more details.\n\nError message:\n"
					.. error.message,
			})
		end,
	}, {
		FileSystem = e(FileSystem.Provider, {}, {
			WidgetBackground = e(WidgetBackground, {}, {
				Navbar = e(Navbar, {}),
				InfoBar = e(InfoBar, {}),

				ContentContainer = e("Frame", {
					Position = UDim2.fromOffset(0, navbarHeight),
					Size = UDim2.new(1, 0, 1, -(navbarHeight + infoBarHeight)),
					BackgroundTransparency = 1,
				}, {
					Content = e(ConnectedSwitchNavigator, {
						navigation = navigation,
					}),
				}),
			}),
		}),
	})
end

return ConnectedScreenNavigator
