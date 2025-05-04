from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.services.baywheels import router as baywheels_router

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

# Include the Baywheels router
app.include_router(baywheels_router, prefix="/api/v1/baywheels", tags=["baywheels"])

@app.get("/")
async def root():
    return {"message": "Welcome to the Bikesharing API"}