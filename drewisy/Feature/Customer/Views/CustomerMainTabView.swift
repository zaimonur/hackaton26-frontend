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
                .tabItem { Label("Katalog", systemImage: "square.grid.2x2.fill") }
                .tag(0)
            
            CartView()
                .tabItem { Label("Sepet", systemImage: "cart.fill") }
                .badge(cartManager.totalItemCount > 0 ? cartManager.totalItemCount : 0)
                .tag(1)
            
            ProfileSettingsView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle.fill") }
                .tag(2)
        }
        .tint(Theme.primary)
    }
}
