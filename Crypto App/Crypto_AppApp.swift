//
//  Crypto_AppApp.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-08.
//

import SwiftUI

@main
struct Crypto_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
