--[[
	A hook used to consume the RoactNavigation context.
]]

local Packages = script:FindFirstAncestor("HoudiniEngineForRoblox").Packages
local React = require(Packages.React)
local NavigationContext = require(script.Parent.NavigationContext)

local function useNavigation()
	return React.useContext(NavigationContext)
end

return useNavigation
