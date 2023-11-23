local React = require("@Packages/React")

local DaemonBridge = require("@Systems/DaemonBridge")
local DaemonConnection = require("@Systems/DaemonConnection")
type DaemonConnection = DaemonConnection.DaemonConnection

local useSignal = require("@Hooks/useSignal")

local e = React.createElement
local useState = React.useState
local useContext = React.useContext

local NONE = newproxy(false)

local Daemon = {}
local DaemonContext = React.createContext(nil :: any)

local function Provider(props: React.ElementProps<any>)
	local connection: DaemonConnection?, setConnection = useState(nil :: DaemonConnection?)

	useSignal(DaemonBridge.OnConnectionChanged, function(connection)
		setConnection(connection)
	end)

	return e(DaemonContext.Provider, {
		value = connection or NONE,
	}, props.children)
end
Daemon.Provider = Provider

local function useDaemonConnection(): DaemonConnection?
	local connection = useContext(DaemonContext)
	return if connection == NONE then nil else connection
end
Daemon.useDaemonConnection = useDaemonConnection

return Daemon
