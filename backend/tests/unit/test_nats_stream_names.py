from app.core.constant import (
    FINAL_BUCKET_CLEANUP_STREAM,
    PHOTO_PROCESS_STREAM,
    UPLOAD_GROUP_IMPORT_STREAM,
)
from app.infra.nats import SUBJECT_TO_STREAM, NatsSubjects
from app.worker.photo_worker.settings import settings as photo_settings


def test_publisher_streams_match_the_worker_streams() -> None:
    """A mismatch makes js_publish try to create an overlapping stream and fail."""
    assert (
        SUBJECT_TO_STREAM[NatsSubjects.STAFF_UPLOAD_GROUP_IMPORT_REQUESTED.value]
        == UPLOAD_GROUP_IMPORT_STREAM
    )
    assert SUBJECT_TO_STREAM[NatsSubjects.PHOTO_PROCESS.value] == PHOTO_PROCESS_STREAM
    assert PHOTO_PROCESS_STREAM == photo_settings.stream_name
    assert (
        SUBJECT_TO_STREAM[NatsSubjects.FINAL_BUCKET_CLEANUP.value]
        == FINAL_BUCKET_CLEANUP_STREAM
    )
