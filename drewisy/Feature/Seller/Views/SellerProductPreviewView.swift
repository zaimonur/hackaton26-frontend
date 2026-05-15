import SwiftUI

struct SellerProductPreviewView: View {
    let product: ProductResponse
    @State private var viewModel = ProductDetailViewModel()
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. HERO SECTION
                    PreviewHeroSection(product: product)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // 2. AI SUMMARY
                        if let detail = viewModel.productDetail, !detail.aiSummary.isEmpty {
                            PreviewAISummaryCard(summary: detail.aiSummary)
                        }
                        
                        // 3. DESCRIPTION
                        PreviewDescriptionSection(description: viewModel.productDetail?.description ?? product.description)
                        
                        Divider()

                        // 4. REVIEWS SECTION
                        PreviewReviewsSection(viewModel: viewModel)
                    }
                    .padding(.horizontal, Theme.spacing)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Ürün Önizleme")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Tek bir kaynaktan zengin veriyi çekiyoruz
            await viewModel.fetchProductDetail(productId: product.id)
        }
    }
}

// MARK: - Helper Views
fileprivate struct PreviewHeroSection: View {
    let product: ProductResponse
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: product.image_path)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .clipped()
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(String(format: "%.2f TL", product.price))
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(Theme.spacing)
        }
    }
}

fileprivate struct PreviewAISummaryCard: View {
    let summary: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Akıllı Özet", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
            Text(summary)
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.textSecondary.opacity(0.1))
        )
    }
}

fileprivate struct PreviewDescriptionSection: View {
    let description: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ürün Açıklaması").font(.headline)
            Text(description).font(.subheadline).foregroundColor(.secondary)
        }
    }
}

fileprivate struct PreviewReviewsSection: View {
    let viewModel: ProductDetailViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacing) {
            Text("Değerlendirmeler").font(.headline)
            
            if viewModel.isLoading {
                ProgressView().tint(Theme.primary).frame(maxWidth: .infinity).padding()
            } else if let detail = viewModel.productDetail, !detail.recentReviews.isEmpty {
                ForEach(detail.recentReviews) { review in
                    PreviewReviewCard(review: review)
                }
            } else {
                Text("Henüz değerlendirme bulunmuyor.")
                    .font(.subheadline).foregroundColor(.secondary)
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
                Text(review.user_email).font(.subheadline.bold())
                Spacer()
                Text(review.created_at).font(.caption2).foregroundColor(.secondary)
            }
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < review.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow).font(.caption2)
                }
            }
            Text(review.comment).font(.caption).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(Theme.cornerRadius)
    }
}
