//
//  ContentView.swift
//  APP-TEMPLATE
//
//  Created by Will Silver on 5/2/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var showSplash = true
    
    var body: some View {
        if showSplash {
            LaunchSplashscreenView(onDoneShowingSplash: {
                showSplash = false
            })
        } else {
            NavigationStack {
                TabBarView()
            }
        }
    }
    
}

#Preview {
    ContentView()
}
