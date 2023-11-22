local React = require("@Packages/React")

local useContext = React.useContext

local WidgetDimensions = {}

local WidgetDimensionsContext = React.createContext(Vector2.zero)
WidgetDimensions.Provider = WidgetDimensionsContext.Provider

local function useWidgetDimensions(): Vector2
	return useContext(WidgetDimensionsContext)
end
WidgetDimensions.useWidgetDimensions = useWidgetDimensions

return WidgetDimensions
