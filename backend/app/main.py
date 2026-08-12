from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import admin, public
from app.core.config import settings


@asynccontextmanager
async def lifespan(_: FastAPI):
    settings.content_dir.mkdir(parents=True, exist_ok=True)
    yield


app = FastAPI(title="GenGames API", version="0.2.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=settings.cors_origin_list, allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
app.include_router(public.router, prefix="/api/v1", tags=["public"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["admin"])
