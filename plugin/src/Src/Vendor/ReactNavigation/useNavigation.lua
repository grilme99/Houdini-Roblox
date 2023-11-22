local Packages = script:FindFirstAncestor("HoudiniEngineForRoblox").Packages
local React = require(Packages.React)

local NavigationContext = require(script.Parent.views.NavigationContext)

local function useNavigation(): any
	return React.useContext(NavigationContext)
end

return useNavigation
