//
//  CustomerMainTabView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct CustomerMainTabView: View {
    @Environment(CartManager.self) private var cartManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CustomerCatalogView(selectedTab: $selectedTab)
                .tabItem { Label("Katalog", systemImage: "house.fill") }
                .tag(0)
            
            // Placeholder: AI Chat
            Text("AI Assistant Çok Yakında")
                .font(Theme.titleFont)
                .foregroundColor(Theme.textSecondary)
                .tabItem { Label("AI Sohbet", systemImage: "sparkles") }
                .tag(1)
            
            CartView()
                .tabItem { Label("Sepet", systemImage: "cart.fill") }
                .badge(cartManager.totalItemCount > 0 ? cartManager.totalItemCount : 0)
                .tag(2)
            
            NotificationListView()
                .tabItem { Label("Bildirimler", systemImage: "bell.fill") }
                .tag(3)
            
            CustomerProfileView()
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(4)
        }
        .tint(Theme.primary)
    }
}
