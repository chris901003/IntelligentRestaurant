//
//  LandmarkModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI
import MapKit

struct LandmarkModel: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var coordinate: CLLocationCoordinate2D
    
    init(mapItem: MKMapItem) {
        title = mapItem.name ?? ""
        subtitle = mapItem.placemark.title ?? ""
        coordinate = mapItem.placemark.coordinate
    }
}
