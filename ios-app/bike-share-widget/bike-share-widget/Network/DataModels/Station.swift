import Foundation

struct Station: Identifiable, Equatable, Decodable {
    let id: String
    let name: String?
    let latitude: Double
    let longitude: Double
    let numRegularBikesAvailable: Int
    let numEBikesAvailable: Int
    let numDocksAvailable: Int
    let isRenting: Bool
    let isReturning: Bool
    let lastReported: Date
    var distance: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "station_id"
        case name
        case latitude = "lat"
        case longitude = "lon"
        case numRegularBikesAvailable = "num_regular_bikes_available"
        case numEBikesAvailable = "num_ebikes_available"
        case numDocksAvailable = "num_docks_available"
        case isRenting = "is_renting"
        case isReturning = "is_returning"
        case lastReported = "last_reported"
        case distance
    }
    
    // init from decoder to handle date format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        numRegularBikesAvailable = try container.decode(Int.self, forKey: .numRegularBikesAvailable)
        numEBikesAvailable = try container.decode(Int.self, forKey: .numEBikesAvailable)
        numDocksAvailable = try container.decode(Int.self, forKey: .numDocksAvailable)
        isRenting = try container.decode(Bool.self, forKey: .isRenting)
        isReturning = try container.decode(Bool.self, forKey: .isReturning)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        
        // Parse the date string
        let dateString = try container.decode(String.self, forKey: .lastReported)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            lastReported = date
        } else {
            // Fall back to current date if parsing fails
            print("Warning: Could not parse date: \(dateString)")
            lastReported = Date()
        }
    }
    
    var totalBikesAvailable: Int {
        return numRegularBikesAvailable + numEBikesAvailable
    }
    
    var lastReportedFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastReported, relativeTo: Date())
    }
}
