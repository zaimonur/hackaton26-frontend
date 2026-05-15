//
//  PanelRootView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct PanelRootView: View {
    @State private var showAddProductSheet = false
    @State private var viewModel = SellerDashboardViewModel() // Paylaşılan ViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        NavigationLink(destination: SellerDashboardView()) {
                            PanelCardView(title: "Satış Performansı", icon: "chart.bar.fill", iconColor: .green)
                        }
                        
                        NavigationLink(destination: MyProductsView()) {
                            PanelCardView(title: "Envanter ve Ürün Yönetimi", icon: "shippingbox.fill", iconColor: Theme.primary)
                        }
                        
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            showAddProductSheet = true
                        } label: {
                            PanelCardView(title: "Yeni Ürün Ekle", icon: "plus.app.fill", iconColor: .orange)
                        }
                        .buttonStyle(.plain)
                        
                        // Gerçek AI Analisti Ekranına Gidiş
                        NavigationLink(destination: PanelSummaryView(viewModel: viewModel)) {
                            PanelCardView(title: "AI İş Analisti", icon: "sparkles", iconColor: .purple, isPremium: true)
                        }
                    }
                    .padding(Theme.spacing)
                }
            }
            .navigationTitle("Satıcı Paneli")
            .sheet(isPresented: $showAddProductSheet) {
                AddProductView(onUploadSuccess: { showAddProductSheet = false })
            }
        }
    }
}

// MARK: - PanelSummaryView (Final Phase 3 UI)

struct PanelSummaryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    var viewModel: SellerDashboardViewModel
    
    @State private var typedText: String = ""
    @State private var isGlowAnimating = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isFetchingAI {
                    loadingStateView
                } else if let summary = viewModel.aiSummary {
                    successStateView(summary: summary)
                }
            }
        }
        .navigationTitle("AI İş Analisti")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchAISummary(token: appState.token)
        }
        .onChange(of: viewModel.aiSummary) { _, newValue in
            if let newValue {
                runTypewriterEffect(fullText: newValue)
            }
        }
    }
    
    // MARK: - States
    
    private var loadingStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            // Parlayan AI Küresi
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                    .blur(radius: isGlowAnimating ? 20 : 10)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isGlowAnimating ? 1.1 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowAnimating = true
                }
            }
            
            VStack(spacing: 8) {
                Text("İş Analistiniz Verileri İnceliyor...")
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                
                Text("Satış trendleri ve müşteri geri bildirimleri harmanlanıyor.")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            ProgressView()
                .tint(.purple)
            
            Spacer()
        }
    }
    
    private func successStateView(summary: String) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("Yapay Zeka Analiz Raporu")
                            .font(Theme.captionFont.bold())
                            .foregroundColor(.purple)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // Markdown Destekli ve Daktilo Efektli Metin
                    Text(LocalizedStringKey(typedText))
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textPrimary)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                }
                .padding(24)
                .background(Theme.surface)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(LinearGradient(colors: [.purple.opacity(0.4), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
                .padding(Theme.spacing)
            }
            
            // Alt Buton (Sticky)
            Button {
                dismiss()
            } label: {
                Text("Anladım, Teşekkürler")
                    .font(Theme.bodyFont.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(Theme.spacing)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - WOW Faktörü: Daktilo Efekti
    private func runTypewriterEffect(fullText: String) {
        typedText = ""
        let characters = Array(fullText)
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if index < characters.count {
                typedText.append(characters[index])
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - PanelCardView ve Diğerleri Aynı Kalıyor...
fileprivate struct PanelCardView: View {
    let title: String
    let icon: String
    let iconColor: Color
    var isPremium: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isPremium ? .white : iconColor)
                .frame(width: 48, height: 48)
                .background(
                    Group {
                        if isPremium {
                            LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                        } else {
                            iconColor.opacity(0.15)
                        }
                    }
                )
                .clipShape(Circle())
            
            Text(title)
                .font(Theme.bodyFont.bold())
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline.bold())
                .foregroundColor(Theme.textSecondary.opacity(0.5))
        }
        .padding(Theme.spacing)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(isPremium ? Color.purple.opacity(0.5) : Theme.textSecondary.opacity(0.1), lineWidth: isPremium ? 1.5 : Theme.borderWidth)
        )
        .shadow(color: isPremium ? Color.purple.opacity(0.15) : .clear, radius: 8, x: 0, y: 4)
    }
}
