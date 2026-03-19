export function splitTimestamp(value: string): [string, string] {
  if (!value?.trim()) {
    return ['--', '--']
  }

  const normalized = value.trim().replace('T', ' ').replace('Z', '')
  const strictMatch = normalized.match(/^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})/)

  if (strictMatch) {
    return [strictMatch[1], strictMatch[2]]
  }

  const parts = normalized.split(/\s+/)
  const datePart = parts[0] ?? '--'
  const timePart = parts[1] ?? '--'

  return [datePart, timePart]
}