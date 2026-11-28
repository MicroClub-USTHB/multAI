export interface EventPhoto {
  id: string
  visibility: string
  status: string
  face_count: number
  day_number: number | null
  taken_at: string | null
  created_at: string
}

export interface EventPhotosPage {
  total: number
  items: EventPhoto[]
}
