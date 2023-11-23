local React = require("@Packages/React")

local Navbar = require("@Src/Screens/Connected/Navbar/Navbar")
local InfoBar = require("@Src/Screens/Connected/InfoBar/InfoBar")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

local function ConnectedScreen()
	local theme = useStudioTheme()

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		Navbar = e(Navbar, {}),
		InfoBar = e(InfoBar, {}),
	})
end

return ConnectedScreen
