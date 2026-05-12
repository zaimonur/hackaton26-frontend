//
//  AddProductView.swift
//  drewisy
//
//  Created by Onur Zaim on 12.05.2026.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    @State private var viewModel = AddProductViewModel()
    @Environment(AppState.self) private var appState
    @FocusState private var focusedField: Field?
    
    enum Field { case title, desc, price, category }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
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
                
                Section("Ürün Detayları") {
                    TextField("Ürün Adı", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                    TextField("Kategori (Örn: Elektronik)", text: $viewModel.category)
                        .focused($focusedField, equals: .category)
                    TextField("Fiyat", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .price)
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                        .focused($focusedField, equals: .desc)
                }
                
                Section {
                    Button {
                        focusedField = nil
                        Task { await viewModel.uploadProduct(token: appState.token) }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Ürünü Kaydet").font(Theme.bodyFont.bold())
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
