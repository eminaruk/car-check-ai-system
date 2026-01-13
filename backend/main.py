from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.routers import vehicles_router, checks_router
from app.services import initialize_firebase


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Uygulama baslangicinda Firebase'i baslat"""
    initialize_firebase()
    yield


app = FastAPI(
    lifespan=lifespan,
    title="CarCheck AI API",
    description="Arac bakim ve ariza tespit sistemi backend API",
    version="0.1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(vehicles_router, prefix="/api")
app.include_router(checks_router, prefix="/api")


@app.get("/")
async def root():
    return {"message": "CarCheck AI API", "version": "0.1.0"}


@app.get("/health")
async def health_check():
    return {"status": "ok"}
