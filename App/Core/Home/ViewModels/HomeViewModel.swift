//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-12.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    enum SortOptions {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    @Published var statistics: [StatisticModel] = []
    @Published var sortOption: SortOptions = .rank
    @Published var allCoins: [CoinModel] = []
    @Published var allCoinSearchText: String = ""
    @Published var portfolioCoins: [CoinModel] = []
    @Published var isLoading: Bool = false

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
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellable)
        
        $allCoins
            .combineLatest(portfolioDataService.$savedEntitys)
            .map (mapAllCoinsToPorfolioCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellable)
        
        marketDataService
            .$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] mappedStatistics in
                self?.statistics = mappedStatistics
                self?.isLoading = false
            }
            .store(in: &cancellable)
        
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePorfolio(coin: coin, amount: amount)
    }
    
    func reloadData() {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getMarketData()
        HapticsManager.notification(type: .success)
    }
    
    
    private func sortPortfolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel] {
        // will only sort by holdings or reverse holdings if needed
        switch sortOption {
            case .holdings:
                return coins.sorted(by: {  $0.currentHoldingsValue > $1.currentHoldingsValue })
            case .holdingsReversed:
                return coins.sorted(by: {  $0.currentHoldingsValue < $1.currentHoldingsValue })
            default:
                return coins
        }
        
        return []
    }
    
    private func mapAllCoinsToPorfolioCoins(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
        allCoins.compactMap { allCoins in
            guard let entity = portfolioEntities.first(where: { $0.coinID == allCoins.id }) else {
                return nil
            }
            return allCoins.updateHoldings(amount: entity.amount)
        }
    }
    
    private func filterAndSortCoins(text: String, coins:[CoinModel], sort: SortOptions) -> [CoinModel] {
        
        var filteredCoins = filterCoins(text: text, coins: coins)
        let sortedCoins = sortCoins(sort: sort, coins: filteredCoins)
        return sortedCoins
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
    
    private func sortCoins(sort: SortOptions, coins: [CoinModel]) -> [CoinModel] {
        
        switch sort {
        case .rank, .holdings:
            return coins.sorted(by: { $0.rank < $1.rank })
        case .rankReversed, .holdingsReversed:
            return coins.sorted(by: { $0.rank > $1.rank })
        case .price:
            return coins.sorted(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            return coins.sorted(by: { $0.currentPrice < $1.currentPrice })
        }
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
