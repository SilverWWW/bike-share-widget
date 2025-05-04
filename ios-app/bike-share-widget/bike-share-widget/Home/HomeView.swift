//
//  HomeView.swift
//  bike-share-widget
//
//  Created by Will Silver on 5/2/25.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel = HomeViewModel()
            
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                HStack(alignment: .bottom) {
                    Text.BSW("Nearby Stations", size: 32, color: Color.BSWMain, bold: true)

                    Spacer()
                    
                    Picker("System", selection: $viewModel.currentBikeShareSystemChoice) {
                        ForEach(BikeShareSystem.allCases) { system in
                            Text(system.rawValue.capitalized)
                        }
                    }
                    .tint(Color.BSWMain)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 18)

            
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text.BSW("Distance", size: 12, color: Color.darkGray)
                        Text.BSW(viewModel.searchRadiusFormatted, size: 18, color: Color.BSWMain, bold: true)
                    }
                    .frame(width: 70, alignment: .leading)
                    
                    Slider(
                        value: $viewModel.searchRadius,
                        in: 0...10
                    ) {
                        Text("Speed")
                    } onEditingChanged: { editing in
                        if !editing {
                            Task {
                                await viewModel.fetchNearbyStations()
                            }
                        }
                    }
                    .tint(Color.BSWMain)
                }
                .padding(.bottom, 20)
                
                // no stations and loading
                if viewModel.stations.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .tint(Color.BSWMain)
                        .padding()
                }
                // no stations and not loading
                else if viewModel.stations.isEmpty && !viewModel.isLoading {
                    Text.BSW("No stations found nearby", size: 16, color: Color.BSWMain, bold: true)
                        .padding()
                }
                // stations
                else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.stations.prefix(20)) { station in
                                StationCardView(name: station.name ?? "Dock #\(station.id)",
                                                numBikes: station.numRegularBikesAvailable,
                                                numEbikes: station.numEBikesAvailable,
                                                distance: station.distance)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .mask( // add a fade
                        VStack(spacing: 0) {
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black, location: 0.5) // Increased from 0.15 to 0.5
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 20)
                            
                            Rectangle().fill(Color.black)
                            
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: 0),
                                    .init(color: .clear, location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 20)
                        }
                    )
                }
                Spacer()
            }
            .padding(12)
        }
        .task {
            await viewModel.fetchNearbyStations()
        }
    }
}

struct StationCardView: View {
    
    let name: String
    let numBikes: Int
    let numEbikes: Int
    let formattedDistance: String
    
    
    init(name: String, numBikes: Int, numEbikes: Int, distance: Double?) {
        self.name = name
        self.numBikes = numBikes
        self.numEbikes = numEbikes
        
        if let distance {
            formattedDistance = String(format: "%.2f", distance)
        } else {
            formattedDistance = "Unknown"
        }
    }
    
    var body: some View {
        
        HStack {
        
            // bike images
            VStack(spacing: 0) {
                if numBikes > 0 && numEbikes > 0 {
                    HStack { // hug right
                        Spacer()
                        Image.BSW("bike-clip", color: Color.BSWMain)
                            .frame(width: 37)
                    }
                    
                    HStack { // hug left
                        Image.BSW("ebike-clip", color: Color.BSWMain)
                            .frame(width: 35)
                        Spacer()
                    }
                }
                else if numBikes > 0 && numEbikes == 0 {
                    Image.BSW("bike-clip", color: Color.BSWMain)
                        .frame(width: 54)
                }
                else if numEbikes > 0 && numBikes == 0 {
                    Image.BSW("ebike-clip", color: Color.BSWMain)
                        .frame(width: 50)
                }
                else {
                    Image.BSW(systemName: "xmark", color: Color.BSWMain)
                        .frame(width: 40)
                }
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                Text.BSW(name, size: 20, color: Color.darkGray, bold: true)
                    .lineLimit(1)
                                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text.BSW("Bikes: \(numBikes)", size: 16, color: Color.darkGray)
                            Text.BSW("E-Bikes: \(numEbikes)", size: 16, color: Color.darkGray)
                        }
                        Text.BSW("\(formattedDistance) miles away", size: 16, color: Color.BSWMain, bold: true)
                    }
                    Spacer()
                    
                    Button(action: {
                        print(1)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(Color.BSWMain)
                            Text.BSW("Reserve", size: 16, color: .white, bold: true)
                                .padding(2)
                        }
                        .frame(width: 90, height: 30, alignment: .trailing)
                    }
                }
            }
        }
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.tertiary, lineWidth: 2)
                .padding(2)
        )
    }
}

#Preview {
    HomeView()
}
