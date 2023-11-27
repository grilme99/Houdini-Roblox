local React = require("@Packages/React")

local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem

local FileUtils = require("@Utils/FileUtils")

local useDaemonConnection = require("@Contexts/Daemon").useDaemonConnection

local useContext = React.useContext

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect

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

	sortMode: string,
	setSortMode: (mode: string) -> (),
	sortTarget: string,
	setSortTarget: (target: string) -> (),

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

	sortMode = "asc",
	setSortMode = noop,
	sortTarget = "displayName",
	setSortTarget = noop,

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

local function Provider(props: React.ElementProps<any>)
	local daemonConnection = useDaemonConnection()

	local rootDir, setRootDir = useState({})
	local currentDirId, setCurrentDirId = useState("{ROOT}")
	local selectedFileId: string?, setSelectedFileId = useState(nil :: string?)
	local renamingFileId: string?, setRenamingFileId = useState(nil :: string?)

	local navigationStack, setNavigationStack = useState({ "{ROOT}" } :: Array<string>)
	local navigationIndex, setNavigationIndex = useState(1)

	local sortMode, setSortMode = useState("asc")
	local sortTarget, setSortTarget = useState("displayName")

	local function refresh()
		if daemonConnection then
			task.spawn(function()
				local rootDir = daemonConnection:listFiles()
				setRootDir(rootDir)
			end)
		else
			warn("Tried to refresh, but no daemon connection was available")
		end
	end

	useEffect(refresh, { daemonConnection })

	return e(FileSystemContext.Provider, {
		value = {
			currentDirId = currentDirId,
			selectedFileId = selectedFileId,
			renamingFileId = renamingFileId,
			rootDir = rootDir,

			navigationStack = navigationStack,
			navigationIndex = navigationIndex,
			goForward = function()
				if navigationIndex < #navigationStack then
					setNavigationIndex(navigationIndex + 1)
					setCurrentDirId(navigationStack[navigationIndex + 1])
				end
			end,
			goBack = function()
				if navigationIndex > 0 then
					setNavigationIndex(navigationIndex - 1)
					setCurrentDirId(navigationStack[navigationIndex - 1])
				end
			end,

			sortMode = sortMode,
			setSortMode = setSortMode,
			sortTarget = sortTarget,
			setSortTarget = setSortTarget,

			refresh = refresh,
			openAssetImport = function()
				if daemonConnection then
					task.spawn(function()
						local dirId = if currentDirId == "{ROOT}" then "" else currentDirId
						local path = FileUtils.BuildFilePath(rootDir, dirId)
						daemonConnection:openAssetPrompt(path)
						refresh()
					end)
				else
					warn("Tried to open asset import, but no daemon connection was available")
				end
			end,
			setFileName = function(fileId: string, newName: string)
				if daemonConnection then
					task.spawn(function()
						local filePath = FileUtils.BuildFilePath(rootDir, fileId)
						daemonConnection:renameFile(filePath, newName)
						refresh()
					end)
				else
					warn("Tried to rename file, but no daemon connection was available")
				end
			end,

			createFolder = function(dirId: string, name: string)
				if daemonConnection then
					task.spawn(function()
						local path = FileUtils.BuildFilePath(rootDir, dirId)
						local newFolderId = daemonConnection:createFolder(path, name)

						refresh()
						if newFolderId then
							setSelectedFileId(newFolderId)
							setRenamingFileId(newFolderId)
						end
					end)
				else
					warn("Tried to create folder, but no daemon connection was available")
				end
			end,

			selectFile = setSelectedFileId,
			setCurrentDir = function(dirId: string)
				setCurrentDirId(dirId)
				setSelectedFileId(nil)

				setNavigationStack(function(navigationStack_)
					local navigationStack = table.clone(navigationStack_)

					if navigationIndex < #navigationStack then
						-- Remove all items after the current index
						for i = #navigationStack, navigationIndex + 1, -1 do
							table.remove(navigationStack, i)
						end
					end

					-- Add the new directory to the stack
					table.insert(navigationStack, dirId)
					setNavigationIndex(#navigationStack)

					return navigationStack
				end)
			end,
			setRenamingFileId = setRenamingFileId,

			deleteFile = function(fileId: string)
				if daemonConnection then
					task.spawn(function()
						local filePath = FileUtils.BuildFilePath(rootDir, fileId)
						if filePath == "{ROOT}" then
							warn("Cannot delete root directory")
							return
						end

						daemonConnection:deleteFile(filePath)
						refresh()
					end)
				else
					warn("Tried to delete file, but no daemon connection was available")
				end
			end,
		},
	}, props.children)
end
FileSystem.Provider = Provider

local function useFileSystem(): FileSystemContext
	return useContext(FileSystemContext)
end
FileSystem.useFileSystem = useFileSystem

return FileSystem
