import SwiftUI

struct TabBarView: View {
        
    var body: some View {
        
        TabView {
            Group {
                
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        }
        .tint(.black)
    }
    
}
#Preview {
    TabBarView()
}
