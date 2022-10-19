//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-12.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    @Published var allCoins: [CoinModel] = []
    @Published var allCoinSearchText: String = ""
    @Published var portfolioCoins: [CoinModel] = []

    private let coinDataService: CoinDataService
    private let marketDataService: MarketDataService
    private let portfolioDataService: PortfolioDataService
    
    private var cancellable: Set<AnyCancellable>
    
    init(coinDataService: CoinDataService = CoinDataService(),
         marketDataService: MarketDataService = MarketDataService(),
         portfolioDataService: PortfolioDataService = PortfolioDataService()) {
        
        self.coinDataService = coinDataService
        self.marketDataService = marketDataService
        self.portfolioDataService = portfolioDataService
        self.cancellable = Set()
        
        addSubscribers()
    }
    
    private func addSubscribers() {

        $allCoinSearchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellable)
        
        marketDataService
            .$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] mappedStatistics in
                self?.statistics = mappedStatistics
            }
            .store(in: &cancellable)
        
        $allCoins
            .combineLatest(portfolioDataService.$savedEntitys)
            .map (mapAllCoinsToPorfolioCoins)
            .sink { [weak self] returnedCoins in
                self?.portfolioCoins = returnedCoins
            }
            .store(in: &cancellable)
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePorfolio(coin: coin, amount: amount)
    }
    
    
    private func mapAllCoinsToPorfolioCoins(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
        allCoins.compactMap { allCoins in
            guard let entity = portfolioEntities.first(where: { $0.coinID == allCoins.id }) else {
                return nil
            }
            return allCoins.updateHoldings(amount: entity.amount)
        }
    }
    
    private func filterCoins(text: String, coins:[CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        let filteredCoins = coins.filter { coin -> Bool in
            return coin.name.lowercased().contains(lowercasedText)
            || coin.symbol.lowercased().contains(lowercasedText)
            || coin.id.lowercased().contains(lowercasedText)
        }
        
        return filteredCoins
    }
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel] {
        guard let marketDataModel else { return self.statistics }
        
        let totalPortfolioVolume = getTotalPorfolioValue(portfolioCoins: portfolioCoins)
        let previousValue = portfolioCoins.map({ coin -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = coin.priceChangePercentage24H  ?? 0 / 100
            let previousValue = currentValue / (1 + percentChange)
            return previousValue
        })
        .reduce(0, +)
        
        let percentageChange = ( (totalPortfolioVolume - previousValue)/previousValue ) * 100
            
        
        return [
            StatisticModel(title: "Market Cap", value: marketDataModel.marketCap, percentageChange: marketDataModel.marketCapChangePercentage24HUsd),
            StatisticModel(title: "24H Volume", value: marketDataModel.volume),
            StatisticModel(title: "BTC Dominance", value: marketDataModel.btcDominance),
            StatisticModel(title: "Portfolio Value", value: "\(totalPortfolioVolume.asCurrencyWith2Decimals())", percentageChange: percentageChange)
        ]
    }
    
    private func getTotalPorfolioValue(portfolioCoins: [CoinModel]) -> Double {
        return portfolioCoins.reduce(0) { $0 + $1.currentHoldingsValue }
    }
}
