import { jsPDF } from 'jspdf'
import QRCode from 'qrcode'

import type { MultiEvent } from '../types'

export async function exportEventPdf(event: MultiEvent) {
	const qrDataUrl = await QRCode.toDataURL(event.eventCode, { width: 512, margin: 1 })

	const doc = new jsPDF({ unit: 'pt', format: 'a4' })
	const pageWidth = doc.internal.pageSize.getWidth()

	doc.setFontSize(22)
	doc.text(event.name, pageWidth / 2, 80, { align: 'center' })

	doc.setFontSize(12)
	doc.setTextColor(100)
	doc.text(
		new Date(event.eventDate).toLocaleString(undefined, {
			year: 'numeric',
			month: 'long',
			day: '2-digit',
			hour: '2-digit',
			minute: '2-digit',
		}),
		pageWidth / 2,
		100,
		{ align: 'center' },
	)

	const qrSize = 280
	doc.addImage(qrDataUrl, 'PNG', (pageWidth - qrSize) / 2, 140, qrSize, qrSize)

	doc.setFontSize(16)
	doc.setTextColor(0)
	doc.text(event.eventCode, pageWidth / 2, 140 + qrSize + 40, { align: 'center' })

	doc.setFontSize(11)
	doc.setTextColor(120)
	doc.text(
		'Scan this code or enter it manually in the MultiAI app to join the event.',
		pageWidth / 2,
		140 + qrSize + 65,
		{ align: 'center' },
	)

	doc.save(`${event.name.trim().replace(/\s+/g, '-').toLowerCase()}-qr.pdf`)
}
