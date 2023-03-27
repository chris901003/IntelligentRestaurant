//
//  SelectLocationViewModel.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI
import MapKit

class SelectLocationViewModel: ObservableObject {
    
    // Published Variable
    @Published var searchTitle: String = ""
    @Published var selectLocationRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 23.57565, longitude: 120.9738819), span: MKCoordinateSpan(latitudeDelta: 3.5, longitudeDelta: 3.5))
    @Published var landmarks: [LandmarkModel] = []
    
    @Published var isSearching: Bool = false
    
    // Public Function
    func searchLandmark() async {
        await MainActor.run {
            isSearching.toggle()
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTitle
        request.region = selectLocationRegion
        let search = MKLocalSearch(request: request)
        let searchResult = try? await search.start()
        guard let searchResult = searchResult else { return }
        let mapItmes = searchResult.mapItems
        await MainActor.run {
            landmarks = mapItmes.map { mapItem in
                LandmarkModel(mapItem: mapItem)
            }
        }
        await MainActor.run {
            isSearching.toggle()
        }
    }
}
