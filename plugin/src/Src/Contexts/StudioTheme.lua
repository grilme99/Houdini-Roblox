local React = require("@Packages/React")

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect
local useContext = React.useContext

local StudioSettings = settings().Studio
local StudioThemeContext = React.createContext(StudioSettings.Theme)

local StudioTheme = {}

local function StudioThemeProvider(props: React.ElementProps<any>)
	local theme, setTheme = useState(StudioSettings.Theme)

	useEffect(function()
		local connection = StudioSettings.ThemeChanged:Connect(function()
			setTheme(StudioSettings.Theme)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return e(StudioThemeContext.Provider, {
		value = theme,
	}, props.children)
end
StudioTheme.Provider = StudioThemeProvider

local function useStudioTheme(): StudioTheme
    return useContext(StudioThemeContext)
end
StudioTheme.useStudioTheme = useStudioTheme

return StudioTheme
