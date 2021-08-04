//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Thor on 03/08/2021.
//

import SwiftUI

@main
struct CryptoAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView{
                HomeView()
                    .navigationBarHidden(true)
            }
        }
    }
}
