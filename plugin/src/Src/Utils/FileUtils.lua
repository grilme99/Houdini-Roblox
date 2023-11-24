local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem
type FolderFile = HttpTypes.FolderFile
type File = HttpTypes.File

type Array<T> = { T }

local FileUtils = {}

-- Update this recursive function to populate the parents array once the file is found
function FileUtils.IdToFileRecursive(
	fs: FileSystem,
	id: string,
	parents_: Array<FolderFile>?
): (File?, Array<FolderFile>)
	for _, file in fs do
		if file.id == id then
			return file, parents_ or {}
		end

		if file.type == "Folder" and file.children then
			local parents = if parents_ then table.clone(parents_) else {}
			table.insert(parents, file)

			for _, child in file.children do
				local result, resultParents = FileUtils.IdToFileRecursive({ child }, id, parents)
				if result then
					return result, resultParents
				end
			end
		end
	end

	return nil, parents_ or {}
end

return FileUtils
