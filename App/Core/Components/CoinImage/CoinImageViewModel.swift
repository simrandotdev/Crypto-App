//
//  CoinImageViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-14.
//

import Foundation
import UIKit
import Combine

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    
    private var coinImageService: CoinImageService
    private let coin: CoinModel
    private var cancellable: Set<AnyCancellable>
    
    init(coin: CoinModel) {
        self.coin = coin
        self.cancellable = Set()
        self.coinImageService = CoinImageService(coin: coin)
        self.isLoading = true
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        coinImageService.$image
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
            }, receiveValue: { [weak self] returnedImage in
                self?.image = returnedImage
            })
            .store(in: &cancellable)
    }
}
