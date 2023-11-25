local StudioService = game:GetService("StudioService")

local React = require("@Packages/React")

local PluginConstants = require("@Src/PluginConstants")
local Font = PluginConstants.Font

local TarmacAssets = require("@Src/TarmacAssets")
local TarmacAssetUtils = require("@Src/TarmacAssetUtils")

local AssetIcon = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.AssetsScreen.AssetIcon)
local AssetDragIcon = TarmacAssetUtils.ResolveTarmacAsset(TarmacAssets.DragIcons.AssetIcon, 1)

local TableTabs = require("@Src/Screens/Connected/Screens/Assets/TableTabs")
local useTableTabs = TableTabs.useTableTabs

local useStudioTheme = require("@Contexts/StudioTheme").useStudioTheme
local useFileSystem = require("@Contexts/FileSystem").useFileSystem
local useDockWidget = require("@Contexts/DockWidget").useDockWidget
local usePlugin = require("@Contexts/Plugin").usePlugin

local HttpTypes = require("@Types/HttpTypes")
type File = HttpTypes.File

local e = React.createElement
local useRef = React.useRef
local useState = React.useState
local useEffect = React.useEffect

export type Props = {
	index: number,
	fileData: File,
}

local function ListItem(props: Props)
	local index = props.index
	local fileData = props.fileData

	local theme = useStudioTheme()
	local fileSystem = useFileSystem()
	local dockWidget = useDockWidget()
	local plugin = usePlugin()
	local tableTabs = useTableTabs()

	local renameCountdownThread = useRef(nil :: thread?)
	local lastSelectTime, setLastSelectTime = useState(0)

	local startDragPosition: Vector2?, setStartDragPosition = useState(nil :: Vector2?)
	local dragTriggered, setDragTriggered = useState(false)

	local renameRef = useRef(nil :: TextBox?)
	local renaming, setRenaming = useState(false)

	local folderIcon = StudioService:GetClassIcon("Folder")

	local icon, iconSize
	if fileData.meta.type == "Folder" then
		icon = folderIcon
		iconSize = Vector2.new(16, 16)
	else
		icon = AssetIcon
		iconSize = Vector2.new(14, 14)
	end

	-- When the selected file changes, cancel any task to rename the file
	useEffect(function()
		if renameCountdownThread.current then
			task.cancel(renameCountdownThread.current)
			renameCountdownThread.current = nil
		end
	end, { fileSystem.selectedFileId })

	useEffect(function()
		if not dragTriggered then
			return
		end

		local connection = dockWidget.PluginDragDropped:Connect(function(data)
			if data.Sender == "HoudiniAssetManager" then
				setStartDragPosition(nil)
				setDragTriggered(false)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { dragTriggered })

	local defaultBackgroundColor = index % 2 == 0 and theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
		or theme:GetColor(Enum.StudioStyleGuideColor.Titlebar)

	local isSelected = fileData.id == fileSystem.selectedFileId
	local backgroundColor = if isSelected then Color3.fromHex("#0074bd") else defaultBackgroundColor

	local innerPadding = 8
	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
	}, {
		VisualBackground = e("ImageButton", {
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -innerPadding * 2, 1, 0),
			BackgroundColor3 = backgroundColor,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			[React.Event.InputBegan] = function(_, input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					setStartDragPosition(Vector2.new(input.Position.X, input.Position.Y))
				end
			end,
			[React.Event.InputEnded] = function(_, input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					setStartDragPosition(nil)
					setDragTriggered(false)
				end
			end,
			[React.Event.InputChanged] = function(_, input: InputObject)
				if not startDragPosition or dragTriggered then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseMovement then
					local position = Vector2.new(input.Position.X, input.Position.Y)
					local delta = position - startDragPosition

					if delta.Magnitude > 10 then
						if renameCountdownThread.current then
							task.cancel(renameCountdownThread.current)
							renameCountdownThread.current = nil
						end

						setDragTriggered(true)
						plugin:StartDrag({
							Sender = "HoudiniAssetManager",
							MimeType = "text/plain",
							Data = fileData.id,
							MouseIcon = "",
							DragIcon = if fileData.meta.type == "Folder" then folderIcon.Image else AssetDragIcon.Image,
							HotSpot = Vector2.new(20, 20),
						})
					end
				end
			end,
			[React.Event.Activated] = function()
				if fileSystem.selectedFileId ~= fileData.id then
					fileSystem.selectFile(fileData.id)
					setLastSelectTime(os.clock())
				else
					local now = os.clock()
					local timeSinceLastSelect = now - lastSelectTime

					if renameCountdownThread.current then
						task.cancel(renameCountdownThread.current)
					end

					-- If the user double-clicks quickly, open the folder
					-- If the user clicks after selecting, rename the file
					if timeSinceLastSelect < 0.2 then
						if fileData.meta.type == "Folder" then
							fileSystem.setCurrentDir(fileData.id)
						end
					else
						renameCountdownThread.current = task.delay(0.6, function()
							renameCountdownThread.current = nil
							setRenaming(true)

							-- Note: Weird engine timing specifics means that
							-- the shorted delay before `ref` is set is 0.
							-- `task.defer` does not work.
							task.delay(0, function()
								if renameRef.current then
									renameRef.current:CaptureFocus()

									local connection
									connection = renameRef.current.FocusLost:Connect(function()
										connection:Disconnect()
										setRenaming(false)

										local newName = renameRef.current.Text

										-- The name can only contain alphanumeric characters, dashes, and underscores
										-- It must be at least one character
										if string.match(newName, "[a-zA-Z0-9-_]+") then
											if newName ~= fileData.displayName then
												fileSystem.renameFile(fileData.id, newName)
											end
										end
									end)
								end
							end)
						end)
					end

					setLastSelectTime(os.clock())
				end
			end,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),

			Icon = e("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.fromOffset(iconSize.X, iconSize.Y),
				BackgroundTransparency = 1,
				Image = icon.Image,
				ImageRectOffset = icon.ImageRectOffset,
				ImageRectSize = icon.ImageRectSize,
			}),

			Content = e("Frame", {
				Position = UDim2.fromOffset(32, 0),
				Size = UDim2.new(1, -32, 1, 0),
				BackgroundTransparency = 1,
			}, {
				NameContainer = e("Frame", {
					Size = UDim2.fromScale(tableTabs.tabs.name, 1),
					BackgroundTransparency = 1,
				}, {
					ItemName = e(if renaming then "TextBox" else "TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(0, 0, 1, -4),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundColor3 = defaultBackgroundColor,
						BackgroundTransparency = if renaming then 0 else 1,
						TextEditable = if renaming then true else nil,
						Text = fileData.displayName,
						FontFace = Font.Regular,
						TextSize = 16,
						TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.BrightText),
						TextXAlignment = Enum.TextXAlignment.Left,
						ClearTextOnFocus = if renaming then false else nil,
						ref = if renaming then renameRef else nil,
					}, {
						UICorner = e("UICorner", {
							CornerRadius = UDim.new(0, 4),
						}),

						Stroke = renaming and e("UIStroke", {
							Color = Color3.fromHex("#32b5ff"),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Transparency = 0.5,
							Thickness = 2,
						}),

						Padding = e("UIPadding", {
							PaddingLeft = UDim.new(0, 4),
							PaddingRight = UDim.new(0, 4),
						}),
					}),
				}),

				DateModified = e("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(tableTabs.tabs.name, 0.5),
					Size = UDim2.new(tableTabs.tabs.dateModified, -4, 1, 0),
					BackgroundTransparency = 1,
					Text = "Today, 17:14",
					FontFace = Font.Regular,
					TextSize = 16,
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),

				Kind = e("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(tableTabs.tabs.name + tableTabs.tabs.dateModified, 0.5),
					Size = UDim2.fromScale(tableTabs.tabs.kind, 1),
					BackgroundTransparency = 1,
					Text = if fileData.meta.type == "Asset" then fileData.meta.assetType else fileData.meta.type,
					FontFace = Font.Regular,
					TextSize = 16,
					TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),
			}),
		}),
	})
end

return ListItem
