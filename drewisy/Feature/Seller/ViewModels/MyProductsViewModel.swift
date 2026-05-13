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
    
    @MainActor
    func loadProducts(token: String?) async {
        guard let token else { return }
        isLoading = true
        do {
            products = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/seller/products",
                body: String?.none,
                token: token
            )
        } catch {
            print("Ürünler çekilemedi: \(error.localizedDescription)")
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
            // Başarılı olursa animasyonlu bir şekilde diziden çıkartıyoruz
            withAnimation {
                products.removeAll { $0.id == id }
            }
        } catch {
            print("Silme işlemi başarısız: \(error.localizedDescription)")
        }
    }
}
