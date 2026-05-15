//
//  SellerProductDetailViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import Foundation
import Observation

@Observable
final class SellerProductDetailViewModel {
    var product: ProductResponse
    var isLoading = false
    var errorMessage: String? = nil
    
    var newPrice: String
    var newStock: Int
    
    init(product: ProductResponse) {
        self.product = product
        self.newPrice = String(format: "%.2f", product.price)
        self.newStock = product.stock
    }
    
    @MainActor
    func updateProduct(token: String?) async {
        guard let token = token else { return }
        
        let formattedPrice = newPrice.replacingOccurrences(of: ",", with: ".")
        guard let priceDouble = Double(formattedPrice) else {
            self.errorMessage = "Geçersiz fiyat formatı."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let requestBody = UpdateProductRequest(price: priceDouble, stock: newStock)
        let url = "\(NetworkManager.baseURL)/api/v1/seller/products/\(product.id)"
        
        do {
            let updatedProduct: ProductResponse = try await NetworkManager.shared.request(
                url: url,
                method: "PATCH",
                body: requestBody,
                token: token
            )
            self.product = updatedProduct
            
            self.newPrice = String(format: "%.2f", updatedProduct.price)
            self.newStock = updatedProduct.stock
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ürün güncellenirken bir hata oluştu."
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteProduct(token: String?) async -> Bool {
        guard let token = token else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let url = "\(NetworkManager.baseURL)/api/v1/products/\(product.id)"
        
        do {
            let _: String = try await NetworkManager.shared.request(
                url: url,
                method: "DELETE",
                body: String?.none,
                token: token
            )
            isLoading = false
            return true
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ürün silinirken bir hata oluştu."
        }
        
        isLoading = false
        return false
    }
}
