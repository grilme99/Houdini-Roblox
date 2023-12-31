local Otter = require(script.Parent.Otter)
local useAnimatedBinding = require(script.useAnimatedBinding)
local useMotor = require(script.useMotor)

export type Goal = Otter.Goal<any>
export type SpringOptions = Otter.SpringOptions
export type SetGoal<V> = useMotor.SetGoal<V>

return {
	useAnimatedBinding = useAnimatedBinding,
	useMotor = useMotor,
	spring = Otter.spring,
	instant = Otter.instant,
}
