//
//  MerchantTablePreviewView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import SwiftUI

struct MerchantTablePreviewView: View {
    
    @Binding var selectedTableIdx: String
    @Binding var selectedFoodIdx: String
    var tableIdx: String
    var tableInfos: [String: FoodStatusInfoModel]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tableInfos.keys.sorted(), id: \.self) { infoIdx in
                    if let foodStatusInfo = tableInfos[infoIdx] {
                        VStack(spacing: 0) {
                            Text(infoIdx)
                                .font(.caption)
                            VStack {
                                Text(foodStatusInfo.foodRemainTime.secToMin())
                                    .font(.subheadline)
                                Text(foodStatusInfo.foodRemain)
                                    .font(.caption)
                            }
                            .foregroundColor(Color.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .foregroundColor(Color(hex: "#5B3E3E"))
                            )
                            .onTapGesture {
                                selectedTableIdx = tableIdx
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    // 這裡存在淺在問題
                                    selectedFoodIdx = infoIdx
                                }
                            }
                        }
                        .bold()
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
        .frame(height: 65)
        .background(
            Rectangle()
                .foregroundColor(Color(hex: "#DCD1C3"))
        )
    }
}
