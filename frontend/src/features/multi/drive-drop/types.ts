export interface DriveDropInput {
  folder_url: string
  event_id?: string
  new_event?: { name: string; event_date?: string }
  visibility: 'private' | 'public'
}

export interface DriveDropResult {
  group_id: string
  event_id: string
}
