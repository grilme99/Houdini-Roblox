local TextService = game:GetService("TextService")

local React = require("@Packages/React")

local useState = React.useState
local useEffect = React.useEffect

local function useTextBounds(text: string, font: Font, textSize: number, width: number?): Vector2
	local textBounds, setTextBounds = useState(Vector2.zero)

	useEffect(function()
		local params = Instance.new("GetTextBoundsParams")
		params.Text = text
		params.Font = font
		params.Size = textSize
		if width then
			params.Width = width
		end

		local thread = task.spawn(function()
			local bounds = TextService:GetTextBoundsAsync(params)
			setTextBounds(bounds)
		end)

		return function()
			task.cancel(thread)
		end
	end, { text, font, textSize, width } :: { any })

	return textBounds
end

return useTextBounds
