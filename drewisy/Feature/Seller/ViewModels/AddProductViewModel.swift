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
    
    var selectedItem: PhotosPickerItem? = nil {
        didSet {
            Task { await loadTransferable(from: selectedItem) }
        }
    }
    var selectedImageData: Data? = nil
    
    var isLoading = false
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
        
        // YENİ: Virgülü noktaya çevirerek Backend'in (Go) ParseFloat fonksiyonunu kurtarıyoruz.
        let formattedPrice = price.replacingOccurrences(of: ",", with: ".")
        let fields = ["title": title, "description": description, "price": formattedPrice, "category": category]
        
        do {
            let _: DummyProductResponse = try await NetworkManager.shared.uploadMultipart(
                url: "http://localhost:8080/api/v1/products", // Go backend endpoint'imiz
                fields: fields,
                fileData: fileData,
                fileName: "product.jpg", // Daha genel destek için jpg
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
    
    // YENİ: Data çevirisi hatalarına (HEIC/iCloud gecikmesi vb.) karşı daha güvenli ve hata yönetimli yapı
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
            // Çeviri başarısız olursa UI'ın takılı kalmaması için uyarı ver
            await MainActor.run {
                self.selectedImageData = nil
                self.alertMessage = "Görsel formatı okunamadı (Örn: Desteklenmeyen HEIC/iCloud hatası). Lütfen farklı bir görsel seçin."
                self.showAlert = true
            }
        }
    }
    
    private func clearForm() {
        title = ""
        description = ""
        price = ""
        category = ""
        selectedItem = nil
        selectedImageData = nil
    }
}
