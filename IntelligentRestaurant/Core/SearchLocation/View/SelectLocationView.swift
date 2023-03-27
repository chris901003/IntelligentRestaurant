//
//  SelectLocationView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/10.
//

import Foundation
import SwiftUI
import MapKit

struct SelectLocationView: View {
    
    @Binding var isShowSelectLocationView: Bool
    @Binding var selectLocation: CLLocationCoordinate2D
    @StateObject var vm: SelectLocationViewModel = SelectLocationViewModel()
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack {
                topBarButton
                searchBar
                landmarkInfo
                mapView
            }
            .frame(width: 300, height: 600)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
    
    private var topBarButton: some View {
        HStack {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundColor(Color.red)
                .padding(8)
                .background(Circle().stroke(Color.red, lineWidth: 2))
                .padding(4)
                .onTapGesture { withAnimation { isShowSelectLocationView.toggle() } }
            Text("請拖曳地圖，完成後打勾")
                .font(.headline)
                .bold()
            Image(systemName: "checkmark")
                .font(.headline)
                .foregroundColor(Color.blue)
                .padding(8)
                .background(Circle().stroke(Color.blue, lineWidth: 2))
                .padding(4)
                .onTapGesture {
                    selectLocation = vm.selectLocationRegion.center
                    withAnimation {
                        isShowSelectLocationView.toggle()
                    }
                }
        }
    }
    
    private var backgroundView: some View {
        Color.black.opacity(0.01)
            .frame(maxWidth: .infinity)
            .onTapGesture { withAnimation { isShowSelectLocationView.toggle() } }
    }
    
    private var searchBar: some View {
        HStack {
            Button {
                Task { await vm.searchLandmark() }
            } label: {
                Image(systemName: "magnifyingglass")
                    .opacity(vm.searchTitle.count == 0 ? 0.3 : 1)
                    .foregroundColor(Color.black)
            }
            .disabled(vm.searchTitle.count == 0 || vm.isSearching)
            TextField("尋找地點", text: $vm.searchTitle)
                .font(.headline)
            if vm.isSearching {
                ProgressView()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    private var landmarkInfo: some View {
        List {
            ForEach(vm.landmarks) { landmarkInfo in
                VStack(alignment: .leading) {
                    Text(landmarkInfo.title)
                        .font(.headline)
                    Text(landmarkInfo.subtitle)
                        .font(.subheadline)
                }
                .onTapGesture {
                    vm.selectLocationRegion.center = landmarkInfo.coordinate
                    vm.selectLocationRegion.span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var mapView: some View {
        ZStack {
            MapviewView(selectLocation: $vm.selectLocationRegion)
                .cornerRadius(10)
            
            VStack(spacing: 0) {
                Image(systemName: "house.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color.theme.buttonBackground)
                    .background(Color.theme.loginInfoBackground)
                    .clipShape(Circle())
                Image(systemName: "triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(Color.theme.buttonBackground)
                    .rotationEffect(Angle(degrees: 180))
                    .offset(y: -2)
                    .padding(.bottom, 40)
            }
        }
    }
}
