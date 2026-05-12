//
//  AddProductViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 12.05.2026.
//

import SwiftUI
import PhotosUI
import Observation

struct DummyProductResponse: Decodable { let id: String }

@Observable
final class AddProductViewModel {
    var title = ""
    var description = ""
    var price = ""
    var category = ""
    
    var selectedItem: PhotosPickerItem? = nil {
        didSet { Task { await loadTransferable(from: selectedItem) } }
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
        let fields = ["title": title, "description": description, "price": price, "category": category]
        
        do {
            let _: DummyProductResponse = try await NetworkManager.shared.uploadMultipart(
                url: "http://localhost:8080/api/v1/products",
                fields: fields,
                fileData: fileData,
                fileName: "product.png",
                mimeType: "image/png",
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
    
    private func loadTransferable(from item: PhotosPickerItem?) async {
        guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
        await MainActor.run { self.selectedImageData = data }
    }
    
    private func clearForm() {
        title = ""; description = ""; price = ""; category = ""; selectedItem = nil; selectedImageData = nil
    }
}
