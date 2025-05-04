# app/services/baywheels.py
from typing import List
from datetime import datetime
from app.models import StationResponse
from app.services.base import BikeShareService

# Baywheels API URL
BAYWHEELS_API_URL = "https://gbfs.baywheels.com/gbfs/en"

class BaywheelsService(BikeShareService):
    """Service for accessing Baywheels bike sharing data."""
    
    def __init__(self):
        super().__init__(BAYWHEELS_API_URL, "baywheels")
    
    async def get_stations(self) -> List[StationResponse]:
        """
        Get information for all non-virtual Baywheels stations with pre-calculated
        counts for regular and electric bikes.
        """
        feeds = await self.get_feed_urls()
        
        # Get station information
        station_info_response = await self.make_request(feeds["station_information"])
        stations_info = {
            station["station_id"]: station 
            for station in station_info_response["data"]["stations"]
            if not station.get("is_virtual_station", False)
        }
        
        # Get station status
        station_status_response = await self.make_request(feeds["station_status"])
        
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

# Create an instance of the service
baywheels_service = BaywheelsService()
# Export the router for use in the main application
router = baywheels_service.router