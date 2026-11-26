/**
 * Thin wrapper around the Screen Wake Lock API. Keeps the machine from
 * sleeping while a long bulk upload is running. No-ops silently on browsers
 * without support (Firefox, older Safari) or when the request is rejected
 * (e.g. tab not visible) — this is a best-effort improvement, not something
 * upload correctness depends on.
 */

let sentinel: WakeLockSentinel | null = null

export async function acquireUploadWakeLock(): Promise<void> {
	if (sentinel) return
	if (!('wakeLock' in navigator)) return

	try {
		sentinel = await navigator.wakeLock.request('screen')
		sentinel.addEventListener('release', () => {
			sentinel = null
		})
	} catch {
		// Not fatal — e.g. document not visible, or unsupported. Upload continues either way.
		sentinel = null
	}
}

export async function releaseUploadWakeLock(): Promise<void> {
	if (!sentinel) return
	try {
		await sentinel.release()
	} catch {
		// already released or unsupported
	}
	sentinel = null
}
