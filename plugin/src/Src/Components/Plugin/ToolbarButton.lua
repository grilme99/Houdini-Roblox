local React = require("@Packages/React")

export type Props = React.ElementProps<any> & {
	--- The text which displays below the button
	title: string,
	--- The toolbar instance to insert this PluginButton into
	toolbar: PluginToolbar,
	--- A callback for when the button was clicked
	onClick: () -> (),

	--- The unique (within the plugin) non-localized id for the button. Falls back to Title if this is nil
	id: string?,
	--- The button's icon image
	icon: string?,
	--- The tooltip display text when the user hovers their mouse over the button
	tooltip: string?,
	--- Whether the button is currently highlighted to show that it is in an active state
	active: boolean?,
	--- Whether the button is interactive
	enabled: boolean?,
	--- Whether the button is enabled when the main window is not active
	clickableWhenViewportHidden: boolean?,
}

local ToolbarButton = React.Component:extend("ToolbarButton")

function ToolbarButton:createButton()
	local props = self.props
	local toolbar = props.toolbar
	local title = props.title
	local id = props.id or title
	local tooltip = props.tooltip or ""
	local icon = props.icon or ""
	local onClick = props.onClick

	self.button = toolbar:CreateButton(id, tooltip, icon, title)

	self.button.ClickableWhenViewportHidden = (props.clickableWhenViewportHidden == nil) and true
		or props.clickableWhenViewportHidden

	self.button.Click:Connect(function()
		onClick()

		-- We need to call this here because when the user clicks a button,
		-- the engine automagically toggles the activate state of the
		-- button. This call will force the activated state back to what our
		-- props specify it should be.
		-- The case where this matters is one-shot action buttons which have
		-- the active prop hardcoded to false. These should not become
		-- activated after being clicked.
		self:updateButton()
	end)
end

function ToolbarButton:updateButton()
	local props = self.props
	local enabled = props.enabled
	local active = props.active
	self.button:SetActive(active)
	if enabled ~= nil then
		self.button.Enabled = enabled
	end
	local icon = props.icon or ""
	if icon ~= self.button.Icon then
		self.button.Icon = icon
	end
end

function ToolbarButton:didMount()
	self:updateButton()
end

function ToolbarButton:didUpdate()
	self:updateButton()
end

function ToolbarButton:render()
	if not self.button then
		self:createButton()
	end
end

function ToolbarButton:willUnmount()
	if self.button then
		self.button:Destroy()
	end
end

return ToolbarButton :: React.FC<Props>
