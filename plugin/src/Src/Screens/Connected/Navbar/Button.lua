local React = require("@Packages/React")

local ReactNavigation = require("@Vendor/ReactNavigation/init")
local useNavigation = ReactNavigation.useNavigation

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local TarmacAssetUtils = require("@Src/TarmacAssetUtils")
local ThemeUtils = require("@Src/Utils/ThemeUtils")

local useStudioTheme = require("@Src/Contexts/StudioTheme").useStudioTheme

local e = React.createElement
local useState = React.useState

export type Props = {
	index: number,
	icon: TarmacAssetUtils.TarmacAsset,
	iconSize: Vector2,
	text: string,
	displayText: boolean,
	buttonWidth: number,
	routeName: string,
}

local function NavbarButton(props: Props)
	local navigation = useNavigation()

	local index = props.index
	local icon = props.icon
	local iconSize = props.iconSize
	local text = props.text
	local displayText = props.displayText
	local buttonWidth = props.buttonWidth
	local routeName = props.routeName

	local selected = navigation.state.index == index

	local theme = useStudioTheme()
	local isDark = ThemeUtils.IsDarkerTheme(theme)

	local hovering, setHovering = useState(false)

	local borderWidth = 2
	local borderColor = theme:GetColor(Enum.StudioStyleGuideColor.Border)

	local resolvedIcon = TarmacAssetUtils.ResolveTarmacAsset(icon)

	local xPosition = (index - 1) * buttonWidth

	local selectedColor = if isDark then Color3.new(1, 1, 1) else Color3.fromRGB(0, 162, 255)
	local contentColor = if selected or hovering
		then selectedColor
		else theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)

	return e("ImageButton", {
		Position = UDim2.fromOffset(xPosition, 0),
		Size = UDim2.new(0, buttonWidth, 1, 0),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = if selected then 2 else 1,
		[React.Event.Activated] = function()
			navigation.navigate(routeName)
		end,
		[React.Event.MouseEnter] = function()
			setHovering(true)
		end,
		[React.Event.MouseLeave] = function()
			setHovering(false)
		end,
	}, {
		BottomBar = not selected and e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 0, borderWidth),
			BackgroundColor3 = borderColor,
			BorderSizePixel = 0,
		}),

		LeftBar = selected and e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(0, borderWidth, 1, 0),
			BackgroundColor3 = borderColor,
			BorderSizePixel = 0,
		}),

		RightBar = selected and e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.new(0, borderWidth, 1, 0),
			BackgroundColor3 = borderColor,
			BorderSizePixel = 0,
		}),

		TopBar = selected and e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(1, 0, 0, borderWidth),
			BackgroundColor3 = if isDark then Color3.fromRGB(0, 162, 255) else Color3.fromRGB(182, 182, 182),
			BorderSizePixel = 0,
		}),

		ButtonContent = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
			}),

			Icon = e("ImageLabel", {
				Size = UDim2.fromOffset(iconSize.X, iconSize.Y),
				BackgroundTransparency = 1,
				Image = resolvedIcon.Image,
				ImageRectOffset = resolvedIcon.ImageRectOffset,
				ImageRectSize = resolvedIcon.ImageRectSize,
				ImageColor3 = contentColor,
				LayoutOrder = 1,
			}),

			Text = displayText and e("TextLabel", {
				Size = UDim2.fromOffset(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = contentColor,
				TextSize = 16,
				FontFace = if selected then Font.Bold else Font.SemiBold,
				LayoutOrder = 2,
			}),
		}),
	})
end

return NavbarButton
