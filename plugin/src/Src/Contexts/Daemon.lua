local React = require("@Packages/React")

local DaemonBridge = require("@Systems/DaemonBridge")
local useSignal = require("@Hooks/useSignal")

local e = React.createElement
local useState = React.useState
local useContext = React.useContext

export type DaemonContext = {
	isConnected: boolean,
}

local DEFAULT: DaemonContext = {
	isConnected = false,
}

local Daemon = {}
local DaemonContext = React.createContext(DEFAULT)

local function Provider(props: React.ElementProps<any>)
	local isConnected, setIsConnected = useState(false)

	useSignal(DaemonBridge.OnConnectionChanged, function(isConnected: boolean)
		setIsConnected(isConnected)
	end)

	local context: DaemonContext = {
		isConnected = isConnected,
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
