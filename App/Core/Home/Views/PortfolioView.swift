//
//  PortfolioView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-17.
//

import SwiftUI

struct PortfolioView: View {
    
    @EnvironmentObject var vm: HomeViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText: String = ""
    @State private var showCheckmark = false
    @FocusState private var focusState: Bool
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.allCoinSearchText)
                        .padding()
                    CoinLogoList()
                    
                    if selectedCoin != nil {
                        PortfolioInputSection()
                    }
                }
            }
            .navigationTitle("Edit Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    TrailingBarButton()
                }
            }
            .onChange(of: vm.allCoinSearchText) { newValue in
                if newValue == "" {
                    removeSelectedCoin()
                }
            }
        }
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}


// MARK: - Data Operations


private extension PortfolioView {
    
    func saveButtonPressed() {
        
        guard let coin = selectedCoin,
              let amount = Double(quantityText)
        else { return }
        
        // save to portfolio
        vm.updatePortfolio(coin: coin, amount: amount)
        
        // show checkmark
        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectedCoin()
            
            focusState = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut) {
                    showCheckmark = false
                }
            }
        }
    }
    
    func removeSelectedCoin() {
        selectedCoin = nil
        vm.allCoinSearchText = ""
    }
    
    func updateSelectedCoin(coin: CoinModel) {
        selectedCoin = coin
        
        if let portfolioCoin = vm.portfolioCoins.first(where: { $0.id == coin.id }),
        let currentHoldings = portfolioCoin.currentHoldings {
            quantityText = "\(currentHoldings)"
        } else {
            quantityText = ""
        }
        
    }
}


// MARK: - UI Components


private extension PortfolioView {
    
    func CoinLogoList() -> ScrollView<some View> {
        return ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 10) {
                ForEach(vm.allCoinSearchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation {
                                updateSelectedCoin(coin: coin)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedCoin?.id == coin.id ? Color.theme.green : Color.clear, lineWidth: 1)
                        )
                }
            }
            .padding(4)
            
        }
    }
    
    func PortfolioInputSection() -> some View {
        return VStack(spacing: 20) {
            HStack {
                Text("Current Price of \(selectedCoin?.symbol.uppercased() ?? "" ): ")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            
            Divider()
            
            HStack {
                Text("Amount in your Portfolio: ")
                Spacer()
                TextField("Ex: 1.4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focusState)
            }
            
            Divider()
            
            HStack {
                Text("Current Value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
            
        }
        .padding()
    }
    
    func TrailingBarButton() -> some View {
        return HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1.0 : 0.0)
            
            Button {
                saveButtonPressed()
            } label: {
                Text("Save".uppercased())
            }
            .opacity( (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0 )
            
        }
    }
}
