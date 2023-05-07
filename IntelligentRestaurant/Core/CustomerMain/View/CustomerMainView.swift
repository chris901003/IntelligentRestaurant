//
//  CustomerMainView.swift
//  IntelligentRestaurant
//
//  Created by 黃弘諺 on 2023/5/5.
//

import SwiftUI


struct CustomerMainView: View {
    @StateObject var vm = CustomerSearchViewModel()
    @StateObject var homevm = CustomerHomeViewModel()
    
    @State var sidebarPressed: Bool = false
    @State var title: String = "主頁"
    @State var icon: String = "house.fill"
    @State var selectedTab = "main"
    
    @State var selectedTabItem: [String] = ["main", "account", "search"]
    
    // side bar menu
    @State var menuSidebarItem: [String] = ["我的帳號", "店家查詢", "最愛店家", "登出"]
    @State var menuSidebarIcon: [String] = ["person.fill", "magnifyingglass", "star.fill", "rectangle.portrait.and.arrow.right"]
    
    @State var checkToLogOut: Bool = false
    @State var myFavPressed: Bool = false
    @State var checkMyFavPressed: Bool = false
    
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
                                    if sidebarPressed {
                                        sidebarPressed.toggle()
                                    }
                                }
                                .onAppear{
                                    // 即時更新
                                    CustomerShareInfoManager.instance.homeTable.merchantName = CustomerShareInfoManager.instance.homeTable.merchantName
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
                                    if sidebarPressed {
                                        sidebarPressed.toggle()
                                    }
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
                                    if sidebarPressed {
                                        sidebarPressed.toggle()
                                    }
                                }
                        }
                        .onAppear() {
                            UITabBar.appearance().backgroundColor = .white
                        }
                        .disabled(checkToLogOut)
                        
                        if myFavPressed {
                            Rectangle()
                                .foregroundColor(Color(hex: "DCD1C3"))
                            VStack {
                                HStack {
                                    Button {
                                        // 取消的話回到主畫面
                                        selectedTab = selectedTabItem[0]
                                        myFavPressed = false
                                    } label: {
                                        Image(systemName: "arrowshape.turn.up.left.fill")
                                        Text("取消").fontWeight(.bold)
                                    }
                                    .foregroundColor(Color(hex: "CC4D4D"))
                                    .font(.title3)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "CC4D4D"), lineWidth: 2)
                                    )
                                    .padding()
                                    
                                    Spacer()
                                }
                                
                                ScrollView {
                                    ForEach(vm.myFavMerchants.indices, id: \.self) { index in
                                        HStack {
                                            Button {
                                                homevm.getTableInfo(merchantUid: vm.myFavMerchants[index].uid)
                                                checkMyFavPressed.toggle()
                                            } label: {
                                                Circle()
                                                    .foregroundColor(.gray)
                                                    .opacity(0.5)
                                                    .overlay{
                                                        Image(systemName: "person.fill")
                                                    }
                                                
                                                Text(vm.myFavMerchants[index].name).font(.title2)
                                                
                                                Spacer()
                                                
                                                Text(vm.myFavMerchants[index].location) // 放地址
                                                    .font(.callout)
                                                    .foregroundColor(.black)
                                                    .opacity(0.7)
                                                    .frame(width: 80)
                                            }
                                            .foregroundColor(.black)
                                            
                                            
                                            Button {
//                                                vm.deleteMyFavItem(customerUid: vm.myFavMerchants[index].customerUid, merchantUid: vm.myFavMerchants[index].uid)
//                                                vm.myFavMerchants[index].favorite.toggle()
                                            } label: {
                                                Image(systemName: vm.myFavMerchants[index].favorite ? "star.fill" : "star")
                                            }
                                            .frame(width: 30)
                                            .foregroundColor(Color(hex: "CC4D4D"))
                                        }
                                        .frame(height: 60)
                                        .padding(5)
                                        Divider()
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .disabled(checkToLogOut)
                        }
                        
                        if checkMyFavPressed {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color.white)
                                    .shadow(radius: 10)
                                VStack {
                                    Text("確定要選擇此店家？")
                                        .font(.title3)
                                    HStack {
                                        Button {
                                            checkMyFavPressed.toggle()
                                            // 跳到查詢頁面
                                            selectedTab = selectedTabItem[0]
                                            myFavPressed = false
                                        } label: {
                                            Text("確認")
                                                .padding()
                                                .background {
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .stroke(Color.black, lineWidth: 2)
                                                }
                                        }
                                        
                                        Button {
                                            checkMyFavPressed.toggle()
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
                                .padding(5)
                            }
                            .frame(width: 200, height: 150)
                            .disabled(checkToLogOut)
                        }
                        
                        // 如果點擊side bar的按鈕，會打開side bar欄
                        if sidebarPressed {
                            TopSideBarMenu
                                .disabled(checkToLogOut)
                        }
                    
                        // 二次確認是否要登出
                        if checkToLogOut {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color(hex: "ECD2D2"))
                                VStack{
                                    Text("您選擇要登出？")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding()
                                    HStack {
                                        Button {
                                            CustomerShareInfoManager.instance.clearAll()
                                            myFavPressed = false
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
                            }
                            .shadow(radius: 10)
                            .frame(width: 200, height: 150)
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        VStack(alignment: .leading) {
                            // "我的帳號"和"查詢店家"按鈕
                            ForEach(0 ..< 2) { index in
                                Button(action: {
                                    selectedTab = selectedTabItem[index+1]
                                    title = menuSidebarItem[index]
                                    icon = menuSidebarIcon[index]
                                    sidebarPressed.toggle()
                                    myFavPressed = false
                                }, label: {
                                    HStack {
                                        Text(menuSidebarItem[index])
                                        Spacer()
                                        Image(systemName: menuSidebarIcon[index])
                                    }
                                })
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                Divider()
                            }
                            
                            // 我的最愛
                            Button(action: {
                                title = menuSidebarItem[2]
                                icon = menuSidebarIcon[2]
                                myFavPressed = true
                                sidebarPressed.toggle()
                                vm.getMyFavList()
                            }, label: {
                                HStack {
                                    Text(menuSidebarItem[2])
                                    Spacer()
                                    Image(systemName: menuSidebarIcon[2])
                                }
                            })
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            Divider()
                            
                            // 登出
                            Button(action: {
                                checkToLogOut.toggle()
                            }, label: {
                                HStack {
                                    Text(menuSidebarItem[3])
                                    Spacer()
                                    Image(systemName: menuSidebarIcon[3])
                                }
                            })
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            Divider()
                        }
                        .padding()
                    }
                    .frame(width: 160, height: 150)
                    
                    Spacer()
                }
            }
        }
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
                        sidebarPressed.toggle()
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
