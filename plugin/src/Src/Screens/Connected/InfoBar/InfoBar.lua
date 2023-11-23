local React = require("@Packages/React")
local ReactSpring = require("@Packages/ReactSpring")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme

local e = React.createElement
local useSpring = ReactSpring.useSpring

local function InfoBar()
	local theme = useStudioTheme()

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

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
		BorderSizePixel = 0,
	}, {
		Border = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
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
			Text = "Connected to bridge",
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return InfoBar
