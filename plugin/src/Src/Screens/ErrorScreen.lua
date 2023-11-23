local React = require("@Packages/React")

local ReactNavigation = require("@Vendor/ReactNavigation/init")
local useNavigation = ReactNavigation.useNavigation

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local Button = require("@Components/Studio/Button")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useWidgetDimensions = require("@Contexts/WidgetDimensions").useWidgetDimensions
local useI18n = require("@Hooks/useI18n")

local e = React.createElement

local function ErrorScreen()
	local navigation = useNavigation()
	local theme = useStudioTheme()
	local widgetDimensions = useWidgetDimensions()

	local errorMessage = navigation.getParam("errorMessage", "An unknown error occurred")

	local okayText = useI18n("Misc.Okay")

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		BorderSizePixel = 0,
	}, {
		Content = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -48, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			ListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 12),
			}),

			SizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(620, widgetDimensions.Y - (48 * 2)),
			}),

			MessageBox = e("TextLabel", {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
				Text = errorMessage,
				TextWrapped = true,
				TextSize = 18,
				FontFace = Font.SemiBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.BrightText),
				LayoutOrder = 1,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),

				Stroke = e("UIStroke", {
					Color = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = 1,
				}),

				Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 12),
					PaddingBottom = UDim.new(0, 12),
				}),
			}),

			BackButton = e(Button, {
				text = okayText,
				primaryButton = false,
				disabled = false,
				loading = false,
				layoutOrder = 2,
				onClick = function()
					navigation.goBack()
				end,
			}, {}),
		}),
	})
end

return ErrorScreen
