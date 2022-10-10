//
//  CryptopApp.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-08.
//

import SwiftUI

@main
struct CryptoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .toolbar(.hidden)
            }
        }
    }
}
