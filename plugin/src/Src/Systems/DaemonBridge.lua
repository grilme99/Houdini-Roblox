--- Acts as a bridge between the plugin and the daemon. Responsible for
--- maintaining state and making requests.

local HttpService = game:GetService("HttpService")

local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local DaemonConnection = require("@Systems/DaemonConnection")
type DaemonConnection = DaemonConnection.DaemonConnection

local DaemonBridge = {}

DaemonBridge.IsConnectionOpen = false
DaemonBridge.Connection = nil :: DaemonConnection?
DaemonBridge.OnConnectionChanged = Signal.new() :: Signal<DaemonConnection?>

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

	local requestSuccess, result = pcall(function()
		return HttpService:RequestAsync({
			Url = baseUrl .. "/connect",
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

	DaemonBridge.Connection = DaemonConnection.new(baseUrl, decodedResult)
	DaemonBridge.IsConnectionOpen = true
	DaemonBridge.OnConnectionChanged:Fire(DaemonBridge.Connection)

	return {
		success = true,
	}
end

function DaemonBridge.CloseConnection()
	if DaemonBridge.Connection then
		DaemonBridge.Connection:close()

		-- TODO: Check if closing was successful before doing this
		DaemonBridge.IsConnectionOpen = false
		DaemonBridge.Connection = nil
		DaemonBridge.OnConnectionChanged:Fire(nil)
	end
end

return DaemonBridge
