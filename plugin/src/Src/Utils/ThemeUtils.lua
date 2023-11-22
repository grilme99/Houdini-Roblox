local ThemeUtils = {}

function ThemeUtils.IsDarkerTheme(theme: StudioTheme): boolean
	-- Assume "darker" theme if the average main background colour is darker
	local mainColour = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	return (mainColour.R + mainColour.G + mainColour.B) / 3 < 0.5
end

return ThemeUtils
