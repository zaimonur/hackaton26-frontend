//
//  StaffDashboardView.swift
//  drewisy
//
//  Created by Onur Zaim on 12.05.2026.
//

import SwiftUI

struct StaffDashboardView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        TabView {
            PlaceholderView(title: "Tüm Ürünler", icon: "square.grid.2x2", subtitle: "Katalog modülü entegre edilecek.")
                .tabItem { Label("Katalog", systemImage: "square.grid.2x2") }
            
            PlaceholderView(title: "Siparişler", icon: "shippingbox", subtitle: "Bekleyen siparişler entegre edilecek.")
                .tabItem { Label("Siparişler", systemImage: "shippingbox") }
            
            AddProductView()
                .tabItem { Label("Ürün Ekle", systemImage: "plus.circle.fill") }
            
            ProfileSettingsView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
        .tint(Theme.primary)
    }
}

// Ortak Taslak Görünümü
struct PlaceholderView: View {
    let title: String
    let icon: String
    let subtitle: String
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: icon).font(.system(size: 64)).foregroundColor(Theme.primary)
                Text(title).font(Theme.titleFont).foregroundColor(Theme.textPrimary)
                Text(subtitle).font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
            }
        }
    }
}
