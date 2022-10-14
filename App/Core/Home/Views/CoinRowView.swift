//
//  CoinRowView.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-10.
//

import SwiftUI

struct CoinRowView: View {
    
    let coinModel: CoinModel
    let showHoldingsColumn: Bool

    init(_ coinModel: CoinModel, showHoldingColumn: Bool = false) {

        self.coinModel = coinModel
        self.showHoldingsColumn = showHoldingColumn
    }
    
    var body: some View {
        HStack(spacing: 0) {
            rankSymbolColumnView()
            
            if showHoldingsColumn {
                holdingsColumnView()
            }
            
            currencyAndPriceChangeColumnView()
        }
        .font(.subheadline)
    }
}

struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CoinRowView(dev.coin, showHoldingColumn: true)
                .previewLayout(.sizeThatFits)
            
            CoinRowView(dev.coin, showHoldingColumn: true)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}


private extension CoinRowView {
    func rankSymbolColumnView() -> some View {
        return HStack(spacing: 0) {
            Text("\(coinModel.rank)")
                .font(.caption)
                .minimumScaleFactor(0.75)
                .foregroundColor(.theme.secondaryText)
                .frame(minWidth: 30)
            CoinImageView(coin: coinModel)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text(coinModel.symbol.uppercased())
                    .font(.headline)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(.theme.accent)
                Text(coinModel.name)
                    .font(.footnote)
                    .minimumScaleFactor(0.75)
                    .foregroundColor(.theme.secondaryText)
            }
            .padding(.leading, 6)
            
            Spacer()
        }
    }
    
    func holdingsColumnView() -> some View {
        return VStack(alignment: .trailing) {
            Text("\(coinModel.currentHoldingsValue.asCurrencyWith2Decimals())")
                .minimumScaleFactor(0.75)
            Text((coinModel.currentHoldings ?? 0).asNumberString())
                .minimumScaleFactor(0.75)
        }
        .foregroundColor(.theme.accent)
        
    }
    
    func currencyAndPriceChangeColumnView() -> some View {
        return VStack(alignment: .trailing) {
            Text("\(coinModel.currentPrice.asCurrencyWith2Decimals())")
                .minimumScaleFactor(0.75)
                .font(.body.bold())
                .foregroundColor(.theme.accent)
            Text("\( (coinModel.priceChangePercentage24H ?? 0).asPercentString())")
                .minimumScaleFactor(0.75)
                .foregroundColor((coinModel.priceChange24H ?? 0) >= 0 ? .theme.green : .theme.red)
        }
        .frame(width: UIScreen.main.bounds.width / 3)
    }
}
