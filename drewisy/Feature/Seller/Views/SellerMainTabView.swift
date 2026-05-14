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
            // Sipariş Yönetimi Modülü
            SellerOrdersView()
                .tabItem {
                    Label("Siparişler", systemImage: "shippingbox.fill")
                }

            SellerDashboardView()
                .tabItem {
                    Label("Panel", systemImage: "chart.bar.fill")
                }
                
            MyProductsView()
                .tabItem {
                    Label("Ürünlerim", systemImage: "bag.fill")
                }
                
            ProfileSettingsView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
        .tint(Theme.primary)
    }
}
