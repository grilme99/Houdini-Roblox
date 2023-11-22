local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local NavbarConstants = require("@Src/Components/App/Navbar/NavbarConstants")
local NavbarButton = require("@Src/Components/App/Navbar/Button")

local WidgetDimensions = require("@Src/Contexts/WidgetDimensions")
local useWidgetDimensions = WidgetDimensions.useWidgetDimensions

local useTextBounds = require("@Hooks/useTextBounds")

local e = React.createElement

local function Navbar()
	local widgetDimensions = useWidgetDimensions()

	local buttonCount = #NavbarConstants.Buttons
	local buttonWidth = widgetDimensions.X / buttonCount

	local maxTextWidth = 0
	for _, button in NavbarConstants.Buttons do
		-- Calling a hook in a loop is technically illegal, but Buttons are
		-- constant, so the call order won't change between renders.
		maxTextWidth = math.max(maxTextWidth, useTextBounds(button.text, Font.Regular, 16).X)
	end

	local maxIconWidth = 0
	for _, button in NavbarConstants.Buttons do
		local iconSize = button.iconSize
		maxIconWidth = math.max(maxIconWidth, iconSize.X)
	end

	local maxContentWidth = maxTextWidth + maxIconWidth + 12
	local displayText = maxContentWidth < (buttonWidth - 24)

	local buttonChildren = {}
	for index, button in NavbarConstants.Buttons do
		buttonChildren[button.text] = e(NavbarButton, {
			index = index,
			icon = button.icon,
			iconSize = button.iconSize,
			text = button.text,
			displayText = displayText,
			selected = index == 2,
			buttonWidth = buttonWidth,
			onClick = function()
				print("Clicked button")
			end,
		})
	end

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, NavbarConstants.Height),
		BackgroundTransparency = 1,
	}, buttonChildren :: any)
end

return Navbar
