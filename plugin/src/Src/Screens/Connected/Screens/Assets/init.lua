local React = require("@Packages/React")
local Sift = require("@Packages/Sift")

local Topbar = require("@Src/Screens/Connected/Screens/Assets/Topbar")
local FileList = require("@Src/Screens/Connected/Screens/Assets/FileList")
local TableHeader = require("@Src/Screens/Connected/Screens/Assets/TableHeader")
local TableTabs = require("@Src/Screens/Connected/Screens/Assets/TableTabs")
local Breadcrumbs = require("@Src/Screens/Connected/Screens/Assets/Breadcrumbs")

local FileSystemContext = require("@Contexts/FileSystem")
local FileUtils = require("@Utils/FileUtils")

local HttpTypes = require("@Types/HttpTypes")
type FileSystem = HttpTypes.FileSystem

local e = React.createElement
local useState = React.useState

local FS: FileSystem = {
	{
		type = "Folder" :: "Folder",
		id = "Folder1",
		displayName = "Folder 1",
		children = {
			{
				type = "Asset" :: "Asset",
				id = "Asset1",
				displayName = "Asset 1",
				assetType = "HDA",
			},
			{
				type = "Asset" :: "Asset",
				id = "Asset2",
				displayName = "Asset 2",
				assetType = "HDA",
			},
			{
				type = "Asset" :: "Asset",
				id = "Asset3",
				displayName = "Asset 3",
				assetType = "HDA",
			},
			{
				type = "Folder" :: "Folder",
				id = "Folder5",
				displayName = "Folder 5",
			} :: any,
		},
	},
	{
		type = "Folder" :: "Folder",
		id = "Folder2",
		displayName = "Folder 2",
		children = {
			{
				type = "Asset" :: "Asset",
				id = "Asset4",
				displayName = "Asset 4",
				assetType = "HDA",
			},
			{
				type = "Asset" :: "Asset",
				id = "Asset5",
				displayName = "Asset 5",
				assetType = "HDA",
			},
			{
				type = "Asset" :: "Asset",
				id = "Asset6",
				displayName = "Asset 6",
				assetType = "HDA",
			},
		},
	},
	{
		type = "Folder" :: "Folder",
		id = "Folder3",
		displayName = "Folder 3",
		children = {
			{
				type = "Asset" :: "Asset",
				id = "Asset7",
				displayName = "Asset 7",
				assetType = "HDA",
			},
		},
	},
	{
		type = "Folder" :: "Folder",
		id = "Folder4",
		displayName = "Folder 4",
	},
}

local function AssetsScreen()
	local rootDir, setRootDir = useState(FS)
	local currentDirId, setCurrentDirId = useState("{ROOT}")
	local selectedFileId: string?, setSelectedFileId = useState(nil :: string?)

	local sortMode, setSortMode = useState("asc")
	local sortTarget, setSortTarget = useState("displayName")

	return e(FileSystemContext.Provider, {
		value = {
			currentDirId = currentDirId,
			selectedFileId = selectedFileId,
			rootDir = rootDir,
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
