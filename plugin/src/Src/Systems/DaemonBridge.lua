--- Acts as a bridge between the plugin and the daemon. Responsible for
--- maintaining state and making requests.

local HttpService = game:GetService("HttpService")

local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local DaemonBridge = {}

DaemonBridge.IsConnectionOpen = false
DaemonBridge.OnConnectionChanged = Signal.new() :: Signal<boolean>

function DaemonBridge.OpenConnection()
    
end

function DaemonBridge.CloseConnection()
    
end

return DaemonBridge
