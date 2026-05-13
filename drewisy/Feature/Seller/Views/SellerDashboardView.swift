//
//  SellerDashboardView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct SellerDashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SellerDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView().tint(Theme.primary)
                } else {
                    ScrollView {
                        VStack(spacing: Theme.spacing) {
                            // Toplam Ürün Kartı
                            statCard(
                                icon: "bag.fill",
                                title: "Toplam Ürün",
                                valueView: Text("\(viewModel.totalProducts)")
                            )
                            
                            // Toplam Katalog Değeri Kartı
                            statCard(
                                icon: "banknote.fill",
                                title: "Katalog Değeri",
                                valueView: Text("\(viewModel.totalCatalogValue, specifier: "%.2f") ₺")
                            )
                            
                            // Son Eklenen Ürün Kartı
                            statCard(
                                icon: "clock.fill",
                                title: "Son Eklenen",
                                valueView: Text(viewModel.latestProduct)
                            )
                        }
                        .padding(Theme.spacing)
                    }
                }
            }
            .navigationTitle("Özet")
            .task { await viewModel.loadData(token: appState.token) }
        }
    }
    
    // MARK: - UI Helpers
    /// HIG Standartlarına uygun, gölgesiz ve ince çerçeveli (border) istatistik kartı.
    @ViewBuilder
    private func statCard<V: View>(icon: String, title: String, valueView: V) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.primary)
                .frame(width: 50, height: 50)
                .background(Theme.primary.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                
                valueView
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
        // 🔥 GÖLGE YERİNE APPLE HIG UYUMLU İNCE VE SAYDAM ÇERÇEVE
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth)
        )
    }
}
