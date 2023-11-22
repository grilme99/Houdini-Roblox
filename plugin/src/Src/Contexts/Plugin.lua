local React = require("@Packages/React")

local useContext = React.useContext

local Plugin = {}

local PluginContext = React.createContext(nil :: any)
Plugin.Provider = PluginContext.Provider

local function usePlugin(): Plugin
	return useContext(PluginContext)
end
Plugin.usePlugin = usePlugin

return Plugin
