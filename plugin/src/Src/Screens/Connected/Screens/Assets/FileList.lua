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

	local sortMode = fileSystem.sortMode
	local sortTarget = fileSystem.sortTarget

	local directoryChildren: Array<File>
	if fileSystem.currentDirId == "{ROOT}" then
		directoryChildren = fileSystem.rootDir
	else
		local currentDir = assert(FileUtils.IdToFileRecursive(fileSystem.rootDir, fileSystem.currentDirId))
		local meta = currentDir.meta :: FolderFile
		directoryChildren = meta.children or {}
	end

	-- Sort the directory children based on the sort mode and target
	local sortedChildren = table.clone(directoryChildren)
	table.sort(sortedChildren, function(a: any, b: any)
		if sortMode == "asc" then
			return a[sortTarget] < b[sortTarget]
		else
			return a[sortTarget] > b[sortTarget]
		end
	end)

	return e(VirtualizedList.FlatList, {
		data = sortedChildren,
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
