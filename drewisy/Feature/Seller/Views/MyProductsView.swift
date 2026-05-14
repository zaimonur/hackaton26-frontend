//
//  MyProductsView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct MyProductsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = MyProductsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView().tint(Theme.primary)
                } else if viewModel.products.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bag.badge.minus")
                            .font(.system(size: 48)).foregroundColor(Theme.textSecondary)
                        Text("Henüz ürün eklemediniz.")
                            .font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                    }
                } else {
                    List(viewModel.products) { product in
                        HStack(spacing: 16) {
                            // AsyncImage entegrasyonu
                            AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().tint(Theme.primary)
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure(_):
                                    Image(systemName: "photo.trianglebadge.exclamationmark").foregroundColor(Theme.textSecondary)
                                @unknown default:
                                    Image(systemName: "photo").foregroundColor(Theme.textSecondary)
                                }
                            }
                            .frame(width: 60, height: 60)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            
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
                        // Swipe-to-Delete aksiyonu
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteProduct(id: product.id, token: appState.token) }
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Ürünlerim")
            .task { await viewModel.loadProducts(token: appState.token) }
        }
    }
}
