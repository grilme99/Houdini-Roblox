local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

local Button = require("@Src/Components/Studio/Button")

local SearchIcon = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.Misc.SearchIcon)

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useDaemonConnection = require("@Contexts/Daemon").useDaemonConnection
local useFileSystem = require("@Contexts/FileSystem").useFileSystem

local e = React.createElement
local useState = React.useState

local function Topbar()
	local theme = useStudioTheme()
	local daemonConnection = useDaemonConnection()
	local fileSystem = useFileSystem()

	local hovering, setHovering = useState(false)
	local focused, setFocused = useState(false)

	local innerPadding = 10
	local searchIconSize = 12

	local buttonWidth = 120

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
		BorderSizePixel = 0,
		ZIndex = 2,
	}, {
		SearchBar = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, innerPadding, 0.5, 0),
			Size = UDim2.new(1, -((innerPadding * 2) + buttonWidth + innerPadding), 1, -innerPadding * 2),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),

			Stroke = e("UIStroke", {
				Color = if hovering or focused
					then theme:GetColor(Enum.StudioStyleGuideColor.MainButton)
					else theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
				Thickness = 1,
			}),

			Icon = e("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.fromOffset(searchIconSize, searchIconSize),
				BackgroundTransparency = 1,
				ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
				Image = SearchIcon.Image,
				ImageRectOffset = SearchIcon.ImageRectOffset,
				ImageRectSize = SearchIcon.ImageRectSize,
			}),

			Text = e("TextBox", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				FontFace = Font.Regular,
				PlaceholderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
				PlaceholderText = "Search",
				Text = "",
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
				TextSize = 18,
				ClipsDescendants = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
				[React.Event.MouseEnter] = function()
					setHovering(true)
				end,
				[React.Event.MouseLeave] = function()
					setHovering(false)
				end,
				[React.Event.Focused] = function()
					setFocused(true)
				end,
				[React.Event.FocusLost] = function()
					setFocused(false)
				end,
			}, {
				Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 12 + searchIconSize + 8),
				}),
			}),
		}),

		OpenAssetButton = e(Button, {
			anchorPoint = Vector2.new(1, 0.5),
			position = UDim2.new(1, -innerPadding, 0.5, 0),
			size = UDim2.new(0, buttonWidth, 1, -innerPadding * 2),
			automaticSize = Enum.AutomaticSize.None,
			backgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button),
			borderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
			text = "Open Asset",
			onClick = function()
				if daemonConnection then
					local dirId = if fileSystem.currentDirId == "{ROOT}" then "" else fileSystem.currentDirId
					task.spawn(daemonConnection.openAssetPrompt, daemonConnection, dirId)
				end
			end,
		}),

		Border = e("Frame", {
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
		}),
	})
end

return Topbar
