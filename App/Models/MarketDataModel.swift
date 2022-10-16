//
//  MarketDataModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-16.
//

import Foundation

// https://api.coingecko.com/api/v3/global

import Foundation

// MARK: - GlobalData
struct GlobalData: Codable {
    let data: MarketDataModel
}


// MARK: - MarketDataModel


struct MarketDataModel: Codable {
    let totalMarketCap: [String: Double]
    let totalVolume: [String: Double]
    let marketCapPercentage: [String: Double]
    let marketCapChangePercentage24HUsd: Double
    
    enum CodingKeys: String, CodingKey {
        case totalMarketCap = "total_market_cap"
        case totalVolume = "total_volume"
        case marketCapPercentage = "market_cap_percentage"
        case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
    }
    
    var marketCap: String {
        if let item = totalMarketCap.first(where: { $0.key == "usd" }) {
            return "$\(item.value.formattedWithAbbreviations())"
        }
        return ""
    }
    
    var volume: String {
        if let item = totalVolume.first(where: { $0.key == "usd" }) {
            return "$\(item.value.formattedWithAbbreviations())"
        }
        return ""
    }
    
    var btcDominance: String {
        if let item = marketCapPercentage.first(where: { $0.key == "btc" }) {
            return "\(item.value.asPercentString())"
        }
        return ""
    }
}
