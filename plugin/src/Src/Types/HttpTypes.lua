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

export type AssetFile = {
	type: "Asset",
	assetType: string,
	assetExists: boolean,
	assetPath: string,
}

export type FolderFile = {
	type: "Folder",
	children: Array<File>?,
}

export type File = {
	id: string,
	displayName: string,
	dateModified: string,
	meta: AssetFile | FolderFile,
}

export type FileSystem = Array<File>

return nil
