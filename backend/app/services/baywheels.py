import httpx
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional
from datetime import datetime
from pydantic import BaseModel
from app.models import StationResponse
import math

# Baywheels API URL
BAYWHEELS_API_URL = "https://gbfs.baywheels.com/gbfs/en"

router = APIRouter()

async def make_request(url: str) -> Dict[str, Any]:
    """
    Make an HTTP request to the specified URL and return the JSON response.
    """
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(url)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=500, detail=f"API request failed: {str(e)}")

async def get_feed_urls() -> Dict[str, str]:
    """
    Get the URLs for all available Baywheels feeds.
    """
    response = await make_request(f"{BAYWHEELS_API_URL}/gbfs.json")
    return {feed["name"]: feed["url"] for feed in response["data"]["en"]["feeds"]}

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the distance between two points using the Haversine formula.
    Returns distance in miles.
    """
    # Earth radius in miles
    R = 3958.8
    
    # Convert latitude and longitude from degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)
    
    # Haversine formula
    dlon = lon2_rad - lon1_rad
    dlat = lat2_rad - lat1_rad
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    distance = R * c
    
    return distance

@router.get("/stations", response_model=List[StationResponse])
async def get_stations():
    """
    Get information for all non-virtual Baywheels stations with pre-calculated
    counts for regular and electric bikes.
    """
    feeds = await get_feed_urls()
    
    # Get station information
    station_info_response = await make_request(feeds["station_information"])
    stations_info = {
        station["station_id"]: station 
        for station in station_info_response["data"]["stations"]
        if not station.get("is_virtual_station", False)
    }
    
    # Get station status
    station_status_response = await make_request(feeds["station_status"])
    
    # Combine the information and status
    combined_stations = []
    for status in station_status_response["data"]["stations"]:
        station_id = status["station_id"]
        # Only include non-virtual stations
        if station_id in stations_info:
            info = stations_info[station_id]
            
            # Convert the last_reported timestamp to datetime
            last_reported = datetime.fromtimestamp(status["last_reported"])
            
            # Calculate e-bike and regular bike counts
            num_ebikes = 0
            num_regular_bikes = 0
            
            # First try to get from vehicle_types_available
            if "vehicle_types_available" in status:
                for vt in status["vehicle_types_available"]:
                    if vt["vehicle_type_id"] == "1":  # Regular bike
                        num_regular_bikes = vt["count"]
                    elif vt["vehicle_type_id"] == "2":  # Electric bike
                        num_ebikes = vt["count"]
            # Fallback to the direct fields if available
            elif "num_ebikes_available" in status:
                num_ebikes = status.get("num_ebikes_available", 0)
                total_bikes = status.get("num_bikes_available", 0)
                num_regular_bikes = total_bikes - num_ebikes
            
            # Create combined response
            station = StationResponse(
                station_id=station_id,
                lat=info["lat"],
                lon=info["lon"],
                name=info.get("name"),
                num_docks_available=status["num_docks_available"],
                is_renting=bool(status.get("is_renting", 1)),
                is_returning=bool(status.get("is_returning", 1)),
                num_ebikes_available=num_ebikes,
                num_regular_bikes_available=num_regular_bikes,
                last_reported=last_reported
            )
            combined_stations.append(station)
            
    return combined_stations

@router.get("/stations/nearby", response_model=List[StationResponse])
async def get_nearby_stations(
    lat: float = Query(..., description="Latitude of the reference point"),
    lon: float = Query(..., description="Longitude of the reference point"),
    radius: float = Query(1.0, description="Radius in miles to search for stations")
):
    """
    Get information for all non-virtual Baywheels stations within a specified radius
    of a geographical point. Stations are sorted by distance from closest to farthest.
    """
    # Get all stations first
    all_stations = await get_stations()
    
    # Calculate distance for each station and filter by radius
    nearby_stations = []
    for station in all_stations:
        distance = calculate_distance(lat, lon, station.lat, station.lon)
        if distance <= radius:
            # Add distance to the station data
            station.distance = distance
            nearby_stations.append(station)
    
    # Sort by distance (closest first)
    nearby_stations.sort(key=lambda x: x.distance)
    
    return nearby_stations