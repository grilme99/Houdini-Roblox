local React = require("@Packages/React")

local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")
local ResolveTarmacAsset = TarmacAssetUtils.ResolveTarmacAsset

local HapiLogoDark = ResolveTarmacAsset(TarmacAssets.ConnectScreen.HapiLogo_Dark)
local HapiLogoLight = ResolveTarmacAsset(TarmacAssets.ConnectScreen.HapiLogo_Light)

local ThemeUtils = require("@Utils/ThemeUtils")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local FormGroup = require("@Src/Screens/Connect/Screens/Form/FormGroup")
local Button = require("@Src/Screens/Connect/Screens/Form/Button")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useTextBounds = require("@Hooks/useTextBounds")

local e = React.createElement
local useState = React.useState

local DEFAULT_ADDRESS = "localhost"
local DEFAULT_PORT = "37246"

local function FormScreen()
	local theme = useStudioTheme()
	local isDark = ThemeUtils.IsDarkerTheme(theme)

	local portTextWidget = useTextBounds("00000", Font.Regular, 18).X
	local portWidth = portTextWidget + (14 * 2)
	local groupPadding = 8

	local logoImage = if isDark then HapiLogoLight else HapiLogoDark

	local address, setAddress = useState(DEFAULT_ADDRESS)
	local port, setPort = useState(DEFAULT_PORT)

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
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 28),
			}),

			Logo = e("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				ListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 14),
				}),

				LogoImage = e("ImageLabel", {
					Size = UDim2.fromOffset(154, 26),
					BackgroundTransparency = 1,
					Image = logoImage.Image,
					ImageRectOffset = logoImage.ImageRectOffset,
					ImageRectSize = logoImage.ImageRectSize,
					LayoutOrder = 1,
				}),

				Version = e("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					FontFace = Font.Regular,
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
					TextSize = 18,
					Text = "1.0.0",
					LayoutOrder = 2,
				}, {
					Padding = e("UIPadding", {
						PaddingTop = UDim.new(0, 6),
					}),
				}),
			}),

			Form = e("Frame", {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				ListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 12),
				}),

				FormInputs = e("Frame", {
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 1,
				}, {
					Address = e(FormGroup, {
						position = UDim2.fromScale(0, 0),
						size = Vector2.new(1, -(portWidth + groupPadding)),
						name = "Address",
						placeholderValue = DEFAULT_ADDRESS,
						centerText = false,
						acceptInput = function(text)
							-- Only accept letters, numbers, and periods
							return text:match("^[%w%.]*$") ~= nil
						end,
						onChange = function(text)
							setAddress(text)
						end,
					}),

					Port = e(FormGroup, {
						position = UDim2.new(1, -portWidth, 0, 0),
						size = Vector2.new(0, portWidth),
						name = "Port",
						placeholderValue = DEFAULT_PORT,
						centerText = true,
						acceptInput = function(text)
							-- Only accept numbers
							-- Clamp to 5 characters
							return text:match("^%d*$") ~= nil and #text <= 5
						end,
						onChange = function(text)
							setPort(text)
						end,
					}),
				}),

				Buttons = e("Frame", {
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
				}, {
					ListLayout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),

					Connect = e(Button, {
						text = "Connect",
						primaryButton = true,
						disabled = address == "" or port == "",
						loading = false,
						onClick = function()
							print("Connect")
						end,
					}),

					Settings = e(Button, {
						text = "Settings",
						primaryButton = false,
						disabled = false,
						loading = false,
						onClick = function()
							print("Settings")
						end,
					}),
				}),
			}),
		}),
	})
end

return FormScreen
