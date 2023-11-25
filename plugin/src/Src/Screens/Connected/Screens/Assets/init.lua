local React = require("@Packages/React")
local Sift = require("@Packages/Sift")

local Topbar = require("@Src/Screens/Connected/Screens/Assets/Topbar")
local FileList = require("@Src/Screens/Connected/Screens/Assets/FileList")
local TableHeader = require("@Src/Screens/Connected/Screens/Assets/TableHeader")
local TableTabs = require("@Src/Screens/Connected/Screens/Assets/TableTabs")
local Breadcrumbs = require("@Src/Screens/Connected/Screens/Assets/Breadcrumbs")

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
			rootDir = rootDir,
			refresh = refresh,
			selectFile = setSelectedFileId,
			renameFile = function(fileId: string, newName: string)
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
			setCurrentDir = function(dirId: string)
				setCurrentDirId(dirId)
			end,
		},
	}, {
		Topbar = e(Topbar, {}),

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
				Position = UDim2.fromOffset(0, 52 + 24 + 6),
				Size = UDim2.new(1, 0, 1, -(52 + 24 + 24 + 6)),
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
