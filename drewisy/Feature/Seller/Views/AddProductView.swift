//
//  AddProductView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    @State private var viewModel = AddProductViewModel()
    @Environment(AppState.self) private var appState
    var onUploadSuccess: () -> Void
    
    @State private var aiGlowState = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        gallerySection
                        infoSection
                        aiDescriptionSection
                    }
                    .padding(Theme.spacing)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Yeni Ürün Stüdyosu")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { stickyPublishButton }
            .alert("Durum", isPresented: $viewModel.showAlert) {
                Button("Tamam", role: .cancel) {
                    if viewModel.alertMessage?.contains("eklendi") == true {
                        onUploadSuccess()
                    }
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }
    
    // MARK: - Subcomponents
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ürün Görselleri (Max 5)")
                .font(Theme.bodyFont.bold())
                .foregroundColor(Theme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Ekleme Butonu
                    if viewModel.selectedItems.count < 5 {
                        PhotosPicker(selection: $viewModel.selectedItems, maxSelectionCount: 5, matching: .images) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                Text("Fotoğraf\nEkle")
                                    .font(Theme.captionFont)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 100, height: 130)
                            .background(Theme.surface)
                            .foregroundColor(Theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6])))
                        }
                    }
                    
                    // Seçilen Görseller (Galeri)
                    ForEach(Array(viewModel.selectedImagesData.enumerated()), id: \.offset) { index, data in
                        if let uiImage = UIImage(data: data) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                
                                // Kapak Rozeti
                                if index == 0 {
                                    Text("KAPAK")
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 4)
                                        .background(Theme.primary)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                        .offset(x: -4, y: 4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                }
                                
                                // Silme Butonu
                                Button {
                                    withAnimation { viewModel.removeImage(at: index) }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .padding(6)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: 16) {
            customTextField(placeholder: "Ürün Adı", text: $viewModel.title)
            customTextField(placeholder: "Kategori (Örn: Giyim)", text: $viewModel.category)
            customTextField(placeholder: "Fiyat (₺)", text: $viewModel.price, keyboardType: .decimalPad)
            customTextField(placeholder: "Anahtar Kelimeler (Kışlık, Dar vb.)", text: $viewModel.keywords)
        }
        .padding(Theme.spacing)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
    }
    
    private var aiDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ürün Açıklaması")
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    Task { await viewModel.generateAIDescription(token: appState.token) }
                } label: {
                    HStack(spacing: 4) {
                        if viewModel.isGeneratingAI {
                            ProgressView().tint(.purple)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text("AI ile Üret")
                    }
                    .font(Theme.captionFont.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isGeneratingAI)
            }
            
            TextEditor(text: $viewModel.description)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Theme.background)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(viewModel.isGeneratingAI ? Color.purple : Theme.textSecondary.opacity(0.2), lineWidth: viewModel.isGeneratingAI ? 2 : 1)
                )
                .shadow(color: viewModel.isGeneratingAI ? Color.purple.opacity(0.6) : .clear, radius: aiGlowState ? 8 : 0)
                .onChange(of: viewModel.isGeneratingAI) { _, isGen in
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        aiGlowState = isGen
                    }
                }
        }
        .padding(Theme.spacing)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
    }
    
    private var stickyPublishButton: some View {
        VStack {
            Button {
                Task { await viewModel.uploadProduct(token: appState.token) }
            } label: {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Ürünü Yayına Al")
                    }
                    .font(Theme.bodyFont.bold())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Theme.primary)
            .foregroundColor(.white)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
            .disabled(viewModel.isLoading)
        }
        .padding(Theme.spacing)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height: Theme.borderWidth).foregroundColor(Theme.textSecondary.opacity(0.1)), alignment: .top)
    }
    
    // MARK: - UI Helpers
    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .padding()
            .frame(height: Theme.inputHeight)
            .background(Theme.background)
            .cornerRadius(Theme.cornerRadius)
            .foregroundColor(Theme.textPrimary)
            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1))
    }
}
