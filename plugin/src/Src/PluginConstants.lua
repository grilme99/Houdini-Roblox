local PluginConstants = {}

PluginConstants.Font = table.freeze({
	Light = Font.fromEnum(Enum.Font.SourceSansLight),
	Regular = Font.fromEnum(Enum.Font.SourceSans),
	SemiBold = Font.fromEnum(Enum.Font.SourceSansSemibold),
	Bold = Font.fromEnum(Enum.Font.SourceSansBold),
})

PluginConstants.RootScreen = table.freeze({
	Connect = "Connect",
	Connected = "Connected",
	Settings = "Settings",
	Error = "Error",
})

PluginConstants.ConnectScreens = table.freeze({
	Form = "Connect/Form",
	Error = "Connect/Error",
})

PluginConstants.ConnectedScreens = table.freeze({
	Assets = "Connected/Assets",
	Properties = "Connected/Properties",
	Settings = "Connected/Settings",
})

return PluginConstants
