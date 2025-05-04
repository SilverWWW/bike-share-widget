import Foundation
import SwiftUI

extension Text {
    
    // A way of creating text with properties I generally want while avoiding redudancy
    
    static func BSW(_ content: String,
                    size: CGFloat = 12,
                    color: Color = .black,
                    bold: Bool = false,
                    underline: Bool = false) -> Text {
        Text(content)
            .font(.system(size: size))
            .bold(bold)
            .underline(underline)
            .foregroundStyle(color)
    }
}
