local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

export type Props = {
    anchorPoint: Vector2?,
    position: UDim2?,
    size: UDim2?,
    automaticSize: Enum.AutomaticSize?,
	internalPadding: Vector2?,

	text: string,
    textSize: number?,
	primaryButton: boolean?,
	disabled: boolean?,
	loading: boolean?,
	layoutOrder: number?,
	onClick: () -> (),
}

local function Button(props: Props)
    local anchorPoint = props.anchorPoint
    local position = props.position
    local size = props.size
    local automaticSize = props.automaticSize
	local internalPadding = props.internalPadding

	local text = props.text
    local textSize = props.textSize
	local primaryButton = props.primaryButton
	local disabled = props.disabled
	local loading = props.loading
	local layoutOrder = props.layoutOrder
	local onClick = props.onClick

	local xPadding = internalPadding and internalPadding.X or 24
	local yPadding = internalPadding and internalPadding.Y or 8

	local displayDisabled = disabled or loading

	local theme = useStudioTheme()

	return e("TextButton", {
        AnchorPoint = anchorPoint,
        Position = position,
        Size = size,
		AutomaticSize = automaticSize or Enum.AutomaticSize.XY,
		Active = not displayDisabled,
		AutoButtonColor = not displayDisabled,
		Text = text,
		TextSize = textSize or 18,
		FontFace = Font.SemiBold,
		BackgroundTransparency = displayDisabled and 0.6 or 0,
		TextTransparency = displayDisabled and 0.2 or 0,
		TextColor3 = primaryButton and theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText)
			or theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText),
		BackgroundColor3 = primaryButton and theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton)
			or theme:GetColor(Enum.StudioStyleGuideColor.DialogButton),
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		[React.Event.Activated] = onClick,
	}, {
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, xPadding),
			PaddingRight = UDim.new(0, xPadding),
			PaddingTop = UDim.new(0, yPadding),
			PaddingBottom = UDim.new(0, yPadding),
		}),

		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),

		Stroke = not displayDisabled and e("UIStroke", {
			Color = theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonBorder),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,
		}),
	})
end

return Button
