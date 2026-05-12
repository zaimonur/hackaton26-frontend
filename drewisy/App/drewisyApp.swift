//
//  drewisyApp.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import SwiftUI

@main
struct drewisyApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    switch appState.userRole {
                    case "seller":
                        SellerRootView()
                    case "admin":
                        AdminDashboardView()
                    default:
                        CustomerCatalogView()
                    }
                } else {
                    AuthView()
                }
            }
            .environment(appState) // Tüm alt view'lara enjekte edilir
            .animation(.easeInOut, value: appState.isAuthenticated)
        }
    }
}
