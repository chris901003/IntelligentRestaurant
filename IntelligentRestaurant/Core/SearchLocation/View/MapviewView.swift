//
//  MapviewView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI
import MapKit

struct MapviewView: UIViewRepresentable {
    
    @Binding var selectLocation: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(selectLocation, animated: true)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(selectLocation, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapviewView
        
        init(_ parent: MapviewView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.selectLocation = mapView.region
            }
        }
    }
}
