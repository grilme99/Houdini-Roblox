--- Acts as a bridge between the plugin and the daemon. Responsible for
--- maintaining state and making requests.

local HttpService = game:GetService("HttpService")

local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

export type Connection = {
    sessionId: string,
}

local DaemonBridge = {}

DaemonBridge.IsConnectionOpen = false
DaemonBridge.Connection = nil :: Connection?
DaemonBridge.OnConnectionChanged = Signal.new() :: Signal<boolean>

export type OpenConnectionResult = {
    success: boolean,
    error: string?,
}

function DaemonBridge.OpenConnection(address: string, port: number): OpenConnectionResult
    if DaemonBridge.IsConnectionOpen then
        return {
            success = false,
            error = "Connection already open",
        }
    end

    local baseUrl = string.format("http://%s:%d", address, port)
    local url = string.format("%s/connect", baseUrl)

    local requestSuccess, result = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "POST",
        })
    end)

    if not requestSuccess then
        return {
            success = false,
            error = result,
        }
    end

    local decodeSuccess, decodedResult = pcall(function()
        return HttpService:JSONDecode(result.Body)
    end)

    if not decodeSuccess then
        return {
            success = false,
            error = decodedResult,
        }
    end

    local sessionId = decodedResult.id
    DaemonBridge.Connection = {
        sessionId = sessionId,
    }

    DaemonBridge.IsConnectionOpen = true
    DaemonBridge.OnConnectionChanged:Fire(true)

    return {
        success = true,
    }
end

function DaemonBridge.CloseConnection() end

return DaemonBridge
