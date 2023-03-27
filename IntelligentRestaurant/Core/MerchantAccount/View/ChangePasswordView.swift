//
//  ChangePasswordView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/12.
//

import Foundation
import SwiftUI

struct ChangePasswordView: View {
    
    @Environment(\.dismiss) var dismissView
    @StateObject var vm: ChangePasswordViewModel
    
    @Binding var password: String
    let infoTitleWidth: CGFloat = 130
    let infoContentWidth: CGFloat = 190
    let infoHeight: CGFloat = 55
    
    init(password: Binding<String>) {
        self._password = Binding(projectedValue: password)
        self._vm = StateObject(wrappedValue: ChangePasswordViewModel())
    }
    
    var body: some View {
        VStack {
            MerchantTopNavigationBarView(title: "修改密碼", titleImage: "lock.fill")
                .padding(.bottom, 64)
            
            oldPasswordField
                .padding(.bottom, 32)
            
            newPasswordField
                .padding(.bottom, 32)
            
            bottomButton
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding(.top, 72)
        .overlay {
            if vm.isProgressing {
                LoadingView(waitingInfo: "密碼更新中")
            }
            if vm.isProgressError {
                ErrorMessageShowView(message: vm.progressErrorMessage)
            }
        }
    }
    
    private var oldPasswordField: some View {
        VStack {
            Text("請輸入舊密碼")
                .font(.title3)
                .bold()
                .foregroundColor(Color(hex: "#7B7B7B"))
            
            HStack {
                Text("舊密碼")
                    .font(.title3)
                    .frame(width: infoTitleWidth)
                Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 3)
                SecureField("輸入舊密碼", text: $vm.oldPassword)
                    .frame(width: infoContentWidth)
            }
            .bold()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white, lineWidth: 3)
            )
            .frame(height: infoHeight)
        }
    }
    
    private var newPasswordField: some View {
        VStack {
            Text("請輸入新密碼")
                .font(.title3)
                .bold()
                .foregroundColor(Color(hex: "7B7B7B"))
            
            HStack {
                Text("新密碼")
                    .font(.title3)
                    .frame(width: infoTitleWidth)
                Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 3)
                SecureField("輸入新密碼", text: $vm.newPassword)
                    .frame(width: infoContentWidth)
            }
            .bold()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white, lineWidth: 3)
            )
            .frame(height: infoHeight)
            .padding(.bottom)
            
            HStack {
                Text("確認新密碼")
                    .font(.title3)
                    .frame(width: infoTitleWidth)
                Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 3)
                HStack {
                    SecureField("確認新密碼", text: $vm.confirmNewPassword)
                    Image(systemName: vm.isConfirmNewPasswordValid ? "checkmark" : "xmark")
                        .foregroundColor(vm.isConfirmNewPasswordValid ? Color.green : Color.red)
                        .bold()
                        .padding(.trailing)
                }
                .frame(width: infoContentWidth)
            }
            .bold()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white, lineWidth: 3)
            )
            .frame(height: infoHeight)
        }
    }
    
    private var bottomButton: some View {
        HStack(spacing: 24) {
            Button {
                Task {
                    let result = await vm.changePassword()
                    if result {
                        await MainActor.run {
                            password = vm.newPassword
                            dismissView()
                        }
                    }
                }
            } label: {
                Text("更新密碼")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#715428").opacity(0.7))
                    .frame(width: infoTitleWidth - 20, height: infoHeight - 15)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#715428").opacity(0.7), lineWidth: 3)
                    )
                    .opacity(vm.isConfirmNewPasswordValid ? 1 : 0.3)
            }
            .disabled(!vm.isConfirmNewPasswordValid)
            
            Text("取消")
                .font(.headline)
                .foregroundColor(Color(hex: "#715428").opacity(0.7))
                .frame(width: infoTitleWidth - 20, height: infoHeight - 15)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#715428").opacity(0.7), lineWidth: 3)
                )
                .onTapGesture { dismissView() }
        }
    }
}
