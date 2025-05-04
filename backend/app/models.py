from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class StationResponse(BaseModel):
    station_id: str
    lat: float
    lon: float
    num_docks_available: int
    is_renting: bool
    is_returning: bool
    num_ebikes_available: int
    num_regular_bikes_available: int
    last_reported: datetime
    name: Optional[str] = None
    distance: Optional[float] = None  # Distance in miles from the query point