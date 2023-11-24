type Array<T> = { T }
type Map<K, V> = { [K]: V }

export type ConnectionResult = {
	id: string,
	sessionInfo: SessionInfo,
}

export type SessionInfo = {
	licenseType: string,
	sessionType: string,
	connectionType: string,
	pipePath: string?,
}

export type BaseFile = {
	id: string,
	displayName: string,
}

export type AssetFile = BaseFile & {
	type: "Asset",
	assetType: string,
}

export type FolderFile = BaseFile & {
	type: "Folder",
	children: Array<File>?,
}

export type File = AssetFile | FolderFile

export type FileSystem = Array<File>

return nil
