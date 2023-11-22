local React = require("@Packages/React")

local Navbar = require("@Components/App/Navbar/Navbar")
local ConnectScreen = require("@Components/App/ConnectScreen")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useDaemonState = require("@Contexts/Daemon").useDaemonState

local e = React.createElement

local function MainView(): React.Node
	local theme = useStudioTheme()
	local daemonState = useDaemonState()

	if not daemonState.isConnected then
		-- We can't display the app until we're connected to the daemon
		return e(ConnectScreen, {})
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		Navbar = e(Navbar, {}),
	})
end

return MainView
