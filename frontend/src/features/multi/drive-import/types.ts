export type DriveImportVisibility = 'private' | 'public';

export interface DriveImportInput {
  event: {
    name: string;
    event_date?: string;
    end_date?: string;
  };
  file_urls: string[];
  visibility: DriveImportVisibility;
  day_number?: number;
  taken_at?: string;
}

interface DriveImportEventDto {
  id: string;
  name: string;
  event_code: string;
  event_date: string;
  status: string;
}

interface DriveImportUploadRequestDto {
  id: string;
  status: string;
  photo_count: number;
}

export interface DriveImportResponseDto {
  event: DriveImportEventDto;
  upload_request: DriveImportUploadRequestDto;
  imported_photo_count: number;
}

export interface DriveImportResult {
  eventId: string;
  eventName: string;
  eventCode: string;
  eventStatus: string;
  uploadRequestId: string;
  uploadRequestStatus: string;
  importedPhotoCount: number;
}

export const toDriveImportResult = (
  response: DriveImportResponseDto,
): DriveImportResult => ({
  eventId: response.event.id,
  eventName: response.event.name,
  eventCode: response.event.event_code,
  eventStatus: response.event.status,
  uploadRequestId: response.upload_request.id,
  uploadRequestStatus: response.upload_request.status,
  importedPhotoCount: response.imported_photo_count,
});
