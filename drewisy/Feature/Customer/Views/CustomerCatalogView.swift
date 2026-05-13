//
//  CustomerCatalogView.swift
//  drewisy
//
//  Created by Onur Zaim on 11.05.2026.
//

import SwiftUI

struct CustomerCatalogView: View {
    @Environment(CartManager.self) private var cartManager
    @State private var viewModel = CustomerCatalogViewModel()
    @Binding var selectedTab: Int // YENİ: Tab geçişi için Binding eklendi
    
    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacing),
        GridItem(.flexible(), spacing: Theme.spacing)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView().tint(Theme.primary)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                        Text(error).font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: Theme.spacing) {
                            ForEach(viewModel.products) { product in
                                productCard(for: product)
                            }
                        }
                        .padding(Theme.spacing)
                    }
                }
            }
            .navigationTitle("Katalog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // YENİ: Sepete gitme aksiyonu animasyonlu olarak tetikleniyor
                        withAnimation { selectedTab = 1 }
                    } label: {
                        Image(systemName: "cart")
                            .overlay(alignment: .topTrailing) {
                                if cartManager.totalItemCount > 0 {
                                    Text("\(cartManager.totalItemCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -8)
                                }
                            }
                    }
                    .tint(Theme.primary)
                }
            }
            .task { await viewModel.loadProducts() }
        }
    }
    
    @ViewBuilder
    private func productCard(for product: ProductResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                switch phase {
                case .empty:
                    ProgressView().tint(Theme.primary).frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    Image(systemName: "photo").foregroundColor(Theme.textSecondary).frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 140)
            .clipped()
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                Text(product.category)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                
                HStack {
                    Text("\(product.price, specifier: "%.2f") ₺")
                        .font(Theme.bodyFont.bold())
                        .foregroundColor(Theme.primary)
                    
                    Spacer()
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        cartManager.addToCart(product: product)
                    } label: {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.primary)
                            .padding(8)
                            .background(Theme.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth)
        )
    }
}
