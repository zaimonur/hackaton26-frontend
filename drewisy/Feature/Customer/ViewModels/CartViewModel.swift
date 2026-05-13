//
//  CartViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Observation

@Observable
final class CartViewModel {
    var isSubmitting = false
    var showAlert = false
    var alertMessage = ""
    
    @MainActor
    func checkout(cartItems: [ProductResponse: Int], token: String?) async -> Bool {
        // MVP: Token kontrolü
        guard let token = token, !token.isEmpty else {
            alertMessage = "Sipariş vermek için oturum açmalısınız."
            showAlert = true
            return false
        }
        
        isSubmitting = true
        // İşlem sonunda her halükarda isSubmitting'i false yapar
        defer { isSubmitting = false }
        
        // Dictionary'i API'nin beklediği DTO dizisine mapliyoruz
        let items = cartItems.map { OrderItemRequest(product_id: $0.key.id, quantity: $0.value) }
        let requestBody = CreateOrderRequest(items: items)
        
        do {
            let _: OrderResponse = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/orders",
                method: "POST",
                body: requestBody,
                token: token
            )
            return true
        } catch let error as APIError {
            alertMessage = error.localizedDescription
            showAlert = true
            return false
        } catch {
            alertMessage = "Sipariş oluşturulurken beklenmeyen bir hata oluştu."
            showAlert = true
            return false
        }
    }
}
