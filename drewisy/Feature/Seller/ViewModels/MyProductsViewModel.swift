//
//  MyProductsViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Observation

@Observable
final class MyProductsViewModel {
    var products: [ProductResponse] = []
    var isLoading = true
    var errorMessage: String? = nil
    
    // MARK: - Category Filtering State
    
    var selectedCategory: String = "Tümü"
    
    var uniqueCategories: [String] {
        // Set ile tekrarları engelle, alfabetik sırala ve başa "Tümü" ekle
        let categories = Array(Set(products.map { $0.category })).sorted()
        return ["Tümü"] + categories
    }
    
    var filteredProducts: [ProductResponse] {
        if selectedCategory == "Tümü" { return products }
        return products.filter { $0.category == selectedCategory }
    }
    
    // MARK: - API Calls
    
    @MainActor
    func loadProducts(token: String?) async {
        guard let token else { return }
        isLoading = true
        errorMessage = nil
        do {
            products = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/seller/products",
                body: String?.none,
                token: token
            )
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Ürünler çekilemedi."
        }
        isLoading = false
    }
    
    @MainActor
    func deleteProduct(id: String, token: String?) async {
        guard let token else { return }
        do {
            let _: String = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/products/\(id)",
                method: "DELETE",
                body: String?.none,
                token: token
            )
            withAnimation {
                products.removeAll { $0.id == id }
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Silme işlemi başarısız."
        }
    }
    
    // MARK: - Inline Update
    
    @MainActor
    func updateProductInline(id: String, newPrice: Double?, newStock: Int?, token: String?) async -> Bool {
        guard let token, let index = products.firstIndex(where: { $0.id == id }) else { return false }
        
        let currentProduct = products[index]
        
        // Gelen değer nil ise mevcut ürünün değerini kullan (Fallback)
        let updatedPrice = newPrice ?? currentProduct.price
        let updatedStock = newStock ?? currentProduct.stock
        
        let requestBody = UpdateProductRequest(price: updatedPrice, stock: updatedStock)
        let url = "\(NetworkManager.baseURL)/api/v1/seller/products/\(id)"
        
        do {
            let updatedProduct: ProductResponse = try await NetworkManager.shared.request(
                url: url,
                method: "PATCH",
                body: requestBody,
                token: token
            )
            
            // Başarılıysa anlık UI reaktivitesi için dizideki modeli doğrudan değiştir
            withAnimation {
                products[index] = updatedProduct
            }
            return true
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = "Güncelleme başarısız."
            return false
        }
    }
}
