//
//  SellerMainTabView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct SellerMainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SellerDashboardView()
                .tabItem { Label("Özet", systemImage: "chart.bar.fill") }.tag(0)
            
            MyProductsView()
                .tabItem { Label("Ürünlerim", systemImage: "bag.fill") }.tag(1)
            
            AddProductView(onUploadSuccess: { selectedTab = 1 })
                .tabItem { Label("Yeni Ürün", systemImage: "plus.circle.fill") }.tag(2)
            
            ProfileSettingsView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }.tag(3)
        }
        .tint(Theme.primary)
    }
}
