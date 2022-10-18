//
//  PortfolioDataService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-18.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    
    @Published var savedEntitys: [PortfolioEntity] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error {
                print("Error loading Core Data: \(error)")
            }
        }
        getPorfolio()
    }
    
    
    // MARK: PUBLIC
    
    
    func updatePorfolio(coin: CoinModel, amount: Double) {
        if let entity = savedEntitys.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                remove(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }
    }
    
    
    
    // MARK: PRIVATE
    
    
    private func getPorfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        
        do {
            savedEntitys = try container.viewContext.fetch(request)
        } catch {
            print("❌ Error in \(#function) ", error)
        }
    }
    
    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func remove(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
     
    private func applyChanges() {
        do {
            try container.viewContext.save()
            getPorfolio()
        } catch {
            print("❌ Error in \(#function) ", error)
        }
    }
}
