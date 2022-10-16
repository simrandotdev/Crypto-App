//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-12.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = [
        StatisticModel(title: "Title 1", value: "Value", percentageChange: 1),
        StatisticModel(title: "Title 2", value: "Value"),
        StatisticModel(title: "Title 3", value: "Value"),
        StatisticModel(title: "Title 4", value: "Value", percentageChange: -1),
    ]
    @Published var allCoins: [CoinModel] = []
    @Published var allCoinSearchText: String = ""
    
    @Published var portfolioCoins: [CoinModel] = []


    private let dataService: CoinDataService
    private var cancellable: Set<AnyCancellable>
    
    init(dataService: CoinDataService = CoinDataService()) {
        self.dataService = dataService
        self.cancellable = Set()
        
        addSubscribers()
    }
    
    private func addSubscribers() {

        $allCoinSearchText
            .combineLatest(dataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { returnedCoins in
                self.allCoins = returnedCoins
            }
            .store(in: &cancellable)
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
}
