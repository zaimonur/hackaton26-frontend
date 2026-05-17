//
//  CustomerOrdersViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI
import Observation

@Observable
final class CustomerOrdersViewModel {
    var orders: [CustomerOrderResponse] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    @MainActor
    func fetchOrders(token: String?) async {
        guard let token else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // Müşteri siparişlerini çeken endpoint
            orders = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/customer/orders",
                method: "GET",
                body: String?.none,
                token: token
            )
        } catch {
            errorMessage = "Siparişler yüklenemedi."
        }
        isLoading = false
    }
}
