local React = require("@Packages/React")

local FileList = require("@Src/Screens/Connected/Screens/Assets/FileList")
local TableHeader = require("@Src/Screens/Connected/Screens/Assets/TableHeader")
local TableTabs = require("@Src/Screens/Connected/Screens/Assets/TableTabs")
local Breadcrumbs = require("@Src/Screens/Connected/Screens/Assets/Breadcrumbs")
local Header = require("@Src/Screens/Connected/Screens/Assets/Header/Header")

local e = React.createElement

type Array<T> = { T }

local function AssetsScreen()
	return e(React.Fragment, {}, {
		Header = e("Frame", {
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Header = e(Header, {}),
		}),

		TableTabs = e(TableTabs.Provider, {
			value = {
				tabs = {
					name = 0.5,
					dateModified = 0.3,
					kind = 0.2,
				},
				resizeTab = function() end,
			},
		}, {
			TableHeader = e(TableHeader, {}),

			ListContainer = e("Frame", {
				Position = UDim2.fromOffset(0, 50 + 24 + 6),
				Size = UDim2.new(1, 0, 1, -(50 + 24 + 24 + 6)),
				BackgroundTransparency = 1,
			}, {
				List = e(FileList, {}),
			}),

			Breadcrumbs = e(Breadcrumbs, {}),
		}),
	})
end

return AssetsScreen
