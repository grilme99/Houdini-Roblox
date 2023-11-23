local React = require("@Packages/React")

local ReactNavigation = require("@Vendor/ReactNavigation/init")
local useNavigation = ReactNavigation.useNavigation

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

local function SettingsScreen()
	local navigation = useNavigation()
	local theme = useStudioTheme()

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		BackButton = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(120, 32),
			Text = "Go Back",
			[React.Event.Activated] = function()
				navigation.goBack()
			end,
		}, {}),
	})
end

return SettingsScreen
