local React = require("@Packages/React")

local TarmacAssetUtils = require("@Src/TarmacAssetUtils")
type TarmacAsset = TarmacAssetUtils.TarmacAsset

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement
local useState = React.useState
local useMemo = React.useMemo

export type Props = {
	anchorPoint: Vector2?,
	position: UDim2?,
	icon: TarmacAsset,
	iconSize: Vector2,
	innerPadding: Vector2?,
	imageOffset: Vector2?,
	layoutOrder: number?,
	onClick: () -> (),
	disabled: boolean?,
	dimmedIcon: boolean?,
}

local function HeaderButton(props: Props)
	local anchorPoint = props.anchorPoint
	local position = props.position
	local icon = props.icon
	local iconSize = props.iconSize
	local innerPadding = props.innerPadding or Vector2.new(12, 10)
	local imageOffset = props.imageOffset or Vector2.zero
	local layoutOrder = props.layoutOrder
	local onClick = props.onClick
	local disabled = props.disabled or false
	local dimmedIcon = props.dimmedIcon or false

	local theme = useStudioTheme()

	local resolvedIcon = useMemo(function()
		return TarmacAssetUtils.ResolveTarmacAsset(icon)
	end, { icon })

	local defaultColor = theme:GetColor(Enum.StudioStyleGuideColor.Button)
	local colorHover = theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Hover)
	local colorPressed = theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Pressed)

	local isHovered, setIsHovered = useState(false)
	local isPressed, setIsPressed = useState(false)

	local backgroundColor = if isPressed then colorPressed elseif isHovered then colorHover else defaultColor

	return e("ImageButton", {
		AnchorPoint = anchorPoint,
		Position = position,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = backgroundColor,
		Active = not disabled,
		BackgroundTransparency = if disabled then 1 elseif isHovered or isPressed then 0 else 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		[React.Event.Activated] = onClick,
		[React.Event.MouseEnter] = function()
			setIsHovered(true)
		end,
		[React.Event.MouseLeave] = function()
			setIsHovered(false)
		end,
		[React.Event.MouseButton1Down] = function()
			setIsPressed(true)
		end,
		[React.Event.MouseButton1Up] = function()
			setIsPressed(false)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, innerPadding.X),
			PaddingRight = UDim.new(0, innerPadding.X),
			PaddingTop = UDim.new(0, innerPadding.Y),
			PaddingBottom = UDim.new(0, innerPadding.Y),
		}),

		ImageContainer = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(iconSize.X, iconSize.Y),
			BackgroundTransparency = 1,
		}, {
			Icon = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, imageOffset.X, 0.5, imageOffset.Y),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = resolvedIcon.Image,
				ImageRectOffset = resolvedIcon.ImageRectOffset,
				ImageRectSize = resolvedIcon.ImageRectSize,
				ImageColor3 = theme:GetColor(
					dimmedIcon and Enum.StudioStyleGuideColor.SubText or Enum.StudioStyleGuideColor.ButtonText,
					disabled and Enum.StudioStyleGuideModifier.Disabled or nil
				),
			}),
		}),
	})
end

return HeaderButton
