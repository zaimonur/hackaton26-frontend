//
//  ProductDetailView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductResponse
    
    @State private var viewModel = ProductDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAssistantSheetPresented = false
    @State private var isPulsing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. HERO SECTION
                HeroSection
                
                VStack(alignment: .leading, spacing: 24) {
                    // 2. AI SUMMARY CARD
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if let detail = viewModel.productDetail, !detail.aiSummary.isEmpty {
                        AISummaryCard(summary: detail.aiSummary)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // 3. DESCRIPTION
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ürün Açıklaması")
                            .font(.headline)
                        Text(viewModel.productDetail?.description ?? product.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // 4. RECENT REVIEWS
                    if let reviews = viewModel.productDetail?.recentReviews, !reviews.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.spacing) {
                            Text("Son Değerlendirmeler")
                                .font(.headline)
                            
                            ForEach(reviews, id: \.id) { review in
                                ReviewRow(review: review)
                            }
                        }
                    }
                    
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, Theme.spacing)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true) // DÜZELTME: Çift geri butonunu önler
        .overlay(alignment: .topLeading) { BackButton }
        .safeAreaInset(edge: .bottom) { BottomActionBar }
        .overlay(alignment: .bottomTrailing) {
             AIFloatingActionButton
                 .padding(.trailing, Theme.spacing)
                 .padding(.bottom, 90)
         }
         .sheet(isPresented: $isAssistantSheetPresented) {
             ProductAIAssistantSheet(viewModel: viewModel, productId: product.id)
         }
        .task {
            await viewModel.fetchProductDetail(productId: product.id)
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

// MARK: - Subviews
extension ProductDetailView {
    
    var HeroSection: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let height = geometry.size.height + (minY > 0 ? minY : 0)
            
            ZKeyStack {
                Group {
                    if let gallery = viewModel.productDetail?.gallery, !gallery.isEmpty {
                        TabView {
                            ForEach(gallery, id: \.self) { url in
                                // DÜZELTME: BaseURL Eklendi
                                AsyncImage(url: URL(string: NetworkManager.baseURL + url)) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.1)
                                }
                            }
                        }
                        .tabViewStyle(.page)
                    } else {
                        // DÜZELTME: BaseURL Eklendi
                        AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.1))
                        }
                    }
                }
                .frame(width: geometry.size.width, height: height)
                .clipped()
                .offset(y: minY > 0 ? -minY : 0)
                .animation(.smooth, value: viewModel.productDetail?.gallery)
                
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.title)
                            .font(.title2.bold())
                        Text(String(format: "%.2f TL", product.price))
                            .font(.title3).fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.spacing)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .offset(y: minY > 0 ? -minY : 0)
            }
            .overlay(alignment: .topTrailing) {
                // SADECE GÖRÜNMEZ AI ROZETİ (aiSentimentBadge) KALDI
                if let badge = viewModel.productDetail?.aiSentimentBadge {
                    Text("✨ \(badge)")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 60)
                        .padding(.trailing, Theme.spacing)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
    }
    
    func AISummaryCard(summary: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Akıllı Özet", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Theme.textSecondary)
            
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.textSecondary.opacity(0.1))
                .background(.ultraThinMaterial)
        )
    }
    
    var BottomActionBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Toplam")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.2f TL", product.price))
                    .font(.headline)
            }
            
            Spacer()
            
            Button {
                // Sepete ekleme aksiyonu
            } label: {
                Text("Sepete Ekle")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 160, height: 50)
                    .background(Theme.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, Theme.spacing)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    var BackButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.title3.bold())
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .padding(.top, 60)
        .padding(.leading, Theme.spacing)
    }
    
    var AIFloatingActionButton: some View {
        Button {
            isAssistantSheetPresented = true
        } label: {
            Image(systemName: "sparkles.tv")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.7)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .shadow(color: Theme.textSecondary.opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
        }
        .onAppear { isPulsing = true }
    }
}

// MARK: - AI Assistant Bottom Sheet
struct ProductAIAssistantSheet: View {
    @Bindable var viewModel: ProductDetailViewModel
    let productId: String
    
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var sheetDetent: PresentationDetent = .fraction(0.4)
    
    var body: some View {
        VStack(spacing: 0) {
            Text("✨ Ürün Asistanına Sor")
                .font(.headline.bold())
                .padding(.vertical, Theme.spacing)
            
            Divider()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Theme.spacing) {
                        if viewModel.chatMessages.isEmpty {
                            Text("Bu ürün hakkında ne öğrenmek istersin?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 24)
                        }
                        
                        ForEach(viewModel.chatMessages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isAskingQuestion {
                            HStack {
                                ProgressView()
                                    .padding()
                                    .background(Theme.primary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("loading")
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.chatMessages.count) {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.isAskingQuestion) {
                    scrollToBottom(proxy: proxy)
                }
            }
            
            HStack {
                TextField("Ürün hakkında sor...", text: $inputText)
                    .focused($isInputFocused)
                    .padding(12)
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onSubmit { sendMessage() }
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : Theme.primary)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isAskingQuestion)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .onChange(of: isInputFocused) { _, isFocused in
            if isFocused {
                sheetDetent = .large
            }
        }
        .presentationDetents([.fraction(0.4), .large], selection: $sheetDetent)
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        
        Task {
            await viewModel.askQuestion(productId: productId, question: text)
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.isAskingQuestion {
                proxy.scrollTo("loading", anchor: .bottom)
            } else if let lastId = viewModel.chatMessages.last?.id {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

// MARK: - Chat Bubble View
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            
            Text(message.text)
                .font(.subheadline)
                .padding(12)
                // DÜZELTME: AI Mesajları için Premium Gradient & Beyaz Yazı
                .background(
                    Group {
                        if message.isUser {
                            Theme.primary
                        } else {
                            LinearGradient(
                                colors: [Theme.primary, Theme.primary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            
            if !message.isUser { Spacer(minLength: 40) }
        }
        .padding(.horizontal, Theme.spacing)
        .transition(.asymmetric(
            insertion: .move(edge: message.isUser ? .trailing : .leading).combined(with: .opacity),
            removal: .opacity
        ))
    }
}

// Yardımcı View: Yorum Satırı
struct ReviewRow: View {
    let review: ReviewResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(review.user_email)
                    .font(.subheadline.bold())
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(index < review.rating ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
            Text(review.comment)
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider().padding(.top, 4)
        }
    }
}

// Custom Container
struct ZKeyStack<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack { content }
    }
}
