//
//  AddProductViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 12.05.2026.
//

// Feature/Seller/ViewModels/AddProductViewModel.swift

import SwiftUI
import PhotosUI
import Observation

struct DummyProductResponse: Decodable {
    let id: String
}

@Observable
final class AddProductViewModel {
    var title = ""
    var description = ""
    var price = ""
    var category = ""
    var keywords = "" // AI için anahtar kelimeler
    
    var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task { await loadTransferable(from: selectedItem) }
        }
    }
    var selectedImageData: Data? = nil
    
    var isLoading = false
    var isGeneratingAI = false // AI yükleme durumu
    
    var alertMessage: String?
    var showAlert = false
    
    @MainActor
    func uploadProduct(token: String?) async {
        guard let token else { return }
        guard !title.isEmpty, !price.isEmpty, !category.isEmpty, let fileData = selectedImageData else {
            alertMessage = "Lütfen görsel dahil tüm alanları doldurun."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let formattedPrice = price.replacingOccurrences(of: ",", with: ".")
        let fields = ["title": title, "description": description, "price": formattedPrice, "category": category]
        
        do {
            let _: DummyProductResponse = try await NetworkManager.shared.uploadMultipart(
                url: "http://localhost:8080/api/v1/products",
                fields: fields,
                fileData: fileData,
                fileName: "product.jpg",
                mimeType: "image/jpeg",
                token: token
            )
            alertMessage = "Ürün kataloğa eklendi!"
            clearForm()
        } catch let error as APIError {
            alertMessage = error.localizedDescription
        } catch {
            alertMessage = "Bilinmeyen bir hata oluştu."
        }
        
        showAlert = true
        isLoading = false
    }
    
    // Yapay Zeka İstek Fonksiyonu
    @MainActor
    func generateAIDescription(token: String?) async {
        guard let token else { return }
        guard !title.isEmpty, !category.isEmpty else {
            alertMessage = "AI ile açıklama üretmek için ürün adı ve kategorisi zorunludur."
            showAlert = true
            return
        }
        
        isGeneratingAI = true
        
        let req = GenerateDescriptionRequest(title: title, category: category, keywords: keywords)
        
        do {
            let response: GenerateDescriptionResponse = try await NetworkManager.shared.request(
                url: "http://localhost:8080/api/v1/ai/generate-description",
                method: "POST",
                body: req,
                token: token
            )
            self.description = response.generated_description
        } catch let error as APIError {
            alertMessage = error.localizedDescription
            showAlert = true
        } catch {
            alertMessage = "Yapay zeka servisine ulaşılamadı."
            showAlert = true
        }
        
        isGeneratingAI = false
    }
    
    private func loadTransferable(from item: PhotosPickerItem?) async {
        guard let item else {
            await MainActor.run { self.selectedImageData = nil }
            return
        }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run { self.selectedImageData = data }
            }
        } catch {
            await MainActor.run {
                self.selectedImageData = nil
                self.alertMessage = "Görsel formatı okunamadı. Lütfen farklı bir görsel seçin."
                self.showAlert = true
            }
        }
    }
    
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        category = ""
        keywords = ""
        selectedItem = nil
        selectedImageData = nil
    }
}
