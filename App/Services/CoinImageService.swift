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
    
    private var coin: CoinModel
    private let folderName = "coin_images"
    
    init(coin: CoinModel) {
        self.coin = coin
        getCoingImage()
    }
    
    private func getCoingImage() {
        
        if let savedImage = LocalFileManager.instance.getImage(imageName: coin.id, folderName: folderName) {
            print("Downloaded from FileManager: ")
            image = savedImage
            return
        }
        
        guard let url = URL(string: coin.image) else {
            return
        }
        
        imageSubscription = NetworkingManager.shared.download(url: url)
            .tryMap { data -> UIImage? in
                return UIImage(data: data)
            }
            .sink(receiveCompletion: NetworkingManager.shared.handleCompletion(completion:)) { [weak self] returnedImage in
                print("Downloaded from Internet: ", url.path)
                guard let downloadedImage = returnedImage,
                let coin = self?.coin,
                let folderName = self?.folderName else { return }
                
                self?.image = downloadedImage
                self?.imageSubscription?.cancel()
                LocalFileManager.instance.saveImage(image: downloadedImage, imageName: coin.id, folderName: folderName)
            }
    }
}
