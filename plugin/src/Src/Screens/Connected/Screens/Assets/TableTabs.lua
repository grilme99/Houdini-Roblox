local React = require("@Packages/React")

local useContext = React.useContext

export type TableTabs = {
	tabs: {
		name: number,
		dateModified: number,
		kind: number,
	},
	resizeTab: (tabName: string, size: number) -> (),
}

local DEFAULT: TableTabs = {
	tabs = {
		name = 0,
		dateModified = 0,
		kind = 0,
	},
	resizeTab = function() end,
}

local TableTables = {}

local TableTabsContext = React.createContext(DEFAULT)
TableTables.Provider = TableTabsContext.Provider

local function useTableTabs(): TableTabs
	return useContext(TableTabsContext)
end
TableTables.useTableTabs = useTableTabs

return TableTables
