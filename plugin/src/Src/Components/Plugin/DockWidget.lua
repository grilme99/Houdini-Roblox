local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local WidgetDimensions = require("@Contexts/WidgetDimensions")

local e = React.createElement

local expectsRestoredMessage = [[
DockWidget expects an OnWidgetRestored function if ShouldRestore is true.
This DockWidget may restore as enabled, so we need to listen for that!]]

export type Props = React.ElementProps<any> & {
	title: string,
	enabled: boolean,
	size: Vector2,
	initialDockState: Enum.InitialDockState,
	onClose: () -> (),
	plugin: Plugin,

	id: string?,
	minSize: Vector2?,
	zIndexBehavior: Enum.ZIndexBehavior?,
	shouldRestore: boolean?,
	onWidgetRestored: ((enabledState: boolean) -> ())?,
	onWidgetCreated: ((enabledState: boolean) -> ())?,
	createWidgetImmediately: boolean?,
}

local DockWidget = React.Component:extend("DockWidget")

function DockWidget:init()
	self.state = {}
end

function DockWidget:createWidget()
	local props = self.props
	local title = props.title
	local onClose = props.onClose

	local plugin = props.plugin
	local minSize = props.minSize or Vector2.new(0, 0)
	local shouldRestore = props.shouldRestore or false
	local pluginId = props.id or props.title

	if shouldRestore then
		assert(props.onWidgetRestored, expectsRestoredMessage)
	end

	local disregardRestoredEnabledState = not shouldRestore

	local info = DockWidgetPluginGuiInfo.new(
		props.initialDockState,
		props.enabled or false,
		disregardRestoredEnabledState,
		props.size.X,
		props.size.Y,
		minSize.X,
		minSize.Y
	)

	local widget: DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui(pluginId, info)

	assert(onClose, "PluginWidget expects an OnClose function.")

	-- createWidgetFunc can yield, so check we're still alive before continuing
	if not self.isMounted then
		widget:Destroy()
		return
	end

	widget.Name = title or ""
	widget.ZIndexBehavior = props.zIndexBehavior or Enum.ZIndexBehavior.Sibling

	if widget:IsA("PluginGui") then
		widget:BindToClose(onClose)

		if self.props.onWidgetFocused then
			self.windowFocusedConnection = widget.WindowFocused:Connect(function()
				self.props.onWidgetFocused(self.widget)
			end)
		end

		if self.props.onWidgetFocusReleased then
			self.windowFocusReleasedConnection = widget.WindowFocusReleased:Connect(function()
				self.props.onWidgetFocusReleased(self.widget)
			end)
		end

		-- plugin:CreateDockWidgetPluginGui() blocks until after restore logic has ran
		-- By the time Lua thread resumes, HostWidgetWasRestored has been set and is safe to use
		if widget:IsA("DockWidgetPluginGui") and widget.HostWidgetWasRestored and props.onWidgetRestored then
			props.onWidgetRestored(widget.Enabled)
		end

		if widget:IsA("DockWidgetPluginGui") and props.onWidgetCreated then
			props.onWidgetCreated(widget.Enabled, widget.HostWidgetWasRestored)
		end
	end

	-- Connect to enabled changing *after* restore
	-- Otherwise users of this will get 2 enabled changes: one from the onRestore, and the same from Roact.Change.Enabled
	self.widgetEnabledChangedConnection = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		local callback = self.props[ReactRoblox.Change.Enabled]
		if callback and self.widget and self.widget.Enabled ~= self.props.enabled then
			callback(self.widget)
		end
	end)

	self.state.widgetSize = widget.AbsoluteSize
	self.widgetSizeChangedConnection = widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:setState({
			widgetSize = widget.AbsoluteSize,
		})
	end)

	self.widget = widget

	-- Force a rerender now that we have the widget
	self:setState({
		_widgetReady = true,
	})
end

function DockWidget:didMount()
	self.isMounted = true

	if self.props.createWidgetImmediately then
		self:createWidget()
	else
		task.spawn(function()
			self:createWidget()
		end)
	end
end

function DockWidget:didUpdate()
	local props = self.props
	local enabled = props.enabled
	local title = props.title

	local widget = self.widget
	if widget then
		if enabled ~= nil then
			widget.Enabled = enabled
		end

		if title ~= nil and widget:IsA("PluginGui") then
			widget.Title = title
		end
	end
end

function DockWidget:render()
	if not self.widget then
		-- Nothing we can do until the widget is ready to use
		return nil
	end

	return ReactRoblox.createPortal(
		e(WidgetDimensions.Provider, {
			value = self.state.widgetSize,
		}, self.props.children),
		self.widget
	)
end

function DockWidget:willUnmount()
	self.isMounted = false

	if self.widgetEnabledChangedConnection then
		self.widgetEnabledChangedConnection:Disconnect()
		self.widgetEnabledChangedConnection = nil
	end

	if self.widgetSizeChangedConnection then
		self.widgetSizeChangedConnection:Disconnect()
		self.widgetSizeChangedConnection = nil
	end

	if self.windowFocusReleasedConnection then
		self.windowFocusReleasedConnection:Disconnect()
		self.windowFocusReleasedConnection = nil
	end

	if self.windowFocusedConnection then
		self.windowFocusedConnection:Disconnect()
		self.windowFocusedConnection = nil
	end

	if self.widget then
		self.widget:Destroy()
		self.widget = nil
	end
end

return DockWidget :: React.FC<Props>
