local React = require("@Packages/React")
local ReactSpring = require("@Packages/ReactSpring")

local ReactNavigation = require("@Vendor/ReactNavigation/init")
local useNavigation = ReactNavigation.useNavigation

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local DaemonBridge = require("@Systems/DaemonBridge")

local Button = require("@Components/Studio/Button")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useI18n = require("@Hooks/useI18n")

local e = React.createElement
local useSpring = ReactSpring.useSpring

local function InfoBar()
	local theme = useStudioTheme()
	local navigation = useNavigation()

	local styles = useSpring({
		from = {
			glowTransparency = 0.5,
			glowSize = UDim2.fromOffset(12, 12),
		},
		to = {
			glowTransparency = 1,
			glowSize = UDim2.fromOffset(18, 18),
		},
		config = { duration = 0.6, easing = ReactSpring.easings.easeOutQuad },
		loop = { delay = 3, reset = true } :: any,
	})

    local connectedText = useI18n("Screen.Connected.InfoBar.Connected")
	local disconnectText = useI18n("Screen.Connected.InfoBar.Disconnect")

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
		BorderSizePixel = 0,
	}, {
		Border = e("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
		}),

		IndicatorContainer = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1,
		}, {
			ConnectedIndicator = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(8, 8),
				BackgroundColor3 = Color3.fromHex("#4ade80"),
				BorderSizePixel = 0,
				ZIndex = 2,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),

			Glow = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = styles.glowSize,
				BackgroundTransparency = styles.glowTransparency,
				BackgroundColor3 = Color3.fromHex("#22c55e"),
				BorderSizePixel = 0,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
		}),

		IndicatorLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 28, 0.5, 0),
			Size = UDim2.new(1, -32, 1, 0),
			BackgroundTransparency = 1,
			FontFace = Font.SemiBold,
			Text = connectedText,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		DisconnectButton = e(Button, {
			anchorPoint = Vector2.new(1, 0.5),
			position = UDim2.new(1, -12, 0.5, 0),
			size = UDim2.fromOffset(0, 18),
			internalPadding = Vector2.new(12, 8),
			automaticSize = Enum.AutomaticSize.X,
			textSize = 14,
			text = disconnectText,
			primaryButton = false,
			onClick = function()
				DaemonBridge.CloseConnection()
				navigation.navigate(PluginConstants.RootScreen.Connect)
			end,
		}),
	})
end

return InfoBar
