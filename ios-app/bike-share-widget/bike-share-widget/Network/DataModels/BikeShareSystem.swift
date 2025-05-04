//
//  BikeShareSystem.swift
//  bike-share-widget
//
//  Created by Will Silver on 5/4/25.
//

import Foundation

enum BikeShareSystem: String, CaseIterable, Identifiable {
    case baywheels, biketown
    
    var id: Self { self }
}
