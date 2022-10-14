//
//  CryptopApp.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-10-08.
//

import SwiftUI

@main
struct CryptoApp: App {
    
    @StateObject var homeViewModel = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
            .environmentObject(homeViewModel)
        }
    }
}
