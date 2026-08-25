import { UploadCloud } from 'lucide-react'
import { useRef, useState } from 'react'

import { cn } from '@/shared/utils/helpers'

interface UploadDropzoneProps {
	onFilesSelected: (files: FileList) => void
	disabled?: boolean
}

export function UploadDropzone({ onFilesSelected, disabled }: UploadDropzoneProps) {
	const [isDragOver, setIsDragOver] = useState(false)
	const inputRef = useRef<HTMLInputElement>(null)

	const handleDrop = (event: React.DragEvent<HTMLDivElement>) => {
		event.preventDefault()
		setIsDragOver(false)
		if (disabled) return
		if (event.dataTransfer.files.length > 0) {
			onFilesSelected(event.dataTransfer.files)
		}
	}

	return (
		<div
			role="button"
			tabIndex={0}
			onClick={() => !disabled && inputRef.current?.click()}
			onKeyDown={(event) => {
				if (event.key === 'Enter' || event.key === ' ') inputRef.current?.click()
			}}
			onDragOver={(event) => {
				event.preventDefault()
				if (!disabled) setIsDragOver(true)
			}}
			onDragLeave={() => setIsDragOver(false)}
			onDrop={handleDrop}
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
				Drag and drop photos here, or click to browse
			</p>
			<p className="text-muted-foreground text-xs">
				JPEG, PNG, HEIC &middot; up to 1000 files at once
			</p>
			<input
				ref={inputRef}
				type="file"
				accept="image/*"
				multiple
				disabled={disabled}
				className="hidden"
				onChange={(event) => {
					if (event.target.files && event.target.files.length > 0) {
						onFilesSelected(event.target.files)
					}
					event.target.value = ''
				}}
			/>
		</div>
	)
}
