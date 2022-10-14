//
//  NetworkingService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-13.
//

import Foundation
import Combine


class NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private init() { }
    
    func download<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({ try self.handleURLResponse(output: $0, url: url) })
            .receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        return output.data
    }
    
    func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}


enum NetworkingError: LocalizedError {
    
    case badURLResponse(url: URL)
    case unknown
    
    var errorDescription: String {
        switch self {
            
        case .badURLResponse(url: let url):
            return "❌ Bad response from URL: \(url)"
        case .unknown:
            return "❌ Unknown error occurred"
        }
    }
}
