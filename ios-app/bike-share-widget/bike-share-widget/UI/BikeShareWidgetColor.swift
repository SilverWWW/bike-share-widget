
import Foundation
import SwiftUI

extension Color {
        
    static var currentBikeShareSystem: BikeShareSystem = .baywheels
    
    static var BSWMain: Color {
        switch currentBikeShareSystem {
        case .baywheels:
            return baywheels
        case .biketown:
            return biketown
        case .bluebikes:
            return bluebikes
        case .citibike:
            return citibike
        case .divvy:
            return divvy
        }
    }
    
    static let darkGray = Color(hex: 0x555555)
    
    private static let biketown = Color(hex: 0xff5733)
    private static let baywheels = Color(hex: 0xff00bf)
    private static let bluebikes = Color(hex: 0x006fb9)
    private static let citibike = Color(hex: 0x0047ab)
    private static let divvy = Color(hex: 0x48bbdb)

    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255.0
        let g = Double((hex & 0x00FF00) >> 8) / 255.0
        let b = Double(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}
