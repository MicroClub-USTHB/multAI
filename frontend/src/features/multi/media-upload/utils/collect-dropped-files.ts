/**
 * Recursively walks a drag-and-drop payload (which may include whole
 * folders, not just individual files) and flattens it into a plain File[].
 * Falls back to `dataTransfer.files` on browsers without the
 * webkitGetAsEntry API (folder contents won't be expanded there, but plain
 * file drops still work).
 */

interface FileSystemEntryLike {
	isFile: boolean
	isDirectory: boolean
	file?: (callback: (file: File) => void) => void
	createReader?: () => {
		readEntries: (
			callback: (entries: FileSystemEntryLike[]) => void,
			errorCallback?: (error: unknown) => void,
		) => void
	}
}

const readAllEntries = (reader: {
	readEntries: (
		callback: (entries: FileSystemEntryLike[]) => void,
		errorCallback?: (error: unknown) => void,
	) => void
}): Promise<FileSystemEntryLike[]> =>
	new Promise((resolve, reject) => {
		reader.readEntries(resolve, reject)
	})

const readEntryAsFile = (entry: FileSystemEntryLike): Promise<File> =>
	new Promise((resolve, reject) => {
		entry.file?.(resolve)
		if (!entry.file) reject(new Error('Not a file entry'))
	})

async function collectFromEntry(entry: FileSystemEntryLike, out: File[]): Promise<void> {
	if (entry.isFile) {
		try {
			out.push(await readEntryAsFile(entry))
		} catch {
			// unreadable entry, skip it
		}
		return
	}

	if (entry.isDirectory && entry.createReader) {
		const reader = entry.createReader()
		// readEntries must be called repeatedly until it returns an empty array
		let batch = await readAllEntries(reader)
		while (batch.length > 0) {
			await Promise.all(batch.map((child) => collectFromEntry(child, out)))
			batch = await readAllEntries(reader)
		}
	}
}

export async function collectDroppedFiles(dataTransfer: DataTransfer): Promise<File[]> {
	const items = dataTransfer.items
	if (!items || items.length === 0) {
		return Array.from(dataTransfer.files ?? [])
	}

	const supportsEntries = typeof items[0]?.webkitGetAsEntry === 'function'
	if (!supportsEntries) {
		return Array.from(dataTransfer.files ?? [])
	}

	const out: File[] = []
	const entries = Array.from(items)
		.map((item) => item.webkitGetAsEntry() as FileSystemEntryLike | null)
		.filter((entry): entry is FileSystemEntryLike => entry !== null)

	await Promise.all(entries.map((entry) => collectFromEntry(entry, out)))
	return out
}
