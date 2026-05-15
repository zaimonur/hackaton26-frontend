//
//  SellerProductDetailView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct SellerProductDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: SellerProductDetailViewModel
    @State private var showDeleteAlert = false
    
    // ViewModel'in ProductResponse ile ilklendirilmesi için özel init
    init(product: ProductResponse) {
        _viewModel = State(initialValue: SellerProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection
                    descriptionSection
                    quickEditPanel
                    deleteButtonSection
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Ürün Detayı")
        .navigationBarTitleDisplayMode(.inline)
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
        // Hata mesajı yönetimi
        .alert("Hata", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: URL(string: NetworkManager.baseURL + viewModel.product.image_path)) { phase in
                switch phase {
                case .empty:
                    ProgressView().tint(Theme.primary)
                        .frame(maxWidth: .infinity).frame(height: 300)
                case .success(let image):
                    image.resizable().scaledToFill()
                        .frame(maxWidth: .infinity).frame(height: 300)
                        .clipped()
                case .failure:
                    Theme.surface
                        .frame(maxWidth: .infinity).frame(height: 300)
                        .overlay(Image(systemName: "photo").foregroundColor(Theme.textSecondary))
                @unknown default:
                    EmptyView()
                }
            }
            .background(Theme.surface)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.product.category.uppercased())
                    .font(Theme.captionFont.bold())
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Theme.primary.opacity(0.1))
                    .foregroundColor(Theme.primary)
                    .cornerRadius(8)
                
                Text(viewModel.product.title)
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
            }
            .padding(.horizontal, Theme.spacing)
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ürün Açıklaması")
                .font(Theme.bodyFont.bold())
                .foregroundColor(Theme.textPrimary)
            
            Text(viewModel.product.description)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, Theme.spacing)
    }
    
    // MARK: - Quick Edit Panel
    private var quickEditPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı Düzenleme")
                .font(Theme.bodyFont.bold())
                .foregroundColor(Theme.textPrimary)
            
            VStack(spacing: 12) {
                // Fiyat Girişi
                HStack {
                    Text("Fiyat (₺)").font(Theme.captionFont).foregroundColor(Theme.textSecondary)
                    Spacer()
                    TextField("0.00", text: $viewModel.newPrice)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(Theme.bodyFont.bold())
                        .foregroundColor(Theme.primary)
                }
                .padding().frame(height: Theme.inputHeight)
                .background(Theme.background).cornerRadius(Theme.cornerRadius)
                
                // Stok Girişi
                HStack {
                    Text("Stok Adedi").font(Theme.captionFont).foregroundColor(Theme.textSecondary)
                    Spacer()
                    Stepper(value: $viewModel.newStock, in: 0...9999) {
                        Text("\(viewModel.newStock)")
                            .font(Theme.bodyFont.bold())
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                .padding().frame(height: Theme.inputHeight)
                .background(Theme.background).cornerRadius(Theme.cornerRadius)
            }
            
            Button {
                Task { await viewModel.updateProduct(token: appState.token) }
            } label: {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Bilgileri Güncelle").font(Theme.bodyFont.bold())
                }
            }
            .frame(maxWidth: .infinity).frame(height: Theme.inputHeight)
            .background(Theme.primary).foregroundColor(.white)
            .cornerRadius(Theme.cornerRadius)
            .disabled(viewModel.isLoading)
        }
        .padding(Theme.spacing)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
        .padding(.horizontal, Theme.spacing)
    }
    
    // MARK: - Delete Section
    private var deleteButtonSection: some View {
        Button {
            showDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Ürünü Sil")
            }
            .font(Theme.bodyFont.bold())
            .foregroundColor(.red)
            .frame(maxWidth: .infinity).frame(height: Theme.inputHeight)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.red, lineWidth: 1)
            )
        }
        .padding(.horizontal, Theme.spacing)
        .padding(.top, 24)
    }
}
