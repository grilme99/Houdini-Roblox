local React = require("@Packages/React")

local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem

local useContext = React.useContext

type Array<T> = { T }

type FileSystemContext = {
	currentDirId: string,
	selectedFileId: string | nil,
	renamingFileId: string | nil,
	rootDir: FileSystem,

	navigationStack: Array<string>,
	navigationIndex: number,
	goForward: () -> (),
	goBack: () -> (),

	refresh: () -> (),
	openAssetImport: () -> (),
	setCurrentDir: (dirId: string) -> (),

	createFolder: (dirId: string, name: string) -> (),

	selectFile: (fileId: string) -> (),
	setFileName: (fileId: string, newName: string) -> (),
	setRenamingFileId: (fileId: string?) -> (),

	deleteFile: (filePath: string) -> (),
}

local noop = function() end
local DEFAULT: FileSystemContext = {
	currentDirId = "{ROOT}",
	selectedFileId = nil,
	renamingFileId = nil,
	rootDir = {},

	navigationStack = {},
	navigationIndex = 0,
	goForward = noop,
	goBack = noop,

	refresh = noop,
	openAssetImport = noop,
	setCurrentDir = noop,

	createFolder = noop,

	selectFile = noop,
	setFileName = noop,
	setRenamingFileId = noop,

	deleteFile = noop,
}

local FileSystem = {}

local FileSystemContext = React.createContext(DEFAULT)
FileSystem.Provider = FileSystemContext.Provider

local function useFileSystem(): FileSystemContext
	return useContext(FileSystemContext)
end
FileSystem.useFileSystem = useFileSystem

return FileSystem
