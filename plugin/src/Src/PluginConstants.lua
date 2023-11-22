local PluginConstants = {}

PluginConstants.Font = table.freeze({
	Light = Font.fromEnum(Enum.Font.SourceSansLight),
	Regular = Font.fromEnum(Enum.Font.SourceSans),
	SemiBold = Font.fromEnum(Enum.Font.SourceSansSemibold),
	Bold = Font.fromEnum(Enum.Font.SourceSansBold),
})

return PluginConstants