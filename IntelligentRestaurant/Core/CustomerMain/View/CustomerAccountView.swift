//
//  CustomerAccountView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import SwiftUI

struct CustomerAccountView: View {
    @StateObject var vm : CustomerAccountViewModel = CustomerAccountViewModel()
    
    @State var isShowUpdateAccount: Bool = false
    
    // 帳號頁面上的密碼
    @State var isShowOriginalPassword: Bool = false
    // 舊密碼, 新密碼, 確認新密碼
    @State var changeAccountItem: [String] = ["帳號名稱", "電子信箱", "舊密碼", "新密碼", "確認新密碼"]
    
    @State var accountIcon: [String] = ["person", "envelope", "lock"]
    @State var accountItem: [String] = ["帳號名稱", "電子信箱", "密碼"]
    
    var body: some View {
        ZStack {
            Color.theme.loginBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                // 頭貼（MARK: 還未增加可以選擇相片的功能）
                headStickerSection
                Spacer()
                bodySection
                Spacer()
            }
            
            // 如果要更改資料的話，就會彈出更改的視窗
            if isShowUpdateAccount {
                changeAccountSection
            }
            
            if vm.isProcess {
                LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
            }
            if vm.isProcessError {
                ErrorMessageShowView(message: vm.errorMessage)
            }
        }
    }
    
    private var headStickerSection : some View {
        Circle()
            .frame(width: 200)
            .foregroundColor(.white)
            .overlay {
                Image(systemName: "person")
                    .resizable()
                    .padding(50)
            }
            .padding(.top,10)
    }
    
    private var bodySection: some View {
        VStack{
            ForEach(accountIcon.indices, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(height: 60)
                        .foregroundColor(Color(hex: "#F2F1E1"))
                    
                    // 顯示個資的三個欄位
                    HStack {
                        Image(systemName: accountIcon[index]).frame(width: 10).padding(.leading,20)
                        Text(accountItem[index])
                            .multilineTextAlignment(.leading)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 100, height: 60, alignment: .leading)
                        
                        Rectangle()
                            .frame(width: 3)
                            .foregroundColor(Color.theme.loginBackground)
                        
                        if index == 0 {
                            Text(vm.customerInfo.name)
                                .frame(width: 180, alignment: .leading)
                        }
                        else if index == 1 {
                            Text(vm.customerInfo.email)
                                .frame(width: 180, alignment: .leading)
                        }
                        else {
                            HStack {
                                if isShowOriginalPassword {
                                    Text(vm.customerInfo.password)
                                } else {
                                    Text("*************")
                                }
                                Spacer()
                                Button {
                                    isShowOriginalPassword.toggle()
                                } label: {
                                    Image(systemName: isShowOriginalPassword ? "eye" : "eye.slash")
                                        .foregroundColor(.black)
                                        .padding()
                                }
                            }.frame(width: 180)
                        }
                        
                    }
                }
                .frame(height: 100)
                .padding(10)
            }
            
            // 按鈕"變更資料"
            Button {
                // 彈出"要更改資料"的視窗
                withAnimation { isShowUpdateAccount.toggle() }
            } label: {
                Text("修改資訊")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "715428"))
                    .frame(width: 110, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "715428"), lineWidth: 2)
                    )
            }
        }
    }
    
    private var changeAccountSection: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture {
                    withAnimation {
                        isShowUpdateAccount.toggle()
                    }
                }
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 300, height:500)
                .shadow(radius: 10, x: 10, y: 10)
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation { isShowUpdateAccount.toggle() }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                    }
                }
                
                // 修改帳號的介面
                ForEach(changeAccountItem.indices, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.theme.loginBackground, lineWidth: 2)
                            .frame(height: 60)
                        HStack {
                            Text(changeAccountItem[index])
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(width: 100, height: 60)
                            
                            Rectangle()
                                .frame(width: 2, height: 60)
                                .foregroundColor(Color.theme.loginBackground)
                            
                            if changeAccountItem[index] == "帳號名稱" {
                                TextField(vm.customerInfo.name, text: $vm.newCustomerInfo.name)
                                    .autocorrectionDisabled(true)
                            } else if changeAccountItem[index] == "電子信箱" {
                                TextField(vm.customerInfo.email, text: $vm.newCustomerInfo.email)
                                    .autocorrectionDisabled(true)
                            } else if changeAccountItem[index] == "舊密碼" {
                                PasswordInputBox(info: $vm.oldPassword, message: "輸入舊密碼")
                            } else if changeAccountItem[index] == "新密碼" {
                                PasswordInputBox(info: $vm.newCustomerInfo.password, message: "輸入新密碼")
                            } else if changeAccountItem[index] == "確認新密碼" {
                                PasswordInputBox(info: $vm.newPasswordConfirm, message: "確認新密碼")
                            }
                        }
                    }.padding(5)
                }
                
                HStack {
                    Button {
                        Task {
                            if await vm.updateCustomerAccount() {
                                isShowUpdateAccount.toggle()
                            }
                        }
                    } label: {
                        Text("確認更改")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "715428"))
                            .frame(width: 100, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "715428"), lineWidth: 2)
                            )
                    }
                    
                    Button {
                        vm.newCustomerInfo = vm.customerInfo
                        withAnimation { isShowUpdateAccount.toggle() }
                    } label: {
                        Text("取消")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "715428"))
                            .frame(width: 100, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "715428"), lineWidth: 2)
                            )
                    }
                }
            }
            .frame(width: 300, height: 200)
        }
    }
}

fileprivate struct PasswordInputBox: View {
    
    @Binding var info: String
    @State var isShowPassword: Bool = false
    var message: String
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isShowPassword {
                    TextField(message, text: $info)
                        .autocorrectionDisabled(true)
                } else {
                    SecureField(message, text: $info)
                }
            }
            .padding(.trailing, 32)
            Button {
                isShowPassword.toggle()
            } label: {
                Image(systemName: isShowPassword ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
