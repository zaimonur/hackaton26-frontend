//
//  AddReviewView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct AddReviewView: View {
    let productId: String
    var viewModel: ProductDetailViewModel // Parent'ın ViewModel referansını alıyoruz
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss // Sheet'i kapatmak için
    
    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                Form {
                    Section("Puanınız") {
                        HStack {
                            Spacer()
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 32))
                                    .onTapGesture {
                                        withAnimation { rating = index }
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Theme.surface)
                    }
                    
                    Section("Yorumunuz") {
                        TextEditor(text: $comment)
                            .frame(height: 120)
                            .scrollContentBackground(.hidden)
                            .background(Theme.surface)
                            .foregroundColor(Theme.textPrimary)
                            .listRowBackground(Theme.surface)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Değerlendirme Yap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gönder") {
                        Task { await performSubmit() }
                    }
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.primary)
                    .disabled(rating == 0 || comment.isEmpty || viewModel.isSubmittingReview)
                }
            }
            .alert("Hata", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Beklenmeyen bir hata oluştu.")
            }
            .overlay {
                if viewModel.isSubmittingReview {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView().tint(.white)
                    }
                }
            }
        }
    }
    
    // Auto-dismiss logic burada yönetiliyor
    private func performSubmit() async {
        let success = await viewModel.submitReview(productId: productId, rating: rating, comment: comment, token: appState.token)
        if success {
            dismiss() // İşlem başarılıysa sheet'i otomatik kapat
        } else {
            showAlert = true
        }
    }
}
