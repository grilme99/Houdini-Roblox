local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement

export type Props = {
	text: string,
	primaryButton: boolean,
	disabled: boolean,
	loading: boolean,
	onClick: () -> (),
}

local function Button(props: Props)
	local text = props.text
	local primaryButton = props.primaryButton
	local disabled = props.disabled
	local loading = props.loading
	local onClick = props.onClick

    local displayDisabled = disabled or loading

	local theme = useStudioTheme()

	return e("TextButton", {
		AutomaticSize = Enum.AutomaticSize.XY,
        Active = not displayDisabled,
        AutoButtonColor = not displayDisabled,
		Text = text,
		TextSize = 18,
		FontFace = Font.SemiBold,
        BackgroundTransparency = displayDisabled and 0.6 or 0,
        TextTransparency = displayDisabled and 0.2 or 0,
		TextColor3 = primaryButton and theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText)
			or theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonText),
		BackgroundColor3 = primaryButton and theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton)
			or theme:GetColor(Enum.StudioStyleGuideColor.DialogButton),
		BorderSizePixel = 0,
        [React.Event.Activated] = onClick,
	}, {
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 24),
			PaddingRight = UDim.new(0, 24),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
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
