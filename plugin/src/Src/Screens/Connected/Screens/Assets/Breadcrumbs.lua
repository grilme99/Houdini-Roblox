local StudioService = game:GetService("StudioService")

local React = require("@Packages/React")

local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

local CaretRight = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.AssetsScreen.Breadcrumbs.CaretRight)

local FileSystem = require("@Contexts/FileSystem")
local useFileSystem = FileSystem.useFileSystem

local FileUtils = require("@Utils/FileUtils")

local StudioTheme = require("@Contexts/StudioTheme")
local useStudioTheme = StudioTheme.useStudioTheme

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local e = React.createElement

type BreadcrumbProps = {
	index: number,
	breadcrumb: string,
	finalItem: boolean,
	fileId: string,
}

local function Breadcrumb(props: BreadcrumbProps)
	local theme = useStudioTheme()
	local fileSystem = useFileSystem()

	local icon = if props.index == 1
		then StudioService:GetClassIcon("Workspace")
		else StudioService:GetClassIcon("Folder")

	local color = if props.finalItem
		then theme:GetColor(Enum.StudioStyleGuideColor.MainText)
		else theme:GetColor(Enum.StudioStyleGuideColor.SubText)

	return e("ImageButton", {
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = props.index,
		[React.Event.Activated] = function()
			fileSystem.setCurrentDir(props.fileId)
		end,
	}, {
		ListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		}),

		Icon = e("ImageLabel", {
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			Image = icon.Image,
			ImageRectOffset = icon.ImageRectOffset,
			ImageRectSize = icon.ImageRectSize,
			LayoutOrder = 1,
		}),

		Name = e("TextLabel", {
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text = props.breadcrumb,
			FontFace = Font.SemiBold,
			TextSize = 16,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 2,
		}, {
			Padding = e("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
			}),
		}),

		Caret = not props.finalItem and e("ImageLabel", {
			Size = UDim2.fromOffset(4, 8),
			BackgroundTransparency = 1,
			Image = CaretRight.Image,
			ImageRectOffset = CaretRight.ImageRectOffset,
			ImageRectSize = CaretRight.ImageRectSize,
			ImageColor3 = color,
			LayoutOrder = 3,
		}),
	})
end

local function TableHeader()
	local theme = useStudioTheme()
	local fileSystem = useFileSystem()

	local currentDir, parents = FileUtils.IdToFileRecursive(fileSystem.rootDir, fileSystem.currentDirId)

	local breadcrumbs = { { name = "Home", id = "{ROOT}" } }
	for _, parent in parents do
		table.insert(breadcrumbs, {
			name = parent.displayName,
			id = parent.id,
		})
	end
	if currentDir then
		table.insert(breadcrumbs, {
			name = currentDir.displayName,
			id = currentDir.id,
		})
	end

	local breadcrumbChildren = {}
	for index, breadcrumb in breadcrumbs do
		breadcrumbChildren["Breadcrumb_" .. index] = e(Breadcrumb, {
			index = index,
			breadcrumb = breadcrumb.name,
			finalItem = index == #breadcrumbs,
			fileId = breadcrumb.id,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
	}, {
		Divider = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
		}),

		Content = e("Frame", {
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -8, 1, 0),
			BackgroundTransparency = 1,
		}, {
			ListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),
		}, breadcrumbChildren :: any),
	})
end

return TableHeader
