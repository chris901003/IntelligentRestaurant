//
//  CustomerFavoriteView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/8.
//

import SwiftUI

struct CustomerFavoriteView: View {
    
    @StateObject var vm: CustomerFavoriteViewModel = CustomerFavoriteViewModel()
    @State var isShowSelectMerchantAlert: Bool = false
    @State var selectedMerchantUid: String = ""
    @Binding var selectedTab: String
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
            VStack {
                merchantInfoSection
            }
            .padding(.top, 36)
            
            if isShowSelectMerchantAlert {
                selectedMerchantAlert
            }
            if vm.isProcess {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.errorMessage)
            }
        }
    }
    
    private var merchantInfoSection: some View {
        ScrollView {
            VStack {
                ForEach(vm.favoriteMerchantInfo) { merchantInfo in
                    HStack {
                        VStack {
                            if let imageData = merchantInfo.photo,
                               let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                        .padding(2)
                        .background(
                            Circle()
                                .stroke(Color.black.opacity(0.5), lineWidth: 2)
                        )
                        Text(merchantInfo.name)
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text(merchantInfo.location)
                            .font(.headline)
                        Image(systemName: merchantInfo.favorite ? "star.fill" : "star")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(merchantInfo.favorite ? Color.pink : Color.black)
                            .frame(width: 15, height: 15)
                            .onTapGesture {
                                Task { await vm.toggleFavoriteMerchant(selected: merchantInfo) }
                            }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .onTapGesture {
                        selectedMerchantUid = merchantInfo.uid
                        withAnimation { isShowSelectMerchantAlert.toggle() }
                    }
                }
            }
        }
        .refreshable {
            Task { await vm.updateFavoriteMerchant() }
        }
    }
    
    private var selectedMerchantAlert: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { withAnimation { isShowSelectMerchantAlert.toggle() } }
            VStack {
                Text("要查看此店家嗎")
                    .font(.title3)
                    .bold()
                HStack(spacing: 16) {
                    Button {
                        withAnimation { isShowSelectMerchantAlert.toggle() }
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.backward.fill")
                            Text("返回")
                        }
                        .font(.headline)
                        .foregroundColor(Color.blue)
                        .padding(8)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    
                    Button {
                        CustomerShareInfoManager.instance.selectedMerchantUid = selectedMerchantUid
                        withAnimation { isShowSelectMerchantAlert.toggle() }
                        selectedTab = "main"
                    } label: {
                        HStack {
                            Text("確定")
                            Image(systemName: "paperplane.fill")
                                .rotationEffect(Angle(degrees: 45))
                        }
                        .font(.headline)
                        .foregroundColor(Color.pink)
                        .padding(8)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.pink, lineWidth: 2)
                        )
                    }
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
            )
        }
    }
}
