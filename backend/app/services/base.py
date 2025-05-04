# app/services/base.py
import httpx
from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any, Optional
from datetime import datetime
import math
from app.models import StationResponse

class BikeShareService:
    """Base class for bike sharing services."""
    
    def __init__(self, api_url: str, service_name: str):
        self.api_url = api_url
        self.service_name = service_name
        self.router = APIRouter()
        
        # Register routes
        self.router.add_api_route(
            "/stations", 
            self.get_stations, 
            methods=["GET"], 
            response_model=List[StationResponse]
        )
        self.router.add_api_route(
            "/stations/nearby", 
            self.get_nearby_stations, 
            methods=["GET"], 
            response_model=List[StationResponse]
        )
    
    async def make_request(self, url: str) -> Dict[str, Any]:
        """Make an HTTP request to the specified URL and return the JSON response."""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(url)
                response.raise_for_status()
                return response.json()
            except httpx.HTTPError as e:
                raise HTTPException(status_code=500, detail=f"API request failed: {str(e)}")
    
    async def get_feed_urls(self) -> Dict[str, str]:
        """Get the URLs for all available feeds."""
        response = await self.make_request(f"{self.api_url}/gbfs.json")
        return {feed["name"]: feed["url"] for feed in response["data"]["en"]["feeds"]}
    
    def calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
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
    
    async def get_stations(self) -> List[StationResponse]:
        """
        Get information for all stations with pre-calculated counts for bikes.
        This method should be implemented by subclasses.
        """
        raise NotImplementedError("Subclasses must implement this method")
    
    async def get_nearby_stations(self, 
        lat: float = Query(..., description="Latitude of the reference point"),
        lon: float = Query(..., description="Longitude of the reference point"),
        radius: float = Query(1.0, description="Radius in miles to search for stations")
    ) -> List[StationResponse]:
        """
        Get information for all stations within a specified radius
        of a geographical point. Stations are sorted by distance from closest to farthest.
        """
        # Get all stations first
        all_stations = await self.get_stations()
        
        # Calculate distance for each station and filter by radius
        nearby_stations = []
        for station in all_stations:
            distance = self.calculate_distance(lat, lon, station.lat, station.lon)
            if distance <= radius:
                # Add distance to the station data
                station.distance = distance
                nearby_stations.append(station)
        
        # Sort by distance (closest first)
        nearby_stations.sort(key=lambda x: x.distance)
        
        return nearby_stations