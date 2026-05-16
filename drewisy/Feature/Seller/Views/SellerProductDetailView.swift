//
//  SellerProductDetailView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI
import PhotosUI

struct SellerProductDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SellerProductDetailViewModel
    
    @State private var showDeleteAlert = false
    @State private var aiGlowState = false // EKLENDİ: AI Animasyon State'i
    
    init(product: ProductResponse) {
        _viewModel = State(initialValue: SellerProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    gallerySection
                    infoSection
                    deleteButtonSection
                }
                .padding(Theme.spacing)
                .padding(.bottom, 60) // Yapışkan buton için ekstra boşluk
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Ürünü Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { stickySaveButton }
        .task {
            await viewModel.fetchCategories()
        }
        .alert("Durum", isPresented: $viewModel.showAlert) {
            Button("Tamam", role: .cancel) {
                if viewModel.isUpdateSuccessful {
                    dismiss()
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Ürünü Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    let success = await viewModel.deleteProduct(token: appState.token)
                    if success { dismiss() }
                }
            }
        } message: {
            Text("Bu ürünü silmek istediğinize emin misiniz? Bu işlem geri alınamaz.")
        }
    }
    
    // MARK: - Subcomponents
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ürün Görselleri (Max 5)")
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("\(viewModel.existingImages.count + viewModel.newImagesData.count)/5")
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    
                    // 1. Yeni Görsel Ekleme Butonu (Eğer limit dolmadıysa)
                    let totalImages = viewModel.existingImages.count + viewModel.newImagesData.count
                    if totalImages < 5 {
                        PhotosPicker(selection: $viewModel.newSelectedItems, maxSelectionCount: 5 - viewModel.existingImages.count, matching: .images) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill").font(.system(size: 24))
                                Text("Fotoğraf\nEkle").font(Theme.captionFont).multilineTextAlignment(.center)
                            }
                            .frame(width: 100, height: 130)
                            .background(Theme.surface)
                            .foregroundColor(Theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6])))
                        }
                    }
                    
                    // 2. Mevcut (Existing) Görseller
                    ForEach(Array(viewModel.existingImages.enumerated()), id: \.offset) { index, imagePath in
                        ZStack(alignment: .topTrailing) {
                            AsyncImage(url: URL(string: NetworkManager.baseURL + imagePath)) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    Theme.surface // Skeleton loading state
                                }
                            }
                            .frame(width: 100, height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            
                            // KARAR 3: Mutlak Index 0 Kontrolü (Mevcutların başı)
                            if index == 0 {
                                coverBadge
                            }
                            
                            removeButton { withAnimation { viewModel.removeExistingImage(at: index) } }
                        }
                    }
                    
                    // 3. Yeni (New) Eklenen Görseller
                    ForEach(Array(viewModel.newImagesData.enumerated()), id: \.offset) { index, data in
                        if let uiImage = UIImage(data: data) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                                
                                // KARAR 3: Mevcut listesi tamamen silinmişse, yeni listenin başı Kapak olur.
                                if viewModel.existingImages.isEmpty && index == 0 {
                                    coverBadge
                                }
                                
                                removeButton { withAnimation { viewModel.removeNewImage(at: index) } }
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
            
            // Kategori Picker
            if viewModel.availableCategories.isEmpty {
                HStack {
                    Text("Kategoriler Yükleniyor...").foregroundColor(Theme.textSecondary)
                    Spacer()
                    ProgressView().tint(Theme.primary)
                }
                .padding().frame(height: Theme.inputHeight)
                .background(Theme.background).cornerRadius(Theme.cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1))
            } else {
                HStack {
                    Text("Kategori").foregroundColor(Theme.textSecondary)
                    Spacer()
                    Picker("", selection: $viewModel.category) {
                        ForEach(viewModel.availableCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.textPrimary)
                }
                .padding(.leading).frame(height: Theme.inputHeight)
                .background(Theme.background).cornerRadius(Theme.cornerRadius)
                .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1))
            }
            
            // Fiyat ve Stok
            HStack(spacing: 16) {
                customTextField(placeholder: "Fiyat (₺)", text: $viewModel.price, keyboardType: .decimalPad)
                customTextField(placeholder: "Stok Adedi", text: $viewModel.stock, keyboardType: .numberPad)
            }
            
            // EKLENDİ: AI Anahtar Kelimeler
            customTextField(placeholder: "Anahtar Kelimeler (Kışlık, Dar vb.)", text: $viewModel.keywords)
            
            // EKLENDİ: AI Açıklama Bölümü (AddProductView ile aynı)
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
        }
        .padding(Theme.spacing)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
    }
    
    // MARK: - Buttons & Badges
    
    private var stickySaveButton: some View {
        VStack {
            Button {
                Task { await viewModel.updateProduct(token: appState.token) }
            } label: {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Değişiklikleri Kaydet")
                    }
                    .font(Theme.bodyFont.bold())
                }
            }
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(Theme.primary).foregroundColor(.white).cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
            .disabled(viewModel.isLoading || viewModel.isDeleting)
        }
        .padding(Theme.spacing)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height: Theme.borderWidth).foregroundColor(Theme.textSecondary.opacity(0.1)), alignment: .top)
    }
    
    private var deleteButtonSection: some View {
        Button {
            showDeleteAlert = true
        } label: {
            if viewModel.isDeleting {
                ProgressView().tint(.red)
            } else {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Ürünü Kalıcı Olarak Sil")
                }
            }
        }
        .font(Theme.bodyFont.bold())
        .foregroundColor(.red)
        .frame(maxWidth: .infinity).frame(height: Theme.inputHeight)
        .background(Color.red.opacity(0.1))
        .cornerRadius(Theme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Color.red.opacity(0.3), lineWidth: 1))
        .disabled(viewModel.isLoading || viewModel.isDeleting)
    }
    
    private var coverBadge: some View {
        Text("KAPAK")
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Theme.primary)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .offset(x: -4, y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            // Animasyon sırasında rozetin titrememesi/aniden kaybolmaması için zIndex
            .zIndex(1)
    }
    
    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.white)
                .background(Circle().fill(Color.black.opacity(0.6)))
        }
        .padding(6)
    }
    
    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .padding().frame(height: Theme.inputHeight)
            .background(Theme.background).cornerRadius(Theme.cornerRadius)
            .foregroundColor(Theme.textPrimary)
            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1))
    }
}
