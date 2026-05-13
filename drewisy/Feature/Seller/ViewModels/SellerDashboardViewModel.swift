//
//  SellerDashboardViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Observation

@Observable
final class SellerDashboardViewModel {
    private var products: [ProductResponse] = []
    var isLoading = true
    
    // MARK: - Computed Properties (Client-Side İstatistikler)
    var totalProducts: Int {
        products.count
    }
    
    var totalCatalogValue: Double {
        products.reduce(0) { $0 + $1.price }
    }
    
    var latestProduct: String {
        products.first?.title ?? "Henüz ürün yok"
    }
    
    // MARK: - Network
    @MainActor
    func loadData(token: String?) async {
        guard let token else { return }
        isLoading = true
        do {
            // Sadece ürünleri çekip istatistikleri client tarafında hesaplıyoruz
            products = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/seller/products",
                body: String?.none,
                token: token
            )
        } catch {
            print("Dashboard istatistikleri çekilemedi: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
