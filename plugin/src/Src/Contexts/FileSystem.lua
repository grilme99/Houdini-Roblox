local React = require("@Packages/React")

local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem

local useContext = React.useContext

type FileSystemContext = {
	currentDirId: string,
	selectedFileId: string | nil,
	rootDir: FileSystem,
	refresh: () -> (),
	selectFile: (fileId: string) -> (),
	renameFile: (fileId: string, newName: string) -> (),
	setCurrentDir: (dirId: string) -> (),
}

local noop = function() end
local DEFAULT: FileSystemContext = {
	currentDirId = "{ROOT}",
	selectedFileId = nil,
	rootDir = {},
	refresh = noop,
	selectFile = noop,
	renameFile = noop,
	setCurrentDir = noop,
}

local FileSystem = {}

local FileSystemContext = React.createContext(DEFAULT)
FileSystem.Provider = FileSystemContext.Provider

local function useFileSystem(): FileSystemContext
	return useContext(FileSystemContext)
end
FileSystem.useFileSystem = useFileSystem

return FileSystem
