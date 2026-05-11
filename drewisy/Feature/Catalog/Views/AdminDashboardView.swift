//
//  AdminDashboardView.swift
//  drewisy
//
//  Created by Onur Zaim on 11.05.2026.
//


import SwiftUI

struct AdminDashboardView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "storefront.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.primary)
                
                Text("Satıcı Paneli")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                
                Text("Ürün ekleme ve mağaza yönetim alanı.")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }
}
