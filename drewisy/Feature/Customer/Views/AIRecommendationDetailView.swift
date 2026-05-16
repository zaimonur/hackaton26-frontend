//
//  AIRecommendationDetailView.swift
//  drewisy
//
//  Created by Onur Zaim on 16.05.2026.
//

import SwiftUI

struct AIRecommendationDetailView: View {
    // MARK: - Properties
    let recommendation: AIRecommendationResponse
    
    // MARK: - Dependencies
    @Environment(CartManager.self) private var cartManager
    
    // MARK: - Computed Properties (Gruplama ve Sıralama)
    private var groupedProducts: [String: [ProductResponse]] {
        Dictionary(grouping: recommendation.recommendedProducts, by: { $0.category })
    }
    
    private var sortedCategories: [String] {
        // Kategorileri alfabetik olarak sıralayarak arayüzde tutarlılık sağlıyoruz
        groupedProducts.keys.sorted()
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 32) {
                    
                    // Üst Grafik Banner (Netflix Hissiyatı)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("YAPAY ZEKA ÖZEL KOLEKSİYONU")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.yellow)
                                .tracking(2)
                        }
                        
                        Text("Sana özel harmanlanmış 12 kritik ürün trend analizlerine göre listelendi.")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, Theme.spacing)
                    .padding(.top, 16)
                    
                    // Alt alta dinamik şeritler (Swimlanes)
                    ForEach(sortedCategories, id: \.self) { category in
                        if let products = groupedProducts[category] {
                            ProductSwimlaneView(title: category, products: products) { product in
                                cartManager.addToCart(product: product)
                            }
                        }
                    }
                }
                .padding(.vertical, Theme.spacing)
            }
        }
        // Yerel (Native) navigasyon barını ve geri butonunu kullanıyoruz
        .navigationTitle(recommendation.heroTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}
