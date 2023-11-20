local React = require("@Packages/React")

local PluginContext = require("@Contexts/Plugin")
local DaemonContext = require("@Contexts/Daemon")

local e = React.createElement

export type Props = React.ElementProps<any> & {
	plugin: Plugin,
}

local function ContextProvider(props: Props)
	return e(PluginContext.Provider, {
		value = props.plugin,
	}, {
		DaemonContext = e(DaemonContext.Provider, {}, props.children),
	})
end

return ContextProvider
