local React = require("@Packages/React")
local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local useEffect = React.useEffect

type Array<T> = { T }

local function useSignal<T...>(signal: Signal<T...>, cb: (T...) -> (), deps: Array<any>?)
	useEffect(function()
		local connection = signal:Connect(cb)
		return function()
			connection:Disconnect()
		end
	end, deps or {})
end

return useSignal
