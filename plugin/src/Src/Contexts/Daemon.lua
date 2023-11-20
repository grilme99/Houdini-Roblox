local React = require("@Packages/React")

local DaemonBridge = require("@Systems/DaemonBridge")
local useSignal = require("@Hooks/useSignal")

local e = React.createElement
local useState = React.useState
local useContext = React.useContext

export type DaemonContext = {
	connected: boolean,
}

local DEFAULT: DaemonContext = {
	connected = false,
}

local Daemon = {}
local DaemonContext = React.createContext(DEFAULT)

local function Provider(props: React.ElementProps<any>)
	local connected, setConnected = useState(false)

	useSignal(DaemonBridge.OnConnectionChanged, function(isConnected: boolean)
		setConnected(isConnected)
	end)

	local context: DaemonContext = {
		connected = connected,
	}

	return e(DaemonContext.Provider, {
		value = context,
	}, props.children)
end
Daemon.Provider = Provider

local function useDaemonState(): DaemonContext
	return useContext(DaemonContext)
end
Daemon.useDaemonState = useDaemonState

return Daemon
