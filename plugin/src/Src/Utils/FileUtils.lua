local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem
type FolderFile = HttpTypes.FolderFile
type File = HttpTypes.File

type Array<T> = { T }

local FileUtils = {}

-- Update this recursive function to populate the parents array once the file is found
function FileUtils.IdToFileRecursive(fs: FileSystem, id: string, parents_: Array<File>?): (File?, Array<File>)
	for _, file in fs do
		if file.id == id then
			return file, parents_ or {}
		end

		if file.meta.type == "Folder" and file.meta.children then
			local parents = if parents_ then table.clone(parents_) else {}
			table.insert(parents, file)

			for _, child in file.meta.children do
				local result, resultParents = FileUtils.IdToFileRecursive({ child }, id, parents)
				if result then
					return result, resultParents
				end
			end
		end
	end

	return nil, parents_ or {}
end

function FileUtils.BuildFilePath(fs: FileSystem, id: string): string
	local file, parents = FileUtils.IdToFileRecursive(fs, id)
	if file then
		local path = file.id

		for _, parent in parents do
			path = parent.id .. "/" .. path
		end

		return path
	else
		return "{ROOT}"
	end
end

return FileUtils
