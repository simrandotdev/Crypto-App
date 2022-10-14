//
//  CoinDataService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-12.
//

import Foundation
import Combine

class CoinDataService {
    
    @Published var allCoins: [CoinModel] = []
    
    var coinSubscription: AnyCancellable?
    
    init() {
        getCoins()
    }
    
    private func getCoins() {
        
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h"
        guard let url = URL(string: urlString) else {
            return
        }
        
        coinSubscription = NetworkingManager.shared.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.shared.handleCompletion) { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
                self?.coinSubscription?.cancel()
            }
    }
}
