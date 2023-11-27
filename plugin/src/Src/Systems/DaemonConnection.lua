local HttpService = game:GetService("HttpService")

local HttpTypes = require("@Types/HttpTypes")
type ConnectionResult = HttpTypes.ConnectionResult

type Map<K, V> = { [K]: V }

type RequestResult = {
	success: boolean,
	result: {
		body: any,
		headers: Map<string, string>,
		statusCode: number,
		statusMessage: string,
	},
}

local DaemonConnection = {}
DaemonConnection.__index = DaemonConnection

function DaemonConnection.new(baseUrl: string, connectionResult: ConnectionResult)
	local self = setmetatable({}, DaemonConnection)

	self.baseUrl = baseUrl
	self.sessionId = connectionResult.id
	self.sessionInfo = connectionResult.sessionInfo

	return self
end

export type DaemonConnection = typeof(DaemonConnection.new(...))

function DaemonConnection._makeRequest(self: DaemonConnection, path: string, body: Map<string, any>?): RequestResult
	local success, result = pcall(function()
		local response = HttpService:RequestAsync({
			Url = self.baseUrl .. path,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["x-session-id"] = self.sessionId,
			},
			Body = HttpService:JSONEncode(body),
		})

		local body = if response.Body == "" then {} else HttpService:JSONDecode(response.Body)

		if response.Success then
			return {
				success = true,
				result = {
					body = body,
					headers = response.Headers,
					statusCode = response.StatusCode,
					statusMessage = response.StatusMessage,
				},
			}
		else
			warn("Failed to make request to " .. path .. ":", response.StatusMessage, "\n", response.Body)

			return {
				success = false,
				result = {
					body = body,
					headers = response.Headers,
					statusCode = response.StatusCode,
					statusMessage = response.StatusMessage,
				},
			}
		end
	end)

	if success then
		return result
	else
		warn("Failed to make request to " .. path .. ":", result)

		return {
			success = false,
			result = {
				body = {},
				headers = {},
				statusCode = 0,
				statusMessage = "Failed to make request",
			},
		}
	end
end

function DaemonConnection.openAssetPrompt(self: DaemonConnection, directory: string)
	if directory == nil or directory == "{ROOT}" then
		directory = ""
	end

	self:_makeRequest("/open-asset", {
		directory = directory,
	})
end

function DaemonConnection.createFolder(self: DaemonConnection, directory: string, displayName: string): string?
	if directory == nil or directory == "{ROOT}" then
		directory = ""
	end

	local response = self:_makeRequest("/create-folder", {
		directory = directory,
		displayName = displayName,
	})

	if response.success then
		return response.result.body.id
	else
		return nil
	end
end

function DaemonConnection.listFiles(self: DaemonConnection): HttpTypes.FileSystem
	local result = self:_makeRequest("/list-files", {})

	if result.success then
		return result.result.body.files
	else
		return {}
	end
end

function DaemonConnection.renameFile(self: DaemonConnection, filePath: string, newName: string)
	self:_makeRequest("/rename-file", {
		path = filePath,
		newName = newName,
	})
end

function DaemonConnection.deleteFile(self: DaemonConnection, filePath: string)
	self:_makeRequest("/delete-file", {
		path = filePath,
	})
end

--- Close the connection to the daemon, ending this session.
function DaemonConnection.close(self: DaemonConnection)
	return self:_makeRequest("/close", {})
end

return DaemonConnection
