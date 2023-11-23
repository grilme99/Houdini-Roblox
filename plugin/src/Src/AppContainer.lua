local React = require("@Packages/React")
local ReactNavigation = require("@Vendor/ReactNavigation/init")

local PluginConstants = require("@Src/PluginConstants")
local RootScreen = PluginConstants.RootScreen

local ConnectScreen = require("@Src/Screens/Connect/init")
local ConnectedScreen = require("@Src/Screens/Connected/init")
local SettingsScreen = require("@Src/Screens/Settings/init")
local ErrorScreen = require("@Src/Screens/ErrorScreen")

local e = React.createElement

local function AppContainer(props: React.ElementProps<any>)
	local rootNavigator = ReactNavigation.createRobloxStackNavigator({
		{ [RootScreen.Connect] = ConnectScreen },
		{ [RootScreen.Connected] = ConnectedScreen },
		{ [RootScreen.Settings] = SettingsScreen },
		{ [RootScreen.Error] = ErrorScreen },
	}, {
		initialRouteName = RootScreen.Connect,
		transitionConfig = function()
			return {
				transitionSpec = {
					frequency = 6,
				},
			}
		end,
	})

	local AppContainer = ReactNavigation.createAppContainer(rootNavigator)

	return e(AppContainer, {}, props.children)
end

return AppContainer
