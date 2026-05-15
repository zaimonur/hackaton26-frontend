//
//  SellerMainTabView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct SellerMainTabView: View {
    var body: some View {
        TabView {
            SellerOrdersView()
                .tabItem { Label("Siparişler", systemImage: "shippingbox.fill") }

            PanelRootView()
                .tabItem { Label("Panel", systemImage: "square.grid.2x2.fill") }
                
            // MARK: - Dummy Views
            Text("Mesajlar Hazırlanıyor...")
                .font(Theme.titleFont)
                .foregroundColor(Theme.textSecondary)
                .tabItem { Label("Mesajlar", systemImage: "message.fill") }
                
            Text("Bildirimler Hazırlanıyor...")
                .font(Theme.titleFont)
                .foregroundColor(Theme.textSecondary)
                .tabItem { Label("Bildirimler", systemImage: "bell.fill") }
                
            ProfileSettingsView()
                .tabItem { Label("Profil", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
    }
}
