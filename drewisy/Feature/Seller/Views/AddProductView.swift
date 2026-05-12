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
    var onUploadSuccess: () -> Void // Başarılı yükleme sonrası tetiklenir
    
    var body: some View {
        NavigationStack {
            Form {
                // Görsel Bölümü
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
                    TextField("Kategori (Örn: Giyim)", text: $viewModel.category) // YENİDEN EKLENEN KATEGORİ ALANI
                    TextField("Fiyat", text: $viewModel.price).keyboardType(.decimalPad)
                    
                    // ✨ AI Butonu
                    Button {
                        viewModel.description = "Yapay zeka asistanı yakında burada..."
                    } label: {
                        Label("AI ile Açıklama Üret", systemImage: "sparkles")
                            .font(Theme.captionFont.bold())
                            .foregroundColor(.purple)
                    }
                    .buttonStyle(.plain)
                    
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
