local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement
local useRef = React.useRef

export type Props = {
	position: UDim2,
	size: Vector2,
	name: string,
	placeholderValue: string,
	centerText: boolean,
    acceptInput: (value: string) -> boolean,
    onChange: (value: string) -> (),
}

local function FormGroup(props: Props)
	local position = props.position
	local size = props.size
	local name = props.name
	local placeholderValue = props.placeholderValue
	local centerText = props.centerText
    local acceptInput = props.acceptInput
    local onChange = props.onChange
    
	local theme = useStudioTheme()
    local currentText = useRef("")

	return e("Frame", {
		Position = position,
		Size = UDim2.new(size.X, size.Y, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		ListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),

		GroupName = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
			TextSize = 16,
			FontFace = Font.SemiBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = 1,
		}, {
			Padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 6),
			}),
		}),

		InputField = e("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),

			Stroke = e("UIStroke", {
				Color = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
				Thickness = 1,
			}),

			Text = e("TextBox", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				FontFace = Font.Regular,
				PlaceholderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
				PlaceholderText = placeholderValue,
				Text = "",
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				TextSize = 18,
				ClipsDescendants = true,
				TextXAlignment = if centerText then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left,
                [ReactRoblox.Change.Text] = function(rbx: TextBox)
                    local text = rbx.Text
                    if acceptInput(text) then
                        currentText.current = text
                        onChange(if text == "" then placeholderValue else text)
                    else
                        rbx.Text = currentText.current or ""
                    end
                end,
			}, {
				Padding = not centerText and e("UIPadding", {
					PaddingLeft = UDim.new(0, 12),
				}),
			}),
		}),
	})
end

return FormGroup
