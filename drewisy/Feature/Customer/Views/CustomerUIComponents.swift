//
//  CustomerUIComponents.swift
//  drewisy
//
//  Created by Onur Zaim on 16.05.2026.
//

import SwiftUI

// MARK: - 1. Premium Product Card View
struct PremiumProductCardView: View {
    let product: ProductResponse
    var isCompact: Bool = false
    var onAddTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. GÖRSEL ALANI (SABİT)
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(Theme.surface)
                    }
                }
                .frame(height: isCompact ? 120 : 160) // Görsel yüksekliği netleştirildi
                .clipped()
                
                if let badge = product.aiSentimentBadge {
                    Text("✨ \(badge)")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.ultraThinMaterial).clipShape(Capsule()).padding(6)
                }
            }
            
            // 2. BİLGİ ALANI
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                Text(product.category)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                
                // İçerik az olsa bile butonları aşağı iten sihirli boşluk
                Spacer(minLength: 0)
                
                HStack {
                    Text("\(product.price, specifier: "%.2f") ₺")
                        .font(Theme.bodyFont.bold())
                        .foregroundColor(Theme.primary)
                    Spacer()
                    Button(action: onAddTapped) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white).frame(width: 28, height: 28)
                            .background(Theme.primary).clipShape(Circle())
                    }
                }
            }
            .padding(10)
        }
        // HARD FRAME: Esnekliği tamamen öldüren askeri simetri sınırı
        .frame(height: isCompact ? 225 : 280)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - 2. Category Circle View
struct CategoryCircleView: View {
    let categoryName: String
    
    private var categoryIcon: String {
        switch categoryName.lowercased() {
        case "giyim", "kıyafet": return "tshirt.fill"
        case "elektronik", "teknoloji": return "laptopcomputer"
        case "kitap", "kırtasiye": return "book.fill"
        case "kozmetik", "kişisel bakım": return "sparkles"
        case "spor", "outdoor": return "figure.run"
        case "ev", "yaşam": return "house.fill"
        default: return "bag.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Theme.surface)
                    .frame(width: 64, height: 64)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.primary)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(LinearGradient(colors: [Theme.primary.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5))
            }
            .shadow(color: Theme.primary.opacity(0.15), radius: 8, x: 0, y: 4)
            
            Text(categoryName)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 76)
    }
}

// MARK: - 3. Hero Banner View
struct HeroBannerView: View {
    let recommendation: AIRecommendationResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("AI Seçimi")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    Text(recommendation.heroTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                Spacer()
            }
            
            HStack(alignment: .bottom) {
                // Tıklanabilir dairesel mini görseller (Doğrudan Ürün Detayına Gider)
                HStack(spacing: -12) {
                    ForEach(Array(recommendation.recommendedProducts.prefix(3).enumerated()), id: \.element.id) { index, product in
                        NavigationLink(value: product) {
                            AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    Color.gray.opacity(0.5)
                                }
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Theme.surface, lineWidth: 2))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: -2, y: 0)
                            .zIndex(Double(3 - index))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                // HİT-TEST ÇAKIŞMA ÇÖZÜMÜ ✅: Bağımsız modern NavigationLink butonu
                NavigationLink(value: recommendation) {
                    HStack(spacing: 6) {
                        Text("Koleksiyonu İncele")
                            .font(.system(size: 13, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.primary, Theme.primary.opacity(0.6), Theme.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.primary.opacity(0.3), lineWidth: 1))
        .shadow(color: Theme.primary.opacity(0.2), radius: 10, x: 0, y: 6)
    }
}

// MARK: - 4. Product Swimlane View
struct ProductSwimlaneView: View {
    let title: String
    let products: [ProductResponse]
    var onAddTapped: (ProductResponse) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.titleFont)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, Theme.spacing)
            
            ScrollView(.horizontal, showsIndicators: false) {
                // NEFES ALAN ARAYÜZ: Boşluk 20'den 24'e çıkarıldı.
                LazyHStack(spacing: 24) {
                    ForEach(products) { product in
                        NavigationLink(value: product) {
                            PremiumProductCardView(product: product, isCompact: true) {
                                onAddTapped(product)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.38)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.spacing)
                .padding(.bottom, 8)
            }
        }
    }
}
