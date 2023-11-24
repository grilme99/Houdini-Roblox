local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

export type Props = {
    sectionName: string,
}

local function SectionHeader(props: Props)
    local theme = useStudioTheme()

	return e("TextLabel", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = props.sectionName,
        FontFace = Font.Bold,
        TextSize = 16,
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {
        Padding = e("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
        }),
    })
end

return SectionHeader
