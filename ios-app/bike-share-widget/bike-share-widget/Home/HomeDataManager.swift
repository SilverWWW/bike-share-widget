//
//  HomeDataManager.swift
//  bike-share-widget
//
//  Created by Will Silver on 5/3/25.
//

import Foundation

class HomeDataManager {
    
    func getStations() async throws-> [Station] {
        return try await BikeShareService.fetchAllStations()
    }
    
    func getNearbyStations(userLocation: (lat: Double, lon: Double), radiusMiles: Double) async throws -> [Station] {
        return try await BikeShareService.fetchNearbyStations(latitude: userLocation.lat,
                                                              longitude: userLocation.lon,
                                                              radius: radiusMiles)
    }
    
}
