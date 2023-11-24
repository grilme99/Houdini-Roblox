local React = require("@Packages/React")
local VirtualizedList = require("@Packages/VirtualizedList")

local FileSystem = require("@Contexts/FileSystem")
local useFileSystem = FileSystem.useFileSystem

local FileUtils = require("@Utils/FileUtils")

local ListItem = require("@Src/Screens/Connected/Screens/Assets/ListItem")

local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem
type FolderFile = HttpTypes.FolderFile
type File = HttpTypes.File

local e = React.createElement

type Array<T> = { T }

local function FileList()
	local fileSystem = useFileSystem()

	local directoryChildren: Array<File>
	if fileSystem.currentDirId == "{ROOT}" then
		directoryChildren = fileSystem.rootDir
	else
		local currentDir_ = assert(FileUtils.IdToFileRecursive(fileSystem.rootDir, fileSystem.currentDirId))
		local currentDir = currentDir_ :: FolderFile
		directoryChildren = currentDir.children or {}
	end

	return e(VirtualizedList.FlatList, {
		data = directoryChildren,
		extraData = fileSystem.selectedFileId,
		style = {
			BackgroundTransparency = 1,
		},
		contentContainerStyle = {
			BackgroundTransparency = 1,
		},
		keyExtractor = function(item: File)
			return item.id
		end,
		renderItem = function(data)
			return e(ListItem, {
				index = data.index,
				fileData = data.item,
			})
		end,
	})
end

return FileList
