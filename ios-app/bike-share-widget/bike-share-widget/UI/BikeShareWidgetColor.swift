
import Foundation
import SwiftUI

extension Color {
    
    static let BSWMain = Color(hex: 0x74b72e)
    static let darkGray = Color(hex: 0x555555)
    //    static let APPIDENTIFIERMain: Color = Color(hex: 0x000000)
    //    static let APPIDENTIFIERSecondary: Color = Color(hex: 0x000000)
    //    ...
    //    (I usually use few-letter abbreviations for App Identifiers)

    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255.0
        let g = Double((hex & 0x00FF00) >> 8) / 255.0
        let b = Double(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}
