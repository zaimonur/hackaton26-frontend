//
//  SellerProductDetailViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI
import PhotosUI
import Observation

@Observable
final class SellerProductDetailViewModel {
    // Referans Ürün
    var product: ProductResponse
    
    // Form States
    var title: String
    var description: String
    var price: String
    var category: String
    var stock: String
    var keywords: String = "" // EKLENDİ: AI Anahtar Kelimeleri
    
    // Kategori State'i
    var availableCategories: [String] = []
    
    // Görsel States (Mevcut ve Yeni)
    var existingImages: [String]
    var newSelectedItems: [PhotosPickerItem] = [] {
        didSet {
            Task { await loadTransferables(from: newSelectedItems) }
        }
    }
    var newImagesData: [Data] = []
    
    // UI States
    var isLoading = false
    var isDeleting = false
    var isGeneratingAI = false // AI Yüklenme State'i
    var errorMessage: String?
    var showAlert = false
    var isUpdateSuccessful = false
    
    init(product: ProductResponse) {
        self.product = product
        self.title = product.title
        self.description = product.description
        self.price = String(format: "%.2f", product.price)
        self.category = product.category
        self.stock = String(product.stock)
        
        // Mevcut görselleri doldur
        if !product.gallery.isEmpty {
            self.existingImages = product.gallery
        } else if !product.image_path.isEmpty {
            self.existingImages = [product.image_path]
        } else {
            self.existingImages = []
        }
    }
    
    // MARK: - Kategori Fetch (Güvenli Mutasyon)
    @MainActor
    func fetchCategories() async {
        do {
            let fetchedCategories: [String] = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/categories",
                body: String?.none,
                token: nil
            )
            var mutableCategories = fetchedCategories
            
            // Eğer mevcut kategori backend'den gelen listede yoksa, listenin EN BAŞINA ekle.
            if !mutableCategories.contains(self.category) {
                mutableCategories.insert(self.category, at: 0)
            }
            
            self.availableCategories = mutableCategories
            
        } catch {
            // İstek patlarsa, Picker'ın kırılmaması için mevcut kategoriyi liste olarak sun.
            self.availableCategories = [self.category]
        }
    }
    
    // MARK: - Update İşlemi
    @MainActor
    func updateProduct(token: String?) async -> Bool {
        guard let token else { return false }
        
        // Validasyonlar
        guard !title.isEmpty, !price.isEmpty, !category.isEmpty, !stock.isEmpty else {
            errorMessage = "Lütfen tüm zorunlu alanları doldurun."
            showAlert = true
            return false
        }
        
        guard Int(stock) != nil else {
            errorMessage = "Stok adedi geçerli bir tam sayı olmalıdır."
            showAlert = true
            return false
        }
        
        guard (existingImages.count + newImagesData.count) > 0 else {
            errorMessage = "Ürüne ait en az bir görsel bulunmalıdır."
            showAlert = true
            return false
        }
        
        isLoading = true
        errorMessage = nil
        let formattedPrice = price.replacingOccurrences(of: ",", with: ".")
        
        // existingImages'ı JSON String'e çevir ("kept_images")
        var keptImagesJSON = "[]"
        if let jsonData = try? JSONEncoder().encode(existingImages),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            keptImagesJSON = jsonString
        }
        
        let fields = [
            "title": title,
            "description": description,
            "price": formattedPrice,
            "category": category,
            "stock": stock,
            "kept_images": keptImagesJSON
        ]
        
        do {
            // Multipart PUT isteği (newImagesData boş olsa bile çalışır)
            let updatedProduct: ProductResponse = try await NetworkManager.shared.uploadMultipartImages(
                url: "\(NetworkManager.baseURL)/api/v1/seller/products/\(product.id)",
                method: "PUT",
                fields: fields,
                filesData: newImagesData, // Dosya yoksa NetworkManager boş olarak bypass eder
                fileField: "images",
                mimeType: "image/jpeg",
                token: token
            )
            
            // Reaktif model güncellemesi
            self.product = updatedProduct
            self.errorMessage = "Ürün başarıyla güncellendi!"
            self.isUpdateSuccessful = true
            self.showAlert = true
            
            // Formu temizleyip son gelen data ile refresh yapıyoruz
            self.newSelectedItems.removeAll()
            self.newImagesData.removeAll()
            self.existingImages = updatedProduct.gallery.isEmpty ? [updatedProduct.image_path] : updatedProduct.gallery
            
            isLoading = false
            return true
            
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
            self.showAlert = true
        } catch {
            self.errorMessage = "Güncelleme sırasında beklenmeyen bir hata oluştu."
            self.showAlert = true
        }
        
        isLoading = false
        return false
    }
    
    // MARK: - Silme İşlemi (Mevcut korundu)
    @MainActor
    func deleteProduct(token: String?) async -> Bool {
        guard let token else { return false }
        isDeleting = true
        
        do {
            let _: String = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/products/\(product.id)",
                method: "DELETE",
                body: String?.none,
                token: token
            )
            isDeleting = false
            return true
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
            self.showAlert = true
        } catch {
            self.errorMessage = "Ürün silinirken bir hata oluştu."
            self.showAlert = true
        }
        
        isDeleting = false
        return false
    }
    
    // MARK: - EKLENDİ: AI Açıklama Üretimi
    @MainActor
    func generateAIDescription(token: String?) async {
        guard let token else { return }
        guard !title.isEmpty, !category.isEmpty else {
            errorMessage = "AI ile açıklama üretmek için ürün adı ve kategorisi zorunludur."
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
            self.errorMessage = error.localizedDescription
            self.showAlert = true
        } catch {
            self.errorMessage = "Yapay zeka servisine ulaşılamadı."
            self.showAlert = true
        }
        
        isGeneratingAI = false
    }
    
    // MARK: - Görsel Yardımcı Metodları
    
    private func loadTransferables(from items: [PhotosPickerItem]) async {
        var loadedData: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                loadedData.append(data)
            }
        }
        await MainActor.run { self.newImagesData = loadedData }
    }
    
    func removeExistingImage(at index: Int) {
        guard index < existingImages.count else { return }
        existingImages.remove(at: index)
    }
    
    func removeNewImage(at index: Int) {
        guard index < newImagesData.count, index < newSelectedItems.count else { return }
        newImagesData.remove(at: index)
        newSelectedItems.remove(at: index)
    }
}
