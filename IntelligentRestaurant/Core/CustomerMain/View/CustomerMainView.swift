//
//  CustomerMainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import SwiftUI


struct CustomerMainView: View {
    @State var sidebarPressed: Bool = false
    @State var title: String = "主頁"
    @State var icon: String = "house.fill"
    @State var selectedTab = "search"
    
    @State var selectedTabItem: [String] = ["main", "search", "favorite", "account"]
    
    // side bar menu
    @State var menuSidebarItem: [String] = ["主頁", "店家查詢", "最愛店家", "帳號"]
    @State var menuSidebarIcon: [String] = ["house", "magnifyingglass", "star", "person"]
    
    @State var checkToLogOut: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                Color.theme.loginBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // 最上面的top bar
                    TopBarItem(sidebarPressed: $sidebarPressed, title: $title, icon: $icon)
                    
                    ZStack {
                        TabView(selection: $selectedTab)  {
                            // 左下方的主頁tabview
                            CustomerHomeView()
                                .tabItem {
                                    Image(systemName: "house.fill")
                                    Text("主頁")
                                }
                                .onAppear{
                                    title = "主頁"
                                    icon = "house.fill"
                                    sidebarPressed = false
                                }
                                .tag("main")
                            
                            // 中下方的tabview
                            CustomerSearchView()
                                .tabItem {
                                    Image(systemName: "magnifyingglass")
                                    Text("店家查詢")
                                }
                                .tag("search")
                                .onAppear{
                                    title = "店家查詢"
                                    icon = "fork.knife"
                                    sidebarPressed = false
                                }
                            
                            CustomerFavoriteView(selectedTab: $selectedTab)
                                .tabItem {
                                    Image(systemName: "star")
                                    Text("最愛店家")
                                }
                                .tag("favorite")
                                .onAppear {
                                    title = "最愛店家"
                                    icon = "star"
                                    sidebarPressed = false
                                }
                            
                            // 右下方的帳號tabview
                            CustomerAccountView()
                                .tabItem {
                                    Image(systemName: "person")
                                    Text("帳號")
                                }
                                .tag("account")
                                .onAppear{
                                    title = "我的帳號"
                                    icon = "person.fill"
                                    sidebarPressed = false
                                }
                        }
                        .onAppear() {
                            UITabBar.appearance().backgroundColor = .white
                        }
                        .disabled(checkToLogOut)
                        
                        // 如果點擊side bar的按鈕，會打開side bar欄
                        if sidebarPressed {
                            TopSideBarMenu
                                .disabled(checkToLogOut)
                        }
                    
                        // 二次確認是否要登出
                        if checkToLogOut {
                            logoutAlertSection
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var TopSideBarMenu: some View {
        NavigationStack {
            HStack {
                Spacer()
                VStack {
                    VStack(alignment: .leading) {
                        // "我的帳號"和"查詢店家"按鈕
                        ForEach(0..<4) { index in
                            Button {
                                selectedTab = selectedTabItem[index]
                                title = menuSidebarItem[index]
                                icon = menuSidebarIcon[index]
                                sidebarPressed.toggle()
                            } label: {
                                HStack {
                                    Text(menuSidebarItem[index])
                                    Spacer()
                                    Image(systemName: menuSidebarIcon[index])
                                }
                            }
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            Divider()
                        }
                        // 登出
                        Button {
                            checkToLogOut.toggle()
                        } label: {
                            HStack {
                                Text("登出")
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        Divider()
                    }
                    .padding()
                    .frame(width: 160)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                    )
                    Spacer()
                }
            }
        }
    }
    
    private var logoutAlertSection: some View {
        VStack{
            Text("您選擇要登出？")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            HStack {
                Button {
                    CustomerShareInfoManager.instance.clearAll()
                    CustomerShareInfoManager.instance.isLogin.toggle()
                } label: {
                    Text("確認登出")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                        }
                }
                
                Button {
                    sidebarPressed.toggle()
                    checkToLogOut.toggle()
                } label: {
                    Text("取消")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 2)
                        }
                }
            }
            .foregroundColor(.black)
            .frame(height: 25)
        }
        .shadow(radius: 10)
        .frame(width: 200, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(hex: "#ECD2D2"))
        )
    }
}

// top bar
struct TopBarItem: View {
    
    @Binding var sidebarPressed: Bool
    @Binding var title: String
    @Binding var icon: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(hex: "C3B7A9"))
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 35, height: 30)
                    .padding(.leading, 20)
                Text(title)
                    .frame(width: 100, alignment: .leading)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                // top bar 右上角三條線的按鈕
                ZStack{
                    Rectangle()
                        .foregroundColor(.white).opacity(0.7)
                    Button {
                        withAnimation { sidebarPressed.toggle() }
                    } label: {
                        VStack {
                            ForEach(0..<3) { times in
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(height: 8)
                                    .foregroundColor(Color(hex: "363636").opacity(0.6))
                            }
                        }
                        .padding(3)
                    }
                }.frame(width: 60)
            }
        }
        .frame(height: 60)
    }
}
