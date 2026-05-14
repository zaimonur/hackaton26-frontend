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
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                            if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 120, height: 120).clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            } else {
                                VStack {
                                    Image(systemName: "photo.badge.plus").font(.system(size: 32))
                                    Text("Görsel Seç").font(Theme.captionFont)
                                }
                                .frame(width: 120, height: 120)
                                .background(Theme.surface).foregroundColor(Theme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Ürün Bilgileri") {
                    TextField("Ürün Adı", text: $viewModel.title)
                    TextField("Kategori (Örn: Giyim)", text: $viewModel.category)
                    TextField("Fiyat", text: $viewModel.price).keyboardType(.decimalPad)
                    
                    // Anahtar Kelime Alanı
                    TextField("Anahtar Kelimeler (Opsiyonel, Örn: kışlık, dar)", text: $viewModel.keywords)
                    
                    // AI Butonu (Güncellenmiş Reaktif Durum)
                    Button {
                        Task { await viewModel.generateAIDescription(token: appState.token) }
                    } label: {
                        HStack(spacing: 8) {
                            if viewModel.isGeneratingAI {
                                ProgressView().tint(.purple)
                                Text("AI Üretiyor...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("AI ile Açıklama Üret")
                            }
                        }
                        .font(Theme.captionFont.bold())
                        .foregroundColor(.purple)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isGeneratingAI)
                    
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.uploadProduct(token: appState.token)
                            if viewModel.alertMessage?.contains("eklendi") == true {
                                onUploadSuccess()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Ürünü Yayına Al").font(Theme.bodyFont.bold())
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Yeni Ürün")
            .scrollDismissesKeyboard(.interactively)
            .alert("Durum", isPresented: $viewModel.showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }
}
