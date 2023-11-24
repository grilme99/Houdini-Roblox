local React = require("@Packages/React")

local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

local SortAsc = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.AssetsScreen.SortAsc)
local SortDesc = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.AssetsScreen.SortDesc)

local TableTabs = require("@Src/Screens/Connected/Screens/Assets/TableTabs")
local useTableTabs = TableTabs.useTableTabs

local StudioTheme = require("@Contexts/StudioTheme")
local useStudioTheme = StudioTheme.useStudioTheme

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local e = React.createElement

type TabProps = {
	index: number,
	name: string,
	size: number,
	innerPadding: number?,
	includeDivider: boolean,
    sort: "asc" | "desc" | nil,
}

local function Tab(props: TabProps)
	local index = props.index
	local name = props.name
	local size = props.size
	local innerPadding = props.innerPadding
	local includeDivider = props.includeDivider
	local sort = props.sort

    local selected = sort ~= nil

    local icon
    if selected then
        icon = if sort == "asc" then SortAsc else SortDesc
    end

	local theme = useStudioTheme()

	return e("TextButton", {
		Size = UDim2.fromScale(size, 1),
		BackgroundTransparency = 1,
		Text = name,
		FontFace = if selected then Font.Bold else Font.Regular,
		TextSize = 16,
		TextColor3 = if selected
			then theme:GetColor(Enum.StudioStyleGuideColor.BrightText)
			else theme:GetColor(Enum.StudioStyleGuideColor.SubText),
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = index,
	}, {
		Padding = innerPadding and e("UIPadding", {
			PaddingLeft = UDim.new(0, innerPadding),
		}),

        Icon = icon and e("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, -1),
            Size = UDim2.fromOffset(10, 6),
            BackgroundTransparency = 1,
            Image = icon.Image,
            ImageRectOffset = icon.ImageRectOffset,
            ImageRectSize = icon.ImageRectSize,
            ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
        }),

		Divider = includeDivider and e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.new(0, 1, 1, -8),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
		}),
	})
end

local function TableHeader()
	local tableTabs = useTableTabs()
	local theme = useStudioTheme()

	return e("Frame", {
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
	}, {
		Divider = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			BorderSizePixel = 0,
		}),

		Content = e("Frame", {
			Position = UDim2.fromOffset(40, 0),
			Size = UDim2.new(1, -40, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			Name = e(Tab, {
				index = 1,
				name = "Name",
				size = tableTabs.tabs.name,
				innerPadding = 4,
				includeDivider = true,
                sort = "asc",
			}),

			DateModified = e(Tab, {
				index = 2,
				name = "Date Modified",
				size = tableTabs.tabs.dateModified,
				includeDivider = true,
                sort = nil,
			}),

			Kind = e(Tab, {
				index = 3,
				name = "Kind",
				size = tableTabs.tabs.kind,
				includeDivider = false,
                sort = nil,
			}),
		}),
	})
end

return TableHeader
