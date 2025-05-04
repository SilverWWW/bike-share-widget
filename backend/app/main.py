# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.services.baywheels import router as baywheels_router
from app.services.biketown import router as biketown_router

app = FastAPI(
    title="Bikesharing API",
    description="API for accessing bikesharing data",
    version="0.1.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include the service routers
app.include_router(baywheels_router, prefix="/api/v1/baywheels", tags=["baywheels"])
app.include_router(biketown_router, prefix="/api/v1/biketown", tags=["biketown"])

@app.get("/")
async def root():
    return {"message": "Welcome to the Bikesharing API"}