_G.__DEV__ = true

local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local MainPlugin = require("@Src/MainPlugin")
local DaemonBridge = require("@Src/Systems/DaemonBridge")

local e = React.createElement

local Main = script.Parent.Parent
local root: ReactRoblox.RootType

local function Init()
    plugin.Name = Main.Name

    local mainPlugin = e(MainPlugin, {
        plugin = plugin,
    })

    root = ReactRoblox.createRoot(Instance.new("Folder"))
    root:render(mainPlugin)
end

plugin.Unloading:Connect(function()
    if DaemonBridge.IsConnectionOpen then
        DaemonBridge.CloseConnection()
    end

    if root then
        root:unmount()
        root = nil :: any
    end
end)

Init()
