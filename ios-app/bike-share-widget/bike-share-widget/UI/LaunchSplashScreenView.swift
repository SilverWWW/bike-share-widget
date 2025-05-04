import SwiftUI

struct LaunchSplashscreenView: View {
            
    private let closeSplash: () -> (Void)
    private let durationShowingSplash: Double = 1.5
    
    init(onDoneShowingSplash: @escaping () -> (Void)) {
        self.closeSplash = onDoneShowingSplash
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Image.BSW("REPLACE_WITH_LOGO")
                .frame(width: 500, height: 250)
            
        }
        .task {
            try? await Task.sleep(for: .seconds(durationShowingSplash))
            await MainActor.run {
                closeSplash()
            }
        }
    }
}

#Preview {
    LaunchSplashscreenView(onDoneShowingSplash: {})
}
