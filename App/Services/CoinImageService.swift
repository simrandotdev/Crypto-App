//
//  CoinImageService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-14.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil
    
    var imageSubscription: AnyCancellable?
    
    init(urlString: String) {
        getCoingImage(urlString)
    }
    
    private func getCoingImage(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        imageSubscription = NetworkingManager.shared.download(url: url)
            .tryMap { data -> UIImage? in
                return UIImage(data: data)
            }
            .sink(receiveCompletion: NetworkingManager.shared.handleCompletion(completion:)) { [weak self] returnedImage in
                self?.image = returnedImage
                self?.imageSubscription?.cancel()
            }
    }
}
