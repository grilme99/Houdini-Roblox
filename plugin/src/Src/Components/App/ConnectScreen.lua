local React = require("@Packages/React")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

local function ConnectScreen()
	local theme = useStudioTheme()

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		Form = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -48, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}),
	})
end

return ConnectScreen
