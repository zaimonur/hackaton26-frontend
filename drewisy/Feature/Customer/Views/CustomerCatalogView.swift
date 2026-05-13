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
    @Binding var selectedTab: Int
    
    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacing),
        GridItem(.flexible(), spacing: Theme.spacing)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBarSection
                        .padding(.horizontal, Theme.spacing)
                        .padding(.vertical, 8)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView().tint(viewModel.isAIEnabled ? .purple : Theme.primary)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                            Text(error).font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                        }.padding(.top, 40)
                        Spacer()
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
            }
            .navigationTitle("Katalog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    cartButton
                }
            }
            .task { await viewModel.loadProducts() }
            // Arama kutusu temizlendiğinde otomatik yükle
            .onChange(of: viewModel.searchText) { _, newValue in
                if newValue.isEmpty {
                    Task { await viewModel.loadProducts() }
                }
            }
        }
    }
    
    // MARK: - Arama Barı Bileşeni
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(viewModel.isAIEnabled ? .purple : Theme.textSecondary)
                
                TextField(viewModel.isAIEnabled ? "AI ile akıllı arama..." : "Ürün ara...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(Theme.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.searchProducts() }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .padding()
            .frame(height: 44)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadius)
            // AI Glow ve Border Efekti
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(viewModel.isAIEnabled ? Color.purple.opacity(0.6) : Color.clear, lineWidth: 1.5)
                    .shadow(color: viewModel.isAIEnabled ? .purple.opacity(0.4) : .clear, radius: 4)
            )
            .animation(.spring(response: 0.3), value: viewModel.isAIEnabled)
            
            // AI Toggle Butonu
            Button {
                withAnimation(.spring()) {
                    viewModel.isAIEnabled.toggle()
                }
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(viewModel.isAIEnabled ? .white : .purple)
                    .frame(width: 44, height: 44)
                    .background(viewModel.isAIEnabled ? AnyView(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyView(Theme.surface))
                    .clipShape(Circle())
                    .shadow(color: viewModel.isAIEnabled ? .purple.opacity(0.5) : .clear, radius: 6)
            }
        }
    }
    
    private var cartButton: some View {
        Button {
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

    // Mevcut productCard fonksiyonu buraya gelecek...
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
