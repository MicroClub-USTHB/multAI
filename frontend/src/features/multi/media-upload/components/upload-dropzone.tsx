import { FolderUp, UploadCloud } from 'lucide-react'
import { useRef, useState } from 'react'

import { Button } from '@/shared/ui'
import { cn } from '@/shared/utils/helpers'

import { collectDroppedFiles } from '../utils/collect-dropped-files'

const isImageFile = (file: File) =>
	file.type.startsWith('image/') || /\.(jpe?g|png|heic|heif|webp)$/i.test(file.name)

interface UploadDropzoneProps {
	onFilesSelected: (files: File[]) => void
	disabled?: boolean
}

export function UploadDropzone({ onFilesSelected, disabled }: UploadDropzoneProps) {
	const [isDragOver, setIsDragOver] = useState(false)
	const fileInputRef = useRef<HTMLInputElement>(null)
	const folderInputRef = useRef<HTMLInputElement>(null)

	const handleDrop = async (event: React.DragEvent<HTMLDivElement>) => {
		event.preventDefault()
		setIsDragOver(false)
		if (disabled) return

		const files = await collectDroppedFiles(event.dataTransfer)
		const images = files.filter(isImageFile)
		if (images.length > 0) onFilesSelected(images)
	}

	return (
		<div
			role="button"
			tabIndex={0}
			onClick={() => !disabled && fileInputRef.current?.click()}
			onKeyDown={(event) => {
				if (event.key === 'Enter' || event.key === ' ') fileInputRef.current?.click()
			}}
			onDragOver={(event) => {
				event.preventDefault()
				if (!disabled) setIsDragOver(true)
			}}
			onDragLeave={() => setIsDragOver(false)}
			onDrop={(event) => void handleDrop(event)}
			className={cn(
				'flex flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed p-10 text-center transition-colors',
				disabled
					? 'cursor-not-allowed border-border/40 opacity-60'
					: 'cursor-pointer border-border/70 hover:border-primary/50 hover:bg-muted/30',
				isDragOver && !disabled ? 'border-primary bg-primary/5' : '',
			)}
		>
			<UploadCloud className="text-muted-foreground size-8" />
			<p className="text-sm font-medium">
				Drag and drop photos or a whole folder here
			</p>
			<p className="text-muted-foreground text-xs">
				JPEG, PNG, HEIC &middot; up to 1000 files at once
			</p>

			<div className="mt-2 flex gap-2" onClick={(event) => event.stopPropagation()}>
				<Button
					type="button"
					variant="outline"
					size="sm"
					disabled={disabled}
					onClick={() => fileInputRef.current?.click()}
				>
					Browse files
				</Button>
				<Button
					type="button"
					variant="outline"
					size="sm"
					disabled={disabled}
					onClick={() => folderInputRef.current?.click()}
				>
					<FolderUp className="size-4" />
					Browse folder
				</Button>
			</div>

			<input
				ref={fileInputRef}
				type="file"
				accept="image/*"
				multiple
				disabled={disabled}
				className="hidden"
				onChange={(event) => {
					const files = Array.from(event.target.files ?? []).filter(isImageFile)
					if (files.length > 0) onFilesSelected(files)
					event.target.value = ''
				}}
			/>
			<input
				ref={folderInputRef}
				type="file"
				// @ts-expect-error non-standard attributes for directory selection
				webkitdirectory=""
				directory=""
				multiple
				disabled={disabled}
				className="hidden"
				onChange={(event) => {
					const files = Array.from(event.target.files ?? []).filter(isImageFile)
					if (files.length > 0) onFilesSelected(files)
					event.target.value = ''
				}}
			/>
		</div>
	)
}
