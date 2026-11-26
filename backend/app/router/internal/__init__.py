from fastapi import APIRouter

from app.router.internal.events import router as internal_events_router

router = APIRouter(prefix="/internal", tags=["internal"])
router.include_router(internal_events_router)
