local ReactNavigation = require("@Vendor/ReactNavigation/init")

local PluginConstants = require("@Src/PluginConstants")
local ConnectScreens = PluginConstants.ConnectScreens

local FormScreen = require("@Src/Screens/Connect/Screens/Form/init")

local ConnectStackNavigator = ReactNavigation.createRobloxStackNavigator({
    { [ConnectScreens.Form] = FormScreen },
}, {
    initialRouteName = ConnectScreens.Form,
    transitionConfig = function()
        return {
            transitionSpec = {
                frequency = 6,
            },
        }
    end,
})

return ConnectStackNavigator
