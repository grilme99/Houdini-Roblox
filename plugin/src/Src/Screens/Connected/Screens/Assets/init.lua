local React = require("@Packages/React")

local Topbar = require("@Src/Screens/Connected/Screens/Assets/Topbar")

local e = React.createElement

local function AssetsScreen()
	return e(React.Fragment, {}, {
		Topbar = e(Topbar, {}),
	})
end

return AssetsScreen
