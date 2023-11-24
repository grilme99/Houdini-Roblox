local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

export type Props = {
	index: number,
	itemName: string,
}

local function ListItem(props: Props)
	local theme = useStudioTheme()

	local backgroundColor = props.index % 2 == 0 and theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		or theme:GetColor(Enum.StudioStyleGuideColor.Titlebar)

	return e("ImageButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
	}, {
        ItemName = e("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = props.itemName,
            FontFace = Font.Regular,
            TextSize = 14,
            TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, {
            Padding = e("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
            }),
        }),
    })
end

return ListItem
