//
//  drewisyApp.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import SwiftUI

@main
struct drewisyApp: App {
    // 🚀 scenePhase ortam değişkeni eklendi
    @Environment(\.scenePhase) private var scenePhase
    @State private var appState = AppState()
    @State private var cartManager = CartManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(cartManager)
                .animation(.easeInOut, value: appState.isAuthenticated)
                // 🚀 Arka plandan öne gelme durumunu dinleyen reaktif tetikleyici
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active, let token = appState.token {
                        WebSocketManager.shared.connect(token: token)
                    }
                }
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
