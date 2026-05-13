//
//  CustomerCatalogViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Observation

@Observable
final class CustomerCatalogViewModel {
    var products: [ProductResponse] = []
    var isLoading = true
    var errorMessage: String?
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            // Token nil gönderilerek herkese açık (public) API çağrısı yapılıyor.
            products = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/products",
                body: String?.none,
                token: nil
            )
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Ürünler yüklenemedi."
        }
        isLoading = false
    }
}
