local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local TarmacAssets = require("@Src/TarmacAssets")
local CaretLeft = TarmacAssets.AssetsScreen.Header.CaretLeft
local CaretRight = TarmacAssets.AssetsScreen.Header.CaretRight
local SearchIcon = TarmacAssets.AssetsScreen.Header.SearchIcon
local DeleteIcon = TarmacAssets.AssetsScreen.Header.DeleteIcon
local AddFolderIcon = TarmacAssets.AssetsScreen.Header.AddFolderIcon
local UploadIcon = TarmacAssets.AssetsScreen.Header.UploadIcon

local FileUtils = require("@Utils/FileUtils")

local HeaderButton = require("@Src/Screens/Connected/Screens/Assets/Header/HeaderButton")

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useFileSystem = require("@Contexts/FileSystem").useFileSystem

local e = React.createElement
local useMemo = React.useMemo

local function ListLayout(props: { padding: UDim, alignment: Enum.HorizontalAlignment? })
	return e("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = props.alignment or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = props.padding,
	})
end

local function Header()
	local theme = useStudioTheme()
	local fileSystem = useFileSystem()

	local canGoForward = fileSystem.navigationIndex < #fileSystem.navigationStack
	local canGoBack = fileSystem.navigationIndex > 1

	local directoryName = useMemo(function()
		if fileSystem.currentDirId == "{ROOT}" then
			return "Home"
		end

		local file = FileUtils.IdToFileRecursive(fileSystem.rootDir, fileSystem.currentDirId)
		if file then
			return file.displayName
		else
			return "{Unknown}"
		end
	end, { fileSystem.currentDirId })

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
		BorderSizePixel = 0,
	}, {
		LeftContent = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
		}, {
			ListLayout = e(ListLayout, {
				padding = UDim.new(0, 10),
			}),

			NavButtons = e("Frame", {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				ListLayout = e(ListLayout, {
					-- Note: needs 1 pixel padding to stop input overlapping
					padding = UDim.new(0, 1),
				}),

				Back = e(HeaderButton, {
					icon = CaretLeft,
					iconSize = Vector2.new(8, 16),
					innerPadding = Vector2.new(16, 10),
					imageOffset = Vector2.new(-1, 0),
					layoutOrder = 1,
					disabled = not canGoBack,
					onClick = function()
						fileSystem.goBack()
					end,
				}),

				Forward = e(HeaderButton, {
					icon = CaretRight,
					innerPadding = Vector2.new(16, 10),
					imageOffset = Vector2.new(1, 0),
					iconSize = Vector2.new(8, 16),
					layoutOrder = 2,
					disabled = not canGoForward,
					onClick = function()
						fileSystem.goForward()
					end,
				}),
			}),

			DirectoryName = e("TextLabel", {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = directoryName,
				TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.BrightText),
				TextSize = 20,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.Bold,
				LayoutOrder = 2,
			}),
		}),

		RightContent = e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
		}, {
			ListLayout = e(ListLayout, {
				padding = UDim.new(0, 4),
				alignment = Enum.HorizontalAlignment.Right,
			}),

			SearchButton = e(HeaderButton, {
				icon = SearchIcon,
				iconSize = Vector2.new(16, 16),
				dimmedIcon = true,
				layoutOrder = 5,
				onClick = function()
					print("Search")
				end,
			}),

			Padding1 = e("Frame", {
				Size = UDim2.fromOffset(10, 0),
				BackgroundTransparency = 1,
				LayoutOrder = 4,
			}),

			UploadButton = e(HeaderButton, {
				icon = UploadIcon,
				iconSize = Vector2.new(16, 16),
				dimmedIcon = true,
				layoutOrder = 3,
				onClick = function()
					fileSystem.openAssetImport()
				end,
			}),

			AddFolderButton = e(HeaderButton, {
				icon = AddFolderIcon,
				iconSize = Vector2.new(18, 16),
				dimmedIcon = true,
				layoutOrder = 2,
				onClick = function()
					fileSystem.createFolder(fileSystem.currentDirId, "New Folder")
				end,
			}),

			DeleteButton = e(HeaderButton, {
				icon = DeleteIcon,
				iconSize = Vector2.new(14, 16),
				dimmedIcon = true,
				layoutOrder = 1,
				disabled = fileSystem.selectedFileId == nil,
				onClick = function()
					if fileSystem.selectedFileId then
						fileSystem.deleteFile(fileSystem.selectedFileId)
					end
				end,
			}),
		}),

		Border = e("Frame", {
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
		}),
	})
end

return Header
