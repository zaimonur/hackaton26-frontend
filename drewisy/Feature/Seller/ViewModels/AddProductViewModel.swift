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
    var stock = ""
    
    var availableCategories: [String] = []
    
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
    
    // MARK: - API Calls
    
    @MainActor
    func fetchCategories() async {
        do {
            let fetchedCategories: [String] = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/categories",
                body: String?.none,
                token: nil
            )
            self.availableCategories = fetchedCategories
            
            // Eğer kategori seçilmemişse ve liste boş değilse ilkini varsayılan yap
            if self.category.isEmpty, let firstCategory = fetchedCategories.first {
                self.category = firstCategory
            }
        } catch {
            print("Kategoriler çekilemedi: \(error.localizedDescription)")
            // UX kararı: Kategori çekilemezse upload zaten patlayacağı için sessizce logluyoruz,
            // dilersek alert de fırlatabiliriz.
        }
    }
    
    @MainActor
    func uploadProduct(token: String?) async {
        guard let token else { return }
        
        // Form Doğrulama
        guard !title.isEmpty, !price.isEmpty, !category.isEmpty, !stock.isEmpty, !selectedImagesData.isEmpty else {
            alertMessage = "Lütfen en az bir görsel dahil tüm zorunlu alanları doldurun."
            showAlert = true
            return
        }
        
        guard Int(stock) != nil else {
            alertMessage = "Stok adedi geçerli bir tam sayı olmalıdır."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let formattedPrice = price.replacingOccurrences(of: ",", with: ".")
        
        // Multipart form-data text alanları (Tümü String olmak zorundadır, backend parse eder)
        let fields = [
            "title": title,
            "description": description,
            "price": formattedPrice,
            "category": category,
            "stock": stock
        ]
        
        do {
            let _: DummyProductResponse = try await NetworkManager.shared.uploadMultipartImages(
                url: "\(NetworkManager.baseURL)/api/v1/products",
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
                url: "\(NetworkManager.baseURL)/api/v1/ai/generate-description",
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
    
    // MARK: - Helpers
    
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
        stock = ""
        // category'i temizlemiyoruz, varsayılan kalabilir.
        keywords = ""
        selectedItems.removeAll()
        selectedImagesData.removeAll()
    }
}
