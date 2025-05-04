//
//  HomeViewModel.swift
//  bike-share-widget
//
//  Created by Will Silver on 5/3/25.
//

import Foundation
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    
    let dataManager = HomeDataManager()
    let locationManager = LocationManager.shared
    
    @Published var stations = [Station]()
    @Published var searchRadius: Double = 5.0 
    @Published var isLoading = true
    
    var searchRadiusFormatted: String {
        "\(String(format: "%.1f", searchRadius)) mi."
    }

    enum LocationStatus {
        case waiting
        case available
        case error(String)
    }
    
    
    func fetchNearbyStations() async {
        isLoading = true
        
        // Request location and wait for it
        locationManager.requestLocationIfNeeded()
        
        let timeoutSeconds = 10.0
        let startTime = Date()
        
        while locationManager.location == nil {
            if Date().timeIntervalSince(startTime) > timeoutSeconds {
                isLoading = false
                print(LocationError.locationNotAvailable.localizedDescription)
                return
            }
            // Wait a bit before checking again
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
                
        guard let location = locationManager.location else {
            isLoading = false
            return
        }
        
        do {
            stations = try await dataManager.getNearbyStations(
                userLocation: (location.coordinate.latitude, location.coordinate.longitude),
                radiusMiles: searchRadius)
            isLoading = false
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
}
