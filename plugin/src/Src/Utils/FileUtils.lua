local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem
type FolderFile = HttpTypes.FolderFile
type File = HttpTypes.File

type Array<T> = { T }

local FileUtils = {}

function FileUtils.IdToFileRecursive(
	fs: FileSystem,
	id: string,
	parents_: Array<FolderFile>?
): (File?, Array<FolderFile>)
	local parents = parents_ or {}

	for _, file in fs do
		if file.id == id then
			return file, parents
		end

		if file.type == "Folder" and file.children then
			table.insert(parents, file)

			for _, child in file.children do
				local result, resultParents = FileUtils.IdToFileRecursive(child, id, parents)
				if result then
					return result, resultParents
				end
			end
		end
	end

	return nil, parents
end

return FileUtils
