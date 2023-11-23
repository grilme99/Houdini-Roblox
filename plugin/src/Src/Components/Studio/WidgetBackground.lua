local React = require("@Packages/React")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

local function WidgetBackground(props: React.ElementProps<any>)
	local theme = useStudioTheme()

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, props.children)
end

return WidgetBackground
