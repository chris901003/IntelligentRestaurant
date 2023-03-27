//
//  File.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import SwiftUI
import PhotosUI

struct MerchantAccountView: View {
    
    @StateObject var vm: MerchantAccountViewModel = MerchantAccountViewModel()
    @FocusState var editingIntro: Bool
    @State var isShowSelectLocationView: Bool = false
    @State var isShowResetAlert: Bool = false
    @State var deleteTrim: Double = 0.0
    
    let infoTitleWidth: CGFloat = 130
    let infoContentWidth: CGFloat = 190
    let infoHeight: CGFloat = 55
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.loginBackground
                
                VStack {
                    MerchantTopNavigationBarView(title: "我的帳號", titleImage: "person")
                    merchantPhoto
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            nameTextField
                            phoneNumberField
                            emailField
                            passwordField
                            locationField
                            introTextField
                            bottomButton
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 72)
            }
            .edgesIgnoringSafeArea(.top)
        }
        .overlay {
            if isShowSelectLocationView {
                SelectLocationView(isShowSelectLocationView: $isShowSelectLocationView, selectLocation: $vm.location)
            }
            if vm.isProgressing {
                LoadingView(waitingInfo: "處理中", isProgressView: true)
            }
            if vm.isProgressError {
                ErrorMessageShowView(message: vm.progressErrorMessage)
            }
            if isShowResetAlert {
                resetAlertNote
            }
            if vm.isShowSaveSuccess {
                checkAnimationMark
            }
        }
    }
    
    private var merchantPhoto: some View {
        PhotosPicker(selection: $vm.selectedImageItem, matching: .images) {
            VStack {
                if let imageData = vm.selectedImageData,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let image = vm.photo {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(Color.black)
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .padding(4)
            .background(
                Circle()
                    .foregroundColor(Color.white)
            )
        }
        .onChange(of: vm.selectedImageItem) { _ in
            Task { await vm.transferSelectedImage() }
        }
        .padding(.vertical)
    }
    
    private var nameTextField: some View {
        HStack {
            HStack {
                Image(systemName: "pencil.tip")
                Text("餐廳名稱")
            }
            .frame(width: infoTitleWidth)
            Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.theme.loginBackground)
            HStack {
                TextField("Great company", text: $vm.name)
                    .padding(.horizontal, 8)
            }
            .frame(width: infoContentWidth)
        }
        .font(.headline)
        .frame(height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color(hex: "#F2F1E1"))
        )
    }
    
    private var phoneNumberField: some View {
        HStack {
            HStack {
                Image(systemName: "phone.fill")
                Text("聯絡電話")
            }
            .frame(width: infoTitleWidth)
            Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.theme.loginBackground)
            HStack {
                TextField("02-12345678", text: $vm.phoneNumber)
                    .padding(.horizontal, 8)
            }
            .frame(width: infoContentWidth)
        }
        .font(.headline)
        .frame(height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color(hex: "#F2F1E1"))
        )
    }
    
    private var emailField: some View {
        HStack {
            HStack {
                Image(systemName: "envelope.fill")
                Text("電子信箱")
            }
            .frame(width: infoTitleWidth)
            Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.theme.loginBackground)
            HStack {
                TextField("name@gmail.com", text: $vm.emailAddress)
                    .padding(.horizontal, 8)
            }
            .frame(width: infoContentWidth)
        }
        .font(.headline)
        .frame(height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color(hex: "#F2F1E1"))
        )
    }
    
    private var passwordField: some View {
        HStack {
            HStack {
                Image(systemName: "lock.fill")
                Text("密碼")
            }
            .frame(width: infoTitleWidth)
            Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.theme.loginBackground)
            HStack {
                SecureField("輸入密碼", text: $vm.password)
                    .padding(.horizontal, 8)
                NavigationLink {
                    ZStack {
                        Color.theme.loginBackground
                        ChangePasswordView(password: $vm.password)
                    }
                    .edgesIgnoringSafeArea(.top)
                } label: {
                    Text("修改密碼")
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                        .frame(width: 70, height: infoHeight - 20)
                        .background(Color(hex: "#CC4D4D").opacity(0.5).cornerRadius(10))
                        .padding(.trailing, 8)
                }
            }
            .frame(width: infoContentWidth)
        }
        .font(.headline)
        .frame(height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color(hex: "#F2F1E1"))
        )
    }
    
    private var locationField: some View {
        HStack {
            HStack {
                Image(systemName: "map.fill")
                Text("位置")
            }
            .frame(width: infoTitleWidth)
            Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.theme.loginBackground)
            HStack {
                Text("@\(vm.location.latitude), \(vm.location.longitude)")
            }
            .frame(width: infoContentWidth)
            .onTapGesture { withAnimation { isShowSelectLocationView.toggle() } }
        }
        .font(.headline)
        .frame(height: infoHeight)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color(hex: "#F2F1E1"))
        )
    }
    
    private var introTextField: some View {
        VStack {
            Text("介紹")
                .font(.headline)
            TextEditor(text: $vm.intro)
                .opacity(vm.intro == "(增加更多資訊...)" ? 0.25 : 1)
                .focused($editingIntro)
                .onChange(of: editingIntro) { currentState in
                    if currentState && vm.intro == "(增加更多資訊...)" {
                        vm.intro = ""
                    } else if !currentState && vm.intro.count == 0{
                        vm.intro = "(增加更多資訊...)"
                    }
                }
                .frame(width: infoTitleWidth + infoContentWidth, height: 110)
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#F2F1E1"))
                .cornerRadius(10)
        }
    }
    
    private var bottomButton: some View {
        HStack(spacing: 32) {
            Text("確認變更")
                .foregroundColor(Color(hex: "#715428"))
                .font(.headline)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#715428").opacity(0.7), lineWidth: 3)
                )
                .onTapGesture { Task { await vm.changeMerchantAccount() } }
            Text("放棄編輯")
                .foregroundColor(Color(hex: "#715428"))
                .font(.headline)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#715428").opacity(0.7), lineWidth: 3)
                )
                .onTapGesture {
                    let isChange: Bool = vm.checkIsModify()
                    if isChange { isShowResetAlert.toggle() }
                }
            Text("刪除帳號")
                .foregroundColor(Color.pink)
                .font(.headline)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .trim(from: 0, to: deleteTrim)
                        .stroke(Color.pink, lineWidth: 3)
                )
                .onLongPressGesture(minimumDuration: 1.0) {
                    deleteTrim = 1
                    Task { await vm.deleteMerchantAccount() }
                } onPressingChanged: { state in
                    if state {
                        withAnimation(.linear(duration: 1.0)) {
                            deleteTrim = 1
                        }
                    } else{
                        withAnimation {
                            deleteTrim = 0
                        }
                    }
                }
        }
        .frame(width: infoTitleWidth + infoContentWidth)
        .padding(.bottom)
    }
    
    private var resetAlertNote: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .font(.title3)
                    .onTapGesture { isShowResetAlert.toggle() }
            }
            Text("確認放棄編輯")
                .font(.headline)
                .padding(.bottom, 4)
            Text("確認後不會保留當前更新資訊。")
                .font(.headline)
                .padding(.bottom, 32)
            
            HStack(spacing: 16) {
                Text("確認")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#715428"))
                    .padding(8)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#715428"), lineWidth: 3)
                    )
                    .onTapGesture {
                        vm.resetUserInfo()
                        isShowResetAlert.toggle()
                    }
                
                Text("回到編輯")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#715428"))
                    .padding(8)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#715428"), lineWidth: 3)
                    )
                    .onTapGesture { isShowResetAlert.toggle() }
            }
            .padding(.bottom)
        }
        .bold()
        .frame(width: 300)
        .padding(8)
        .background(Color.white)
        .background(
            Rectangle()
                .stroke(Color.black, lineWidth: 5)
                .blur(radius: 2)
        )
    }
    
    private var checkAnimationMark: some View {
        VStack {
            AnimatedCheckMarkView(animationDuration: 0.75, size: CGSize(width: 100, height: 100), strokeStyle: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
