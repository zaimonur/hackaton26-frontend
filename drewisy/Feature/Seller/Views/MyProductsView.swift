//
//  MyProductsView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct MyProductsView: View {
    @Environment(AppState.self) private var appState
    @State private var products: [ProductResponse] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if isLoading {
                    ProgressView().tint(Theme.primary)
                } else if products.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bag.badge.minus")
                            .font(.system(size: 48)).foregroundColor(Theme.textSecondary)
                        Text("Henüz ürün eklemediniz.")
                            .font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                    }
                } else {
                    List(products) { product in
                        HStack(spacing: 16) {
                            // Backend'den image_path geliyor, şimdilik placeholder koyuyoruz
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(Theme.surface)
                                .frame(width: 60, height: 60)
                                .overlay(Image(systemName: "photo").foregroundColor(Theme.textSecondary))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(Theme.bodyFont.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Text(product.category)
                                    .font(Theme.captionFont)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text("\(product.price, specifier: "%.2f") ₺")
                                .font(Theme.bodyFont.bold())
                                .foregroundColor(Theme.primary)
                        }
                        .listRowBackground(Theme.surface)
                        .listRowSeparatorTint(Theme.textSecondary.opacity(0.2))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Ürünlerim")
            .task { await loadProducts() }
        }
    }
    
    private func loadProducts() async {
        do {
            products = try await NetworkManager.shared.request(
                url: "http://localhost:8080/api/v1/seller/products",
                body: String?.none, // Generic B için çözüm
                token: appState.token
            )
        } catch {
            print("Ürünler çekilemedi.")
        }
        isLoading = false
    }
}
