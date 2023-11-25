local React = require("@Packages/React")
local Sift = require("@Packages/Sift")

local FileList = require("@Src/Screens/Connected/Screens/Assets/FileList")
local TableHeader = require("@Src/Screens/Connected/Screens/Assets/TableHeader")
local TableTabs = require("@Src/Screens/Connected/Screens/Assets/TableTabs")
local Breadcrumbs = require("@Src/Screens/Connected/Screens/Assets/Breadcrumbs")
local Header = require("@Src/Screens/Connected/Screens/Assets/Header/Header")

local useDaemonConnection = require("@Contexts/Daemon").useDaemonConnection

local FileSystemContext = require("@Contexts/FileSystem")
local FileUtils = require("@Utils/FileUtils")

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect

local function AssetsScreen()
	local daemonConnection = useDaemonConnection()

	local rootDir, setRootDir = useState({})
	local currentDirId, setCurrentDirId = useState("{ROOT}")
	local selectedFileId: string?, setSelectedFileId = useState(nil :: string?)
	local renamingFileId: string?, setRenamingFileId = useState(nil :: string?)

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
				setRootDir(function(rootDir_)
					local rootDir = Sift.Dictionary.copyDeep(rootDir_)

					local file: any = FileUtils.IdToFileRecursive(rootDir, fileId)
					if file then
						file.displayName = newName
					else
						warn("Tried to rename, but could not find file with id", fileId)
					end

					return rootDir
				end)
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
	}, {
		Header = e("Frame", {
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			Header = e(Header, {}),
		}),

		TableTabs = e(TableTabs.Provider, {
			value = {
				tabs = {
					name = 0.5,
					dateModified = 0.3,
					kind = 0.2,
				},
				resizeTab = function() end,
			},
		}, {
			TableHeader = e(TableHeader, {
				sortMode = sortMode,
				setSortMode = setSortMode,
				sortTarget = sortTarget,
				setSortTarget = setSortTarget,
			}),

			ListContainer = e("Frame", {
				Position = UDim2.fromOffset(0, 50 + 24 + 6),
				Size = UDim2.new(1, 0, 1, -(50 + 24 + 24 + 6)),
				BackgroundTransparency = 1,
			}, {
				List = e(FileList, {
					sortMode = sortMode,
					sortTarget = sortTarget,
				}),
			}),

			Breadcrumbs = e(Breadcrumbs, {}),
		}),
	})
end

return AssetsScreen
