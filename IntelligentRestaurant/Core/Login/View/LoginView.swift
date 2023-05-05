//
//  LoginView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/8.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    @StateObject var vm: LoginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.loginBackground
                
                VStack {
                    logoImage
                    accountTextField
                    passwordField
                    saveAccount
                    confirmButton
                    createNewAccountLink
                    biometricsLoginButton
                    
                    Spacer()
                }
            }
            .overlay {
                if vm.isProcessing {
                    LoadingView(waitingInfo: "登陸中...", isProgressView: true)
                }
            }
            .overlay {
                if vm.isProcessingError {
                    ErrorMessageShowView(message: vm.processingErrorMessage)
                }
            }
            .overlay {
                if vm.isShowSelectCreateAccountMode {
                    selectCreateMode
                }
            }
            .ignoresSafeArea(.all)
        }
    }
    
    private var logoImage: some View {
        Image("Logo")
            .resizable()
            .scaledToFill()
            .frame(width: 150, height: 150)
            .padding(32)
            .background(Color.theme.loginInfoBackground)
            .clipShape(Circle())
            .padding()
            .padding(.top, 90)
            .padding(.bottom, 16)
    }
    
    private var accountTextField: some View {
        HStack(spacing: 0) {
            Text("帳號")
                .padding(.horizontal)
                .frame(width: 110)
            Rectangle()
                .frame(width: 3)
                .foregroundColor(Color.theme.loginBackground)
            TextField("", text: $vm.account)
                .padding(.horizontal)
            Spacer()
        }
        .font(.title3)
        .bold()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color.theme.loginInfoBackground)
        )
        .frame(height: 65)
        .padding(.horizontal)
        .padding(.bottom, 28)
    }
    
    private var passwordField: some View {
        HStack(spacing: 0) {
            Text("密碼")
                .padding(.horizontal)
                .frame(width: 110)
            Rectangle()
                .frame(width: 3)
                .foregroundColor(Color.theme.loginBackground)
            SecureField("", text: $vm.password)
                .padding(.horizontal)
            Spacer()
            Button {
                vm.password = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .padding(.horizontal)
                    .foregroundColor(Color.black)
                    .opacity(vm.password == "" ? 0 : 0.8)
            }
            .disabled(vm.password == "")
        }
        .font(.title3)
        .bold()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundColor(Color.theme.loginInfoBackground)
        )
        .frame(height: 65)
        .padding(.horizontal)
    }
    
    private var saveAccount: some View {
        HStack {
            Spacer()
            Image(systemName: vm.isRememberAccount ? "checkmark.square" : "square")
            Text("保存資料(下次可用辨識登陸)")
        }
        .onTapGesture { vm.isRememberAccount.toggle() }
        .padding(.bottom, 32)
        .padding(.trailing)
    }
    
    private var confirmButton: some View {
        Button {
            Task { await vm.login() }
        } label: {
            Text("確認")
                .font(.title3)
                .bold()
                .foregroundColor(Color.white)
                .padding(12)
                .padding(.horizontal, 20)
                .background(Color.theme.buttonBackground)
                .cornerRadius(30)
                .opacity(vm.account == "" ? 0.3 : 1)
        }
        .disabled(vm.account == "")
    }
    
    private var createNewAccountLink: some View {
        Text("建立一個新帳號")
            .font(.headline)
            .underline()
            .onTapGesture {
                withAnimation {
                    vm.isShowSelectCreateAccountMode.toggle()
                }
            }
            .padding(.bottom)
    }
    
    private var biometricsLoginButton: some View {
        Button {
            Task { await vm.authenticateWithBiometrics() }
        } label: {
            HStack {
                if vm.biometryType == .faceID && vm.isLoginBefore {
                    Image(systemName: "faceid")
                    Text("透過Face ID登錄")
                } else if vm.biometryType == .touchID && vm.isLoginBefore {
                    Image(systemName: "touchid")
                    Text("透過Touch ID登錄")
                } else {
                    Text("無法使用生物辨識方式登陸")
                }
            }
            .padding()
            .padding(.horizontal)
            .foregroundStyle(Color.black)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(Color.brown.gradient)
            )
            .opacity(vm.isLoginBefore && (vm.biometryType != .none) ? 1 : 0.3)
        }
        .disabled(!(vm.isLoginBefore && (vm.biometryType != .none)))
    }
    
    private var selectCreateMode: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { withAnimation { vm.isShowSelectCreateAccountMode.toggle() } }
            
            VStack {
                HStack {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(Color.theme.loginBackground)
                        .padding(8)
                        .background( Circle() .foregroundColor(Color.theme.loginBackground) )
                        .padding()
                    Spacer()
                }
                VStack {
                    NavigationLink {
                        CreateCustomerAccountView()
                    } label: {
                        Text("我不是店家")
                            .foregroundColor(Color.black)
                            .padding(.horizontal)
                            .frame(width: 200, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 228/255, green: 154/255, blue: 154/255, opacity: 0.74))
                            )
                    }
                    Spacer()
                    NavigationLink {
                        CreateMerchantAccountView()
                    } label: {
                        Text("我是店家")
                            .foregroundColor(Color.black)
                            .padding(.horizontal)
                            .frame(width: 200, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 228/255, green: 154/255, blue: 154/255, opacity: 0.19))
                            )
                    }
                }
                .font(.title3)
                .bold()
                .padding()
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.white)
                )
            }
            .transition(AnyTransition.scale)
        }
    }
}
