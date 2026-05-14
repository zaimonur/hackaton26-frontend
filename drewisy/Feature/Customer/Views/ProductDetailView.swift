//
//  ProductDetailView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductResponse
    
    @Environment(CartManager.self) private var cartManager
    @Environment(AppState.self) private var appState
    
    @State private var viewModel = ProductDetailViewModel()
    @State private var quantity: Int = 1
    
    @State private var showAddReviewSheet = false
    @State private var showLoginAlert = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HeroSection(product: product)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        DescriptionSection(description: product.description)
                        
                        Divider().background(Theme.textSecondary.opacity(0.2))

                        ReviewsSection(
                            productId: product.id,
                            viewModel: viewModel,
                            appState: appState,
                            showAddReviewSheet: $showAddReviewSheet,
                            showLoginAlert: $showLoginAlert
                        )
                    }
                    .padding(.horizontal, Theme.spacing)
                }
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            BottomActionBar(product: product, quantity: $quantity) {
                cartManager.addToCart(product: product, quantity: quantity)
            }
        }
        .task {
            // Sadece yorumlar çekilir, AI özeti butona basılınca çekilecek
            await viewModel.fetchReviews(productId: product.id)
        }
        .sheet(isPresented: $showAddReviewSheet) {
            AddReviewView(productId: product.id, viewModel: viewModel)
        }
        .alert("Giriş Gerekli", isPresented: $showLoginAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Değerlendirme yapabilmek için lütfen hesabınıza giriş yapın.")
        }
    }
}

// MARK: - Sub-components

fileprivate struct HeroSection: View {
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

fileprivate struct DescriptionSection: View {
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

fileprivate struct ReviewsSection: View {
    let productId: String
    var viewModel: ProductDetailViewModel
    var appState: AppState
    @Binding var showAddReviewSheet: Bool
    @Binding var showLoginAlert: Bool
    
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
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.08))
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
            )
            .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity))
        } else if viewModel.isFetchingAISummary {
            HStack(spacing: 12) {
                ProgressView()
                    .tint(.purple)
                Text("Yapay Zeka Yorumları Okuyor...")
                    .font(Theme.captionFont)
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
        } else {
            Button {
                Task {
                        await viewModel.fetchAISummary(productId: productId)
                    }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                    Text("Yapay Zeka'dan Yorum Özeti İste")
                        .font(Theme.bodyFont.bold())
                }
                .animation(.spring(), value: viewModel.isFetchingAISummary)
                .animation(.spring(), value: viewModel.aiSummary)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(Theme.cornerRadius)
                .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Değerlendirmeler")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                
                if let summary = viewModel.reviewsSummary {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", summary.average_rating)).bold()
                        Text("(\(summary.total_reviews))").foregroundColor(Theme.textSecondary)
                    }
                    .font(Theme.captionFont)
                }
            }
            Spacer()
            Button {
                if appState.isAuthenticated { showAddReviewSheet = true }
                else { showLoginAlert = true }
            } label: {
                Label("Yorum Yap", systemImage: "square.and.pencil")
                    .font(Theme.captionFont.bold())
                    .foregroundColor(Theme.primary)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Theme.primary.opacity(0.1))
                    .cornerRadius(16)
            }
        }
    }
    
    private var commentsListView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView().tint(Theme.primary).frame(maxWidth: .infinity).padding()
            } else if let summary = viewModel.reviewsSummary, !summary.reviews.isEmpty {
                ForEach(summary.reviews) { review in
                    ReviewCard(review: review)
                }
            } else {
                Text("Henüz değerlendirme yapılmamış.")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

fileprivate struct ReviewCard: View {
    let review: ReviewResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.user_email)
                    .font(Theme.captionFont.bold())
                Spacer()
                Text(review.created_at)
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
            }
            
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < review.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                }
            }
            
            Text(review.comment)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
    }
}

fileprivate struct BottomActionBar: View {
    let product: ProductResponse
    @Binding var quantity: Int
    let onAdd: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                HStack(spacing: 12) {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                        Image(systemName: "minus")
                            .frame(width: 32, height: 32)
                            .background(Theme.background)
                            .clipShape(Circle())
                    }
                    
                    Text("\(quantity)")
                        .font(Theme.bodyFont.bold())
                        .frame(minWidth: 24)
                    
                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus")
                            .frame(width: 32, height: 32)
                            .background(Theme.background)
                            .clipShape(Circle())
                    }
                }
                .padding(8)
                .background(Theme.surface)
                .cornerRadius(24)
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onAdd()
                }) {
                    Text("Sepete Ekle")
                        .font(Theme.bodyFont.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Theme.primary)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding(Theme.spacing)
            .background(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .frame(height: Theme.borderWidth)
                    .foregroundColor(Theme.textSecondary.opacity(0.1)),
                alignment: .top
            )
        }
    }
}
