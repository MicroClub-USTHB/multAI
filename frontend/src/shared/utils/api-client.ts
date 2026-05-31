const DEFAULT_API_BASE_URL = 'http://127.0.0.1:8000'

export const API_BASE_URL =
	(import.meta.env.VITE_SERVER_URL as string | undefined) ??
	DEFAULT_API_BASE_URL

export type ApiRequestOptions = {
	fallbackErrorMessage?: string
	tokenKey?: string
}

export class ApiError extends Error {
	status: number
	details?: unknown

	constructor(message: string, status: number, details?: unknown) {
		super(message)
		this.name = 'ApiError'
		this.status = status
		this.details = details
	}
}

const getAccessToken = (tokenKey: string) => {
	if (typeof window === 'undefined') {
		return null
	}

	return window.localStorage.getItem(tokenKey)
}

const resolveErrorMessage = (payload: unknown, fallback: string) => {
	if (!payload) {
		return fallback
	}

	if (typeof payload === 'string') {
		return payload
	}

	if (typeof payload !== 'object') {
		return fallback
	}

	const details = (payload as { detail?: unknown }).detail

	if (typeof details === 'string') {
		return details
	}

	if (Array.isArray(details) && details.length > 0) {
		const first = details[0]
		if (typeof first === 'string') {
			return first
		}

		if (first && typeof first === 'object' && 'msg' in first) {
			const message = (first as { msg?: unknown }).msg
			if (typeof message === 'string') {
				return message
			}
		}
	}

	return fallback
}

const buildHeaders = (
	initHeaders: HeadersInit | undefined,
	{
		tokenKey,
		setJsonContentType,
	}: { tokenKey?: string; setJsonContentType: boolean },
) => {
	const headers = new Headers(initHeaders)

	if (setJsonContentType && !headers.has('Content-Type')) {
		headers.set('Content-Type', 'application/json')
	}

	if (tokenKey) {
		const token = getAccessToken(tokenKey)
		if (token) {
			headers.set('Authorization', `Bearer ${token}`)
		}
	}

	return headers
}

const parsePayload = (rawText: string) => {
	if (!rawText) {
		return null
	}

	try {
		return JSON.parse(rawText) as unknown
	} catch {
		return rawText
	}
}

export const apiRequest = async <TResponse>(
	path: string,
	init: RequestInit,
	options: ApiRequestOptions = {},
): Promise<TResponse> => {
	const setJsonContentType =
		init.body !== undefined && !(init.body instanceof FormData)

	const response = await fetch(`${API_BASE_URL}${path}`, {
		...init,
		headers: buildHeaders(init.headers, {
			tokenKey: options.tokenKey,
			setJsonContentType,
		}),
		credentials: 'include',
	})

	const rawText = await response.text()
	const payload = parsePayload(rawText)

	if (!response.ok) {
		const fallbackMessage =
			options.fallbackErrorMessage ?? 'Request failed.'
		throw new ApiError(
			resolveErrorMessage(payload, fallbackMessage),
			response.status,
			payload,
		)
	}

	return payload as TResponse
}

type ApiHelperOptions = ApiRequestOptions & {
	headers?: HeadersInit
}

export const apiGet = <TResponse>(
	path: string,
	options: ApiHelperOptions = {},
): Promise<TResponse> =>
	apiRequest<TResponse>(path, { method: 'GET', headers: options.headers }, options)

export const apiPost = <TResponse, TBody = unknown>(
	path: string,
	body: TBody,
	options: ApiHelperOptions = {},
): Promise<TResponse> =>
	apiRequest<TResponse>(
		path,
		{
			method: 'POST',
			body: body instanceof FormData ? body : JSON.stringify(body),
			headers: options.headers,
		},
		options,
	)

export const apiPatch = <TResponse, TBody = unknown>(
	path: string,
	body: TBody,
	options: ApiHelperOptions = {},
): Promise<TResponse> =>
	apiRequest<TResponse>(
		path,
		{
			method: 'PATCH',
			body: body instanceof FormData ? body : JSON.stringify(body),
			headers: options.headers,
		},
		options,
	)

export const apiPut = <TResponse, TBody = unknown>(
	path: string,
	body: TBody,
	options: ApiHelperOptions = {},
): Promise<TResponse> =>
	apiRequest<TResponse>(
		path,
		{
			method: 'PUT',
			body: body instanceof FormData ? body : JSON.stringify(body),
			headers: options.headers,
		},
		options,
	)

export const apiDelete = <TResponse>(
	path: string,
	options: ApiHelperOptions = {},
): Promise<TResponse> =>
	apiRequest<TResponse>(
		path,
		{ method: 'DELETE', headers: options.headers },
		options,
	)
