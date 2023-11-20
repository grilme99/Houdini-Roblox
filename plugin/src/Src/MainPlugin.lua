local React = require("@Packages/React")

local e = React.createElement

export type Props = {
    plugin: Plugin,
}

local function MainPlugin(props: Props)
    print("aaaa")
    return e(React.Fragment)
end

return MainPlugin
