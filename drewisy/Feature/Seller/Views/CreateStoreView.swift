//
//  CreateStoreView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct CreateStoreView: View {
    @Environment(AppState.self) private var appState
    @State private var name = ""
    @State private var desc = ""
    @State private var isLoading = false
    var onSuccess: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "storefront.circle.fill")
                            .font(.system(size: 80)).foregroundColor(Theme.primary)
                        Text("Mağazanızı Oluşturun")
                            .font(Theme.titleFont).foregroundColor(Theme.textPrimary)
                        Text("Satış yapmaya başlamak için mağaza detaylarını girin.")
                            .font(Theme.bodyFont).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        customField(placeholder: "Mağaza Adı", text: $name)
                        customTextEditor(placeholder: "Mağaza Açıklaması", text: $desc)
                    }
                    
                    Button {
                        createStore()
                    } label: {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("Mağazayı Başlat").font(Theme.bodyFont.bold()) }
                    }
                    .frame(maxWidth: .infinity).frame(height: Theme.inputHeight)
                    .background(Theme.primary).foregroundColor(.white).cornerRadius(Theme.cornerRadius)
                    .disabled(name.isEmpty || isLoading)
                    
                    Spacer()
                }
                .padding(Theme.spacing)
            }
            .navigationTitle("Yeni Mağaza")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func createStore() {
        isLoading = true
        Task {
            do {
                let req = CreateStoreRequest(name: name, description: desc)
                let _: StoreResponse = try await NetworkManager.shared.request(
                    url: "http://localhost:8080/api/v1/stores",
                    method: "POST",
                    body: req,
                    token: appState.token
                )
                onSuccess()
            } catch {
                // Hata yönetimi (Toast vb. eklenebilir)
            }
            isLoading = false
        }
    }
    
    // UI Helpers (Theme Standartlarında)
    private func customField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding().frame(height: Theme.inputHeight)
            .background(Theme.surface).cornerRadius(Theme.cornerRadius)
            .foregroundColor(Theme.textPrimary)
    }
    
    private func customTextEditor(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder).foregroundColor(Theme.textSecondary.opacity(0.5)).padding(.top, 12).padding(.leading, 16)
            }
            TextEditor(text: text)
                .scrollContentBackground(.hidden).padding(8)
                .background(Theme.surface).cornerRadius(Theme.cornerRadius)
                .foregroundColor(Theme.textPrimary).frame(height: 120)
        }
    }
}
