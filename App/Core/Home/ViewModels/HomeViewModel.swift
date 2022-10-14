//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-12.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
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
        dataService.$allCoins
            .sink { [weak self] returnedAllCoins in
                self?.allCoins = returnedAllCoins
            }
            .store(in: &cancellable)
    }
}
