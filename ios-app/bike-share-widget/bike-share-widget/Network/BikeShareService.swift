import Foundation
import CoreLocation

// MARK: - BikeShare Service
class BikeShareService {
    
    static var currentBikeShareSystem: BikeShareSystem = .baywheels
        
    private static let baywheels = "/api/v1/baywheels"
    private static let biketown = "/api/v1/biketown"
    
    // MARK: - Endpoints
    private enum Endpoint {
        static var stations: String {
            switch currentBikeShareSystem {
            case .baywheels:
                return "/api/v1/baywheels/stations"
            case .biketown:
                return "/api/v1/biketown/stations"
            }
        }
        
        static var nearbyStations: String {
            switch currentBikeShareSystem {
            case .baywheels:
                return "/api/v1/baywheels/stations/nearby"
            case .biketown:
                return "/api/v1/biketown/stations/nearby"
            }
        }
    }
    
    // MARK: - Error Types
    enum BikeShareError: Error {
        case decodingFailed(Error)
        case networkError(Error)
        case invalidData
        
        var localizedDescription: String {
            switch self {
            case .decodingFailed(let error):
                return "Failed to decode station data: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidData:
                return "The data received was invalid or empty"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetch all stations
    static func fetchAllStations() async throws -> [Station] {
        do {
            let data = try await APIRequester.getRawData(endpoint: Endpoint.stations)
            return try decodeStations(from: data)
        } catch let error as BikeShareError {
            throw BikeShareError.networkError(error)
        }
    }
    
    /// Fetch stations near a specific location
    static func fetchNearbyStations(latitude: Double, longitude: Double, radius: Double = 10000) async throws -> [Station] {
        do {
            let queryParams = [
                "lat": String(latitude),
                "lon": String(longitude),
                "radius": String(radius)
            ]
            
            let data = try await APIRequester.getRawData(
                endpoint: Endpoint.nearbyStations,
                queryParameters: queryParams
            )
            
            var stations = try decodeStations(from: data)
            // sort by distance
            stations.sort { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
            
            return stations
        } catch let error as BikeShareError {
            throw BikeShareError.networkError(error)
        }
    }
    
    // MARK: - Private Methods
    
    /// Manual decoding function for Station objects
    private static func decodeStations(from data: Data) throws -> [Station] {
        do {
            // Configure the decoder with appropriate date decoding strategy
            let decoder = JSONDecoder()
            
            // Try to decode the array of stations
            return try decoder.decode([Station].self, from: data)
        } catch {
            throw BikeShareError.decodingFailed(error)
        }
    }
}
