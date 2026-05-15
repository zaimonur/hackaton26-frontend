//
//  AddProductViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 12.05.2026.
//

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
    var keywords = ""
    
    // EKLENDİ: Çoklu görsel yönetimi
    var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            Task { await loadTransferables(from: selectedItems) }
        }
    }
    var selectedImagesData: [Data] = []
    
    var isLoading = false
    var isGeneratingAI = false
    
    var alertMessage: String?
    var showAlert = false
    
    @MainActor
    func uploadProduct(token: String?) async {
        guard let token else { return }
        guard !title.isEmpty, !price.isEmpty, !category.isEmpty, !selectedImagesData.isEmpty else {
            alertMessage = "Lütfen en az bir görsel dahil tüm zorunlu alanları doldurun."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let formattedPrice = price.replacingOccurrences(of: ",", with: ".")
        let fields = ["title": title, "description": description, "price": formattedPrice, "category": category]
        
        do {
            // Çoklu dosya yükleme servisi çağrısı
            let _: DummyProductResponse = try await NetworkManager.shared.uploadMultipartImages(
                url: "http://localhost:8080/api/v1/products",
                fields: fields,
                filesData: selectedImagesData,
                fileField: "images",
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
    
    // EKLENDİ: Birden fazla fotoğrafı işleyen yeni metod
    private func loadTransferables(from items: [PhotosPickerItem]) async {
        var newImagesData: [Data] = []
        
        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    newImagesData.append(data)
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = "Görsellerden biri okunamadı."
                    self.showAlert = true
                }
            }
        }
        
        await MainActor.run { self.selectedImagesData = newImagesData }
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImagesData.count, index < selectedItems.count else { return }
        selectedImagesData.remove(at: index)
        selectedItems.remove(at: index)
    }
    
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        category = ""
        keywords = ""
        selectedItems.removeAll()
        selectedImagesData.removeAll()
    }
}
