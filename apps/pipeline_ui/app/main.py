from __future__ import annotations

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from .routes.pages import router as pages_router
from .routes.api import router as api_router


app = FastAPI(title="Pipeline UI", version="0.1.0")
app.include_router(pages_router)
app.include_router(api_router, prefix="/api")

app.mount("/static", StaticFiles(directory="apps/pipeline_ui/static"), name="static")

