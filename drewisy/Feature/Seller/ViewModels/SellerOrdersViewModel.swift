//
//  SellerOrdersViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import Foundation

@Observable
final class SellerOrdersViewModel {
    var orders: [SellerOrderResponse] = []
    var isLoading = true
    var selectedFilter: String = "Tümü"
    var errorMessage: String?
    
    let filterOptions = ["Tümü", "Bekleyen", "Kargoda", "Tamamlanan", "İptal Edilenler"]
    
    var filteredOrders: [SellerOrderResponse] {
        if selectedFilter == "Tümü" { return orders }
        
        let statusMatch: String
        switch selectedFilter {
        case "Bekleyen": statusMatch = "pending"
        case "Kargoda": statusMatch = "shipped"
        case "Tamamlanan": statusMatch = "delivered"
        case "İptal Edilenler": statusMatch = "cancelled"
        default: statusMatch = ""
        }
        
        return orders.filter { $0.status == statusMatch }
    }
    
    @MainActor
    func loadOrders(token: String?) async {
        guard let token = token else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // GET isteğinde B: Encodable'ın çözülebilmesi için body: String?.none geçildi
            let fetchedOrders: [SellerOrderResponse] = try await NetworkManager.shared.request(
                url: NetworkManager.baseURL + "/api/v1/seller/orders",
                method: "GET",
                body: String?.none,
                token: token
            )
            self.orders = fetchedOrders
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateOrderStatus(orderId: String, newStatus: String, token: String?) async {
        guard let token = token else { return }
        
        let requestBody = UpdateOrderStatusRequest(status: newStatus)
        
        do {
            let _: String = try await NetworkManager.shared.request(
                url: NetworkManager.baseURL + "/api/v1/seller/orders/\(orderId)/status",
                method: "PATCH",
                body: requestBody,
                token: token
            )
            // Başarılıysa listeyi reaktif olarak güncelle
            await loadOrders(token: token)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
