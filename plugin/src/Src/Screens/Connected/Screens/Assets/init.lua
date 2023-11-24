local React = require("@Packages/React")
local VirtualizedList = require("@Packages/VirtualizedList")

local Topbar = require("@Src/Screens/Connected/Screens/Assets/Topbar")
local SectionHeader = require("@Src/Screens/Connected/Screens/Assets/SectionHeader")
local ListItem = require("@Src/Screens/Connected/Screens/Assets/ListItem")

local e = React.createElement

local ITEMS = {}
for i = 1, 10000 do
	table.insert(ITEMS, {
		name = "Test " .. i,
	})
end

local function AssetsScreen()
	local sections = {
		{
			title = "Today",
			data = {
				{ name = "Test" },
				{ name = "Test" },
				{ name = "Test" },
			},
		},
		{
			title = "1 Day Ago",
			data = {
				{ name = "Test" },
				{ name = "Test" },
				{ name = "Test" },
				{ name = "Test" },
				{ name = "Test" },
			},
		},
		{
			title = "2 Days Ago",
			data = {
				{ name = "Test" },
				{ name = "Test" },
				{ name = "Test" },
			},
		},
		{
			title = "1 Week Ago",
			data = ITEMS,
		},
	}

	return e(React.Fragment, {}, {
		Topbar = e(Topbar, {}),

		ListContainer = e("Frame", {
			Position = UDim2.fromOffset(0, 52),
			Size = UDim2.new(1, 0, 1, -52),
			BackgroundTransparency = 1,
		}, {
			List = e(VirtualizedList.SectionList, {
				sections = sections,
				style = {
					BackgroundTransparency = 1,
				},
				contentContainerStyle = {
					BackgroundTransparency = 1,
				},
				renderSectionHeader = function(data)
					return e(SectionHeader, {
						sectionName = data.section.title,
					})
				end,
				renderItem = function(data)
					return e(ListItem, {
						index = data.index,
						itemName = data.item.name,
					})
				end,
				getItemLayout = function(_data, index: number)
					return {
						length = 32,
						offset = 32 * (index - 1),
						index = index,
					}
				end,
			}),
		}),
	})
end

return AssetsScreen
