//
//  SellerProductPreviewView.swift
//  drewisy
//
//  Created by Onur Zaim on 15.05.2026.
//

import SwiftUI

struct SellerProductPreviewView: View {
    let product: ProductResponse
    @State private var viewModel = ProductDetailViewModel()
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero (Görsel ve Temel Bilgiler)
                    PreviewHeroSection(product: product)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Açıklama
                        PreviewDescriptionSection(description: product.description)
                        
                        Divider().background(Theme.textSecondary.opacity(0.2))

                        // Yorumlar ve AI Analizi (Salt-Okunur)
                        PreviewReviewsSection(
                            productId: product.id,
                            viewModel: viewModel
                        )
                    }
                    .padding(.horizontal, Theme.spacing)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Ürün Önizleme")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Sadece veri çekme işlemleri
            await viewModel.fetchReviews(productId: product.id)
        }
    }
}

// MARK: - Sub-components (Read-Only)

fileprivate struct PreviewHeroSection: View {
    let product: ProductResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                switch phase {
                case .empty:
                    Theme.surface
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    Theme.surface.overlay(Image(systemName: "photo").foregroundColor(Theme.textSecondary))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 350)
            .clipped()
            .background(Theme.surface)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.title.bold())
                    .foregroundColor(Theme.textPrimary)
                
                HStack {
                    Text(product.store_name)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.primary)
                    Text("•")
                    Text(product.category)
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Text("\(product.price, specifier: "%.2f") ₺")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Theme.primary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, Theme.spacing)
        }
    }
}

fileprivate struct PreviewDescriptionSection: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ürün Açıklaması")
                .font(Theme.titleFont)
                .foregroundColor(Theme.textPrimary)
            
            Text(description)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(4)
        }
    }
}

fileprivate struct PreviewReviewsSection: View {
    let productId: String
    var viewModel: ProductDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            aiAssistantModule
            commentsListView
        }
    }
    
    @ViewBuilder
    private var aiAssistantModule: some View {
        if let aiSummary = viewModel.aiSummary {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Yapay Zeka Analizi")
                }
                .font(Theme.bodyFont.bold())
                .foregroundColor(.purple)
                
                Text(aiSummary)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textPrimary)
                    .lineSpacing(4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.08))
            .cornerRadius(Theme.cornerRadius)
            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Color.purple.opacity(0.2), lineWidth: 1))
        } else if viewModel.isFetchingAISummary {
            HStack(spacing: 12) {
                ProgressView().tint(.purple)
                Text("Analiz Hazırlanıyor...").font(Theme.captionFont).foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity).padding()
            .background(Theme.surface).cornerRadius(Theme.cornerRadius)
        } else {
            Button {
                Task { await viewModel.fetchAISummary(productId: productId) }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Müşteri Yorumlarını AI ile Analiz Et")
                }
                .font(Theme.bodyFont.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(Theme.cornerRadius)
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Müşteri Değerlendirmeleri")
                .font(Theme.titleFont)
                .foregroundColor(Theme.textPrimary)
            
            if let summary = viewModel.reviewsSummary {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", summary.average_rating)).bold()
                    Text("(\(summary.total_reviews) yorum)").foregroundColor(Theme.textSecondary)
                }
                .font(Theme.captionFont)
            }
        }
    }
    
    private var commentsListView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView().tint(Theme.primary).frame(maxWidth: .infinity).padding()
            } else if let summary = viewModel.reviewsSummary, !summary.reviews.isEmpty {
                ForEach(summary.reviews) { review in
                    PreviewReviewCard(review: review)
                }
            } else {
                Text("Henüz değerlendirme bulunmuyor.")
                    .font(Theme.captionFont).foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center).padding()
            }
        }
    }
}

fileprivate struct PreviewReviewCard: View {
    let review: ReviewResponse
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.user_email).font(Theme.captionFont.bold())
                Spacer()
                Text(review.created_at).font(.system(size: 10)).foregroundColor(Theme.textSecondary)
            }
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < review.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow).font(.system(size: 10))
                }
            }
            Text(review.comment).font(Theme.captionFont).foregroundColor(Theme.textSecondary)
        }
        .padding().background(Theme.surface).cornerRadius(Theme.cornerRadius)
    }
}
