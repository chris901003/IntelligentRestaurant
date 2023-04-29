//
//  AlertTrainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/4/29.
//

import SwiftUI

struct AlertTrainView: View {
    
    @StateObject var vm: AlertTrainViewModel = AlertTrainViewModel()
    @Binding var isShowTrainAlert: Bool
    let alertInfo: TrainQueryResultModel
    
    var body: some View {
        ZStack {
            VStack {
                Text("尚有模型在訓練中")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 32)
                Text("類型: \(alertInfo.trainType.rawValue)")
                Text("開始時間: \(alertInfo.startTime.description)")
                    .padding(.bottom, 8)
                VStack {
                    Text("由於資源有限，一次只能訓練一種階段模型")
                    Text("若要停止當前正在訓練的模型，請按下方暫停")
                }
                .foregroundColor(Color.secondary)
                .font(.subheadline)
                .padding(.bottom)
                
                HStack(spacing: 32) {
                    HStack {
                        Image(systemName: "arrowshape.backward.fill")
                            .foregroundColor(Color.blue)
                        Text("返回")
                    }
                    .padding(8)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue, lineWidth: 3)
                    )
                    .onTapGesture { isShowTrainAlert.toggle() }
                    HStack {
                        Text("暫停")
                        Image(systemName: "stop.fill")
                            .foregroundColor(Color.pink)
                    }
                    .padding(8)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.pink, lineWidth: 3)
                    )
                    .onTapGesture {
                        Task {
                            await vm.stopTrain()
                            isShowTrainAlert.toggle()
                        }
                    }
                }
                .bold()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.white.shadow(.drop(radius: 5)))
            )
        }
        if vm.isProcess {
            LoadingView(waitingInfo: vm.loadingMessage, isProgressView: true)
        }
        if vm.isProcessError {
            ErrorMessageShowView(message: vm.processErrorMessage)
        }
    }
}
