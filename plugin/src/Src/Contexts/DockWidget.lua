local React = require("@Packages/React")

local useContext = React.useContext

local DockWidget = {}

local DockWidgetContext = React.createContext(nil :: any)
DockWidget.Provider = DockWidgetContext.Provider

local function useDockWidget(): DockWidgetPluginGui
	return useContext(DockWidgetContext)
end
DockWidget.useDockWidget = useDockWidget

return DockWidget
