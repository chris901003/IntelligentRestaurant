//
//  MerchantFoodDetailView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/3/11.
//

import Foundation
import SwiftUI
import Charts

struct MerchantFoodDetailView: View {
    
    var foodInfo: FoodStatusInfoModel
    var chartInfo: [FoodStatusChartModel]
    
    init(foodInfo: FoodStatusInfoModel) {
        self.foodInfo = foodInfo
        self.chartInfo = foodInfo.convertToFoodStatusChartModel()
    }
    
    var body: some View {
        VStack {
            remainTimeInfo
            foodTypeInfo
            foodRemainInfo
            remainAndRemainTimeChart
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var remainTimeInfo: some View {
        HStack {
            Text("剩餘時間")
                .padding(.horizontal)
            Text("\(foodInfo.foodRemainTime.secToMin())分鐘")
                .padding(.horizontal)
                .padding(.vertical, 8)
                .foregroundColor(Color.white)
                .background(Color(hex: "#ABA399"))
        }
        .font(.headline)
        .background(Color(hex: "#DCD1C3"))
        .cornerRadius(10)
        .padding(.vertical)
    }
    
    private var foodTypeInfo: some View {
        HStack(spacing: 48) {
            Text("食物類別")
            Text(foodInfo.name)
                .foregroundColor(Color.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(hex: "#ABA399"))
                )
        }
        .font(.headline)
        .padding(.bottom)
    }
    
    private var foodRemainInfo: some View {
        HStack(spacing: 48) {
            Text("食物剩餘量")
            Text(foodInfo.foodRemain)
                .foregroundColor(Color.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(hex: "ABA399"))
                )
        }
        .font(.headline)
        .padding(.bottom)
    }
    
    private var remainAndRemainTimeChart: some View {
        Chart {
            ForEach(chartInfo) { remainInfo in
                LineMark(
                    x: .value("時間", remainInfo.time),
                    y: .value("剩餘量", remainInfo.remain)
                )
                .foregroundStyle(Color.black)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
        }
        .frame(width: 280, height: 230)
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYAxisLabel(position: .leading, alignment: .center) {
            Text("剩餘量%")
                .font(.subheadline)
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {
            Text("總花費時間(秒)")
                .font(.subheadline)
        }
    }
}
