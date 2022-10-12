//
//  HomeView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-10.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showPortfolio: Bool = false
    @EnvironmentObject private var vm: HomeViewModel
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            VStack {
                HomeHeaderView()
                
                
                ColumnTitles()
                
                if !showPortfolio {
                    AllCoinsList()
                        .transition(.move(edge: .leading))
                } else {
                    PortfolioCoinsList()
                        .transition(.move(edge: .trailing))
                }
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .toolbar(.hidden)
                .environmentObject(dev.homeViewModel)
        }
    }
}


// MARK: - ViewBuilders

private extension HomeView {
    
    
    @ViewBuilder func ColumnTitles() -> some View {
        
        HStack {
            Text("Coin")
            Spacer()
            if showPortfolio {
                Text("Holdings")
            }
            Text("Price")
                .frame(width: UIScreen.main.bounds.width / 3)
        }
        .font(.caption)
        .foregroundColor(.theme.secondaryText)
        .padding(.horizontal)
    }
    
    @ViewBuilder func AllCoinsList() -> some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin)
                    .listRowInsets(.init(top: 16, leading: 0, bottom: 16, trailing: 0))
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder func PortfolioCoinsList() -> some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin, showHoldingColumn: true)
                    .listRowInsets(.init(top: 16, leading: 0, bottom: 16, trailing: 0))
            }
        }
        .listStyle(.plain)
    }
    
    
    @ViewBuilder func HomeHeaderView() -> some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(nil, value: showPortfolio)
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(nil, value: showPortfolio)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }
        .padding()
    }
    
}
