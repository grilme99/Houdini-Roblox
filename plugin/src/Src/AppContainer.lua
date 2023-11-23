local React = require("@Packages/React")
local ReactNavigation = require("@Vendor/ReactNavigation/init")

local PluginConstants = require("@Src/PluginConstants")
local RootScreen = PluginConstants.RootScreen

local useDaemonState = require("@Contexts/Daemon").useDaemonState

local ConnectScreen = require("@Src/Screens/Connect/init")
local SettingsScreen = require("@Src/Screens/Settings/init")

local e = React.createElement

local function AppContainer(props: React.ElementProps<any>)
	local daemonState = useDaemonState()

	local rootNavigator = ReactNavigation.createRobloxStackNavigator({
		{ [RootScreen.Connect] = ConnectScreen },
		{ [RootScreen.Settings] = SettingsScreen },
	}, {
		initialRouteName = if daemonState.isConnected then RootScreen.Connected else RootScreen.Connect,
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
