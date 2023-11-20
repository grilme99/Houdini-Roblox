local React = require("@Packages/React")

local e = React.createElement

export type Props = React.ElementProps<any> & {
	title: string,
	renderButtons: (toolbar: PluginToolbar) -> any?,
}

local PluginToolbar = React.Component:extend("PluginToolbar")

function PluginToolbar:createToolbar()
	local props = self.props
	local plugin = props.plugin
	local title = props.title

	self.toolbar = plugin:CreateToolbar(title)
end

function PluginToolbar:render()
	if not self.toolbar then
		self:createToolbar()
	end

	local props = self.props
	local renderButtons = props.renderButtons

	local children = renderButtons(self.toolbar)
	if children then
		return e(React.Fragment, {}, children)
	end

	return nil
end

function PluginToolbar:willUnmount()
	if self.toolbar then
		self.toolbar:Destroy()
	end
end

return PluginToolbar :: React.FC<Props>
