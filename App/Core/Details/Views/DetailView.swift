//
//  DetailView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-21.
//

import SwiftUI


struct DetailLoadingView: View {
    @Binding var coin: CoinModel?
    
    var body: some View {
        ZStack {
            if let coin {
                DetailView(coin)
            }
        }
    }
}


struct DetailView: View {
    
    var coin: CoinModel
    
    init(_ coin: CoinModel) {
        self.coin = coin
    }
    
    var body: some View {
        Text(coin.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailLoadingView(coin: .constant(dev.coin))
    }
}
