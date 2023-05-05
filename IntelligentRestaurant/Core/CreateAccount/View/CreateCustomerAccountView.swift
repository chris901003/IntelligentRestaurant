//
//  CreateCustomerAccountView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import SwiftUI

struct CreateCustomerAccountView: View {
    
    @StateObject var vm: CreateCustomerAccountViewModel = CreateCustomerAccountViewModel()
    @Environment(\.dismiss) var dismissView
    
    @State var registerItem: [String] = ["姓名", "電子信箱", "密碼", "確認密碼"]
    @State var registerIcon: [String] = ["person", "envelope.fill", "lock.fill", "lock.fill"]
    
    @State var showPassword: [Bool] = [false, false]
    
    var body: some View {
        ZStack {
            // navigation bar 最上面的 top bar
            topBarSection
            // 背景
            topBarBackground
            // 主要畫面
            bodySection
            
            if vm.isProcess {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.errorMessage)
            }
        }
    }
    
    private var topBarSection: some View {
        Color.theme.loginBackground.edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    HStack {
                        Image("Logo")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .padding(-30)
                        Text("建立新帳號")
                            .font(.title2)
                            .bold()
                    }
            )

    }
    
    private var topBarBackground: some View {
        VStack {
            Circle()
                .foregroundColor(Color(hex: "FFFFFF"))
                .opacity(0.6)
                .frame(width: 800)
                .padding(.top, -550)
            Spacer()
        }
    }
    
    private var bodySection: some View {
        VStack {
            Spacer()
            Spacer()
            
            Circle()
                .foregroundColor(Color(hex: "797979"))
                .frame(width: 180)
                .overlay {
                    Image(systemName: "person")
                        .resizable()
                        .padding(40)
                        .foregroundColor(.white)
                }
            Spacer()
            Spacer()
            
            // 四個textfield
            ForEach(0..<4) { index in
                TextFieldForRegister(
                    index: index,
                    accountInform: $vm.accountInform,
                    showPassword: $showPassword,
                    registerItem: $registerItem,
                    registerIcon: $registerIcon
                )
                Spacer()
            }
            
            // "確認"與"我已有帳號"判斷入口，
            // 也會判斷填寫帳號、信箱、密碼是否有誤
            VStack {
                // "確認"的按鈕
                Button{
                    // MARK: 判斷帳號正確性 + 存值進後端
                    // 如果下次登出的話，會回到主畫面
                    Task {
                        let createResult = await vm.createCustomerAccount()
                        if createResult { dismissView() }
                    }
                }label: {
                    Text("確認")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }
                .frame(width: 100, height: 40)
                .background {
                    Color(hex: "#715428")
                        .opacity(0.7)
                }
                .cornerRadius(30)
                .disabled(!vm.isCanLogin)
                
                // "我已有帳號"的按鈕
                Button {
                    dismissView()
                } label: {
                    Text("我已有帳號")
                        .underline()
                        .foregroundColor(.black)
                        .frame(height: 30)
                        .fontWeight(.semibold)
                }
                
                // 如果vm.isCanLogin = false，會跳紅色提醒
                Text(vm.isCanLogin ? "" : "資訊需正確(填寫資訊完整、信箱格式、密碼需一致)")
                    .foregroundColor(.red)
                    .frame(height: 10)
                    .padding(5)
            }
            Spacer()
        }
    }
}

fileprivate struct TextFieldForRegister: View {
    @EnvironmentObject var vm: MainViewModel
    
    var index: Int
    @Binding var accountInform: [String]
    @Binding var showPassword: [Bool]
    @Binding var registerItem: [String]
    @Binding var registerIcon: [String]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .frame(width: 320, height: 50)
            .overlay {
                HStack{
                    Image(systemName: registerIcon[index])
                        .frame(width: 40, alignment: .trailing)
                    Text(registerItem[index])
                        .frame(width: 80, alignment: .leading)
                    Rectangle()
                        .frame(width: 3)
                        .foregroundColor(Color(hex: "FFFEF2"))
                    
                    // 姓名與電子信箱
                    if index<2 {
                        TextField("\(registerItem[index])...", text: $accountInform[index])
                            .autocorrectionDisabled(true)
                        
                    // 密碼與確認密碼
                    } else {
                        if showPassword[index-2] {
                            TextField("\(registerItem[index])...", text: $accountInform[index])
                                .autocorrectionDisabled(true)
                        } else {
                            SecureField("\(registerItem[index])...", text: $accountInform[index])
                        }
                        
                        Button {
                            showPassword[index-2].toggle()
                        } label: {
                            Image(systemName: showPassword[index-2] ? "eye" : "eye.slash")
                                .padding()
                        }
                    
                    }
                }
                .foregroundColor(.black)
                .font(.headline)
            }
            .fontWeight(.bold)
            .foregroundColor(Color.theme.loginBackground)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(hex: "FFFEF2"), lineWidth: 6)
            )
    }
}
