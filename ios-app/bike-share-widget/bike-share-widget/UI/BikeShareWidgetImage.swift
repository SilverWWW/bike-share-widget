import Foundation
import SwiftUI


extension Image {
    
    // A way of creating images with properties I generally want while avoiding redudancy
    
    private static func imageWithModifiers(_ image: Image, color: Color?) -> some View {
        image
            .renderingMode(color == nil ? .original : .template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(color ?? .primary)
    }
    
    static func BSW(_ image: String, color: Color? = nil) -> some View {
        Image.imageWithModifiers(Image(image), color: color)
    }
    
    static func BSW(uiImage: UIImage, color: Color? = nil) -> some View {
        Image.imageWithModifiers(Image(uiImage: uiImage), color: color)
    }
    
    static func BSW(systemName: String, color: Color? = nil) -> some View {
        Image.imageWithModifiers(Image(systemName: systemName), color: color)
    }
}
