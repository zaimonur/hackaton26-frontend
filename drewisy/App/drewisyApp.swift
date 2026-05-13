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
    @State private var cartManager = CartManager()
    
    var body: some Scene {
        WindowGroup {
            // Sadece tek bir ana View çağırıyoruz, dallanmaları içeride yapıyoruz
            RootView()
                .environment(appState)
                .environment(cartManager)
                .animation(.easeInOut, value: appState.isAuthenticated)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                switch appState.userRole {
                case "seller":
                    SellerRootView()
                case "admin":
                    AdminDashboardView()
                default:
                    CustomerMainTabView() // Müşteri sekme yapımız doğrudan burada ayağa kalkıyor
                }
            } else {
                AuthView()
            }
        }
    }
}
