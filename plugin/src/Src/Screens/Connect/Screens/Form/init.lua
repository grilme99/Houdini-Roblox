local React = require("@Packages/React")

local ReactNavigation = require("@Vendor/ReactNavigation/init")
local useNavigation = ReactNavigation.useNavigation

local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")
local ResolveTarmacAsset = TarmacAssetUtils.ResolveTarmacAsset

local HapiLogoDark = ResolveTarmacAsset(TarmacAssets.ConnectScreen.HapiLogo_Dark)
local HapiLogoLight = ResolveTarmacAsset(TarmacAssets.ConnectScreen.HapiLogo_Light)

local DaemonBridge = require("@Systems/DaemonBridge")
local ThemeUtils = require("@Utils/ThemeUtils")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local FormGroup = require("@Src/Screens/Connect/Screens/Form/FormGroup")
local Button = require("@Src/Screens/Connect/Screens/Form/Button")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useTextBounds = require("@Hooks/useTextBounds")
local useI18n = require("@Hooks/useI18n")

local e = React.createElement
local useState = React.useState

local DEFAULT_ADDRESS = "localhost"
local DEFAULT_PORT = "37246"

local function FormScreen()
	local navigation = useNavigation()

	local theme = useStudioTheme()
	local isDark = ThemeUtils.IsDarkerTheme(theme)

	local portTextWidget = useTextBounds("00000", Font.Regular, 18).X
	local portWidth = portTextWidget + (14 * 2)
	local groupPadding = 8

	local logoImage = if isDark then HapiLogoLight else HapiLogoDark

	local address, setAddress = useState(DEFAULT_ADDRESS)
	local port, setPort = useState(DEFAULT_PORT)
	local loading, setLoading = useState(false)

	local subheadingText = useI18n("Screen.Connect.Subheading")
	local addressText = useI18n("Screen.Connect.Address")
	local portText = useI18n("Screen.Connect.Port")
	local connectText = useI18n("Screen.Connect.Btn_Connect")
	local settingsText = useI18n("Screen.Connect.Btn_Settings")

	local bridgeNotRunningText = useI18n("Screen.Error.BridgeNotRunning")

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
				Padding = UDim.new(0, 18),
			}),

			SizeConstraint = e("UISizeConstraint", {
				MaxSize = Vector2.new(420, math.huge),
			}),

			Logo = e("Frame", {
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				ListLayout = e("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),

				HorizontalContent = e("Frame", {
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
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

				Subheading = e("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					FontFace = Font.SemiBold,
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
					TextSize = 16,
					Text = subheadingText,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2,
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
						name = addressText,
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
						name = portText,
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
						text = connectText,
						primaryButton = true,
						disabled = address == "" or port == "",
						loading = loading,
						layoutOrder = 2,
						onClick = function()
							local port = tonumber(port) :: number

							setLoading(true)
							local result = DaemonBridge.OpenConnection(address, port)

							if result.success then
								setLoading(false)
								navigation.navigate(PluginConstants.RootScreen.Connected)
							else
								local message = result.error or "An unknown error occurred"
								if string.find(message, "ConnectFail") then
									message = bridgeNotRunningText
								end

								setLoading(false)
								navigation.navigate(PluginConstants.RootScreen.Error, {
									errorMessage = message,
								})
							end
						end,
					}),

					Settings = e(Button, {
						text = settingsText,
						primaryButton = false,
						disabled = loading,
						loading = false,
						layoutOrder = 1,
						onClick = function()
							navigation.navigate(PluginConstants.RootScreen.Settings)
						end,
					}),
				}),
			}),
		}),
	})
end

return FormScreen
