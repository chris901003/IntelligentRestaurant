//
//  CreateAccountView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/8.
//

import Foundation
import SwiftUI
import PhotosUI

struct CreateMerchantAccountView: View {
    
    @Environment(\.dismiss) var dismissView
    @StateObject var vm: CreateMerchantAccountViewModel = CreateMerchantAccountViewModel()
    
    let infoTitleWidth: CGFloat = 100
    let infoWidth: CGFloat = 300
    let infoHeight: CGFloat = 50
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground
                .ignoresSafeArea(.all)
            backgroundView
            
            VStack(spacing: 0) {
                topBarInfo
                merchantPhoto
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        merchantName
                        merchantMail
                        merchantPassword
                        merchantPasswordConfirm
                        merchantLocation
                    }
                    .padding(.top, 64)
                }
                
                confirmButton
                haveAccount
                Spacer()
            }
        }
        .overlay {
            if vm.isShowMap {
                SelectLocationView(isShowSelectLocationView: $vm.isShowMap, selectLocation: $vm.location)
            }
        }
        .overlay {
            if vm.isProgressing {
                LoadingView(waitingInfo: "創建中", isProgressView: true)
            }
            if vm.isProgressError {
                ErrorMessageShowView(message: vm.progressErrorMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var backgroundView: some View {
        ZStack {
            VStack {
                Ellipse()
                    .foregroundColor(Color(hex: "#F1EDE7"))
                    .frame(width: 479, height: 393)
                    .offset(y: -35)
                Spacer()
            }
            VStack {
                Rectangle()
                    .foregroundColor(Color.theme.loginBackground)
                    .frame(height: 60)
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private var topBarInfo: some View {
        HStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 124, height: 124)
            
            Text("建立新帳號")
                .font(.title2)
                .bold()
            Spacer()
        }
        .padding(.leading, 32)
    }
    
    private var merchantPhoto: some View {
        PhotosPicker(selection: $vm.selectedPhotoItem) {
            VStack {
                if let imageData = vm.selectedPhotoData,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.black)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .padding(4)
            .background(
                Circle()
                    .foregroundColor(Color(hex: "#797979"))
            )
        }
        .onChange(of: vm.selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem!.loadTransferable(type: Data.self) {
                    vm.selectedPhotoData = data
                }
            }
        }
    }
    
    private var merchantName: some View {
        HStack {
            HStack {
                Image(systemName: "person")
                Text("餐廳名稱")
            }
            .frame(width: infoTitleWidth, alignment: .leading)
            .padding(.horizontal, 8)
            Rectangle()
                .frame(width: 3, height: infoHeight)
                .foregroundColor(Color.white)
            TextField("xxx 餐廳", text: $vm.name)
                .autocorrectionDisabled(false)
            Spacer()
        }
        .frame(width: infoWidth, height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal, 32)
    }
    
    private var merchantMail: some View {
        HStack {
            HStack {
                Image(systemName: "envelope.fill")
                Text("電子信箱")
            }
            .frame(width: infoTitleWidth, alignment: .leading)
            .padding(.horizontal, 8)
            Rectangle()
                .frame(width: 3, height: infoHeight)
                .foregroundColor(Color.white)
            TextField("name@gmail.com", text: $vm.email)
                .autocorrectionDisabled(false)
            Spacer()
        }
        .frame(width: infoWidth, height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal, 32)
    }
    
    private var merchantPassword: some View {
        HStack {
            HStack {
                Image(systemName: "lock.fill")
                Text("密碼")
            }
            .frame(width: infoTitleWidth, alignment: .leading)
            .padding(.horizontal, 8)
            Rectangle()
                .frame(width: 3, height: infoHeight)
                .foregroundColor(Color.white)
            SecureField("", text: $vm.password)
            Spacer()
        }
        .frame(width: infoWidth, height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal, 32)
    }
    
    private var merchantPasswordConfirm: some View {
        HStack {
            HStack {
                Image(systemName: "lock.fill")
                Text("確認密碼")
            }
            .frame(width: infoTitleWidth, alignment: .leading)
            .padding(.horizontal, 8)
            Rectangle()
                .frame(width: 3, height: infoHeight)
                .foregroundColor(Color.white)
            SecureField("", text: $vm.confirmPassword)
            Spacer()
            Image(systemName: vm.isPasswordSame ? "checkmark" : "xmark")
                .padding(8)
                .foregroundColor(vm.isPasswordSame ? Color.green : Color.pink)
        }
        .frame(width: infoWidth, height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal, 32)
    }
    
    private var merchantLocation: some View {
        HStack {
            HStack {
                Image(systemName: "map.fill")
                Text("位置")
            }
            .frame(width: infoTitleWidth, alignment: .leading)
            .padding(.horizontal, 8)
            Rectangle()
                .frame(width: 3, height: infoHeight)
                .foregroundColor(Color.white)
            Text("@\(vm.location.latitude.description), \(vm.location.longitude.description)")
            Spacer()
        }
        .frame(width: infoWidth, height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal, 32)
        .onTapGesture { withAnimation { vm.isShowMap.toggle() } }
    }
    
    private var confirmButton: some View {
        Button {
            Task {
                let result = await vm.createNewAccount()
                if result { await MainActor.run { dismissView() } }
            }
        } label: {
            Text("確認")
                .font(.title3)
                .bold()
                .foregroundColor(Color.white)
                .padding(12)
                .padding(.horizontal, 20)
                .background(Color.theme.buttonBackground)
                .cornerRadius(30)
                .opacity(vm.isPasswordSame ? 1 : 0.3)
        }
        .padding(.vertical, 8)
        .disabled(!vm.isPasswordSame)
    }
    
    private var haveAccount: some View {
        Text("我已有帳號")
            .font(.headline)
            .underline()
            .onTapGesture { dismissView() }
    }
}
