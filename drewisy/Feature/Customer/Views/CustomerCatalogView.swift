//
//  CustomerCatalogView.swift
//  drewisy
//
//  Created by Onur Zaim on 11.05.2026.
//

import SwiftUI

struct CustomerCatalogView: View {
    // MARK: - Dependencies
    @Environment(CartManager.self) private var cartManager
    @Environment(AppState.self) private var appState
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerAndSearchSection
                        
                        if viewModel.isLoading && viewModel.products.isEmpty {
                            Spacer()
                            ProgressView().tint(viewModel.isAIEnabled ? .purple : Theme.primary)
                            Spacer()
                        } else {
                            if viewModel.searchText.isEmpty {
                                VStack(spacing: 24) {
                                    if !viewModel.categories.isEmpty {
                                        categoriesSection
                                    }
                                    
                                    if let recommendation = viewModel.aiRecommendation {
                                        HeroBannerView(recommendation: recommendation)
                                            .padding(.horizontal, Theme.spacing)
                                    }
                                    
                                    if !viewModel.history.isEmpty {
                                        ProductSwimlaneView(title: "Son Baktıkların", products: viewModel.history) { product in
                                            cartManager.addToCart(product: product)
                                        }
                                    }
                                    
                                    if !viewModel.bestsellers.isEmpty {
                                        ProductSwimlaneView(title: "🔥 En Çok Satanlar", products: viewModel.bestsellers) { product in
                                            cartManager.addToCart(product: product)
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            mainProductGridSection
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Katalog")
            .navigationBarTitleDisplayMode(.inline)
            // 1. Ürün Detay Rotası (Mevcut)
            .navigationDestination(for: ProductResponse.self) { product in
                ProductDetailView(product: product)
                    .onAppear {
                        Task { await viewModel.recordHistory(productId: product.id, token: appState.token) }
                    }
            }
            // 2. MODERN ROTA ENTEGRASYONU ✅: Netflix AI Vitrini Detay Sayfası
            .navigationDestination(for: AIRecommendationResponse.self) { rec in
                AIRecommendationDetailView(recommendation: rec)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    cartButton
                }
            }
            .task { await viewModel.fetchHomePageData(token: appState.token) }
            .onChange(of: viewModel.searchText) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.searchWithDebounce()
                }
            }
            .alert("Hata", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - UI Subcomponents (Arama ve Grid Yapıları - Dokunulmadı)
    private var headerAndSearchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Merhaba, Hoş Geldin 👋")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                Text("Senin için en akıllı vitrini hazırladık.")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, Theme.spacing)
            
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
                    
                    if !viewModel.searchText.isEmpty {
                        Button { viewModel.searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .padding().frame(height: 44).background(Theme.surface).cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(viewModel.isAIEnabled ? Color.purple.opacity(0.6) : Color.clear, lineWidth: 1.5)
                )
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.isAIEnabled.toggle()
                        if !viewModel.searchText.isEmpty { viewModel.searchWithDebounce() }
                    }
                } label: {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(viewModel.isAIEnabled ? .white : .purple)
                        .frame(width: 44, height: 44)
                        .background(viewModel.isAIEnabled ? AnyView(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyView(Theme.surface))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, Theme.spacing)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategoriler").font(Theme.titleFont).foregroundColor(Theme.textPrimary).padding(.horizontal, Theme.spacing)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Button { withAnimation(.spring()) { viewModel.searchText = category } } label: {
                            CategoryCircleView(categoryName: category)
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, Theme.spacing)
            }
        }
    }
    
    private var mainProductGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.searchText.isEmpty ? "Tüm Ürünler" : "Arama Sonuçları").font(Theme.titleFont).foregroundColor(Theme.textPrimary).padding(.horizontal, Theme.spacing)
            if viewModel.products.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass.circle").font(.system(size: 48)).foregroundColor(Theme.textSecondary)
                    Text("Kriterlere uygun ürün bulunamadı.").font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                }.frame(maxWidth: .infinity, minHeight: 200).padding(.horizontal, Theme.spacing)
            } else {
                LazyVGrid(columns: columns, spacing: Theme.spacing) {
                    ForEach(viewModel.products) { product in
                        NavigationLink(value: product) {
                            PremiumProductCardView(product: product) { cartManager.addToCart(product: product) }
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, Theme.spacing)
            }
        }
    }
    
    private var cartButton: some View {
        Button { withAnimation { selectedTab = 1 } } label: {
            Image(systemName: "cart")
                .overlay(alignment: .topTrailing) {
                    if cartManager.totalItemCount > 0 {
                        Text("\(cartManager.totalItemCount)").font(.system(size: 10, weight: .bold)).foregroundColor(.white).padding(4).background(Color.red).clipShape(Circle()).offset(x: 10, y: -8)
                    }
                }
        }.tint(Theme.primary)
    }
}
