//
//  SellerDTO.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import Foundation

struct StoreResponse: Decodable {
    let id: String
    let name: String
    let description: String
}

struct CreateStoreRequest: Encodable {
    let name: String
    let description: String
}

struct ProductResponse: Decodable, Identifiable, Hashable, Equatable {
    let id: String
    let store_id: String
    let store_name: String
    let title: String
    let description: String
    let price: Double
    let category: String
    let image_path: String
}

// AI Entegrasyon Modelleri
struct GenerateDescriptionRequest: Encodable {
    let title: String
    let category: String
    let keywords: String
}

struct GenerateDescriptionResponse: Decodable {
    let generated_description: String
}

struct SellerOrderItem: Decodable, Hashable {
    let product_title: String
    let product_image: String
    let quantity: Int
    let unit_price: Double
    let total_price: Double
}

struct SellerOrderResponse: Decodable, Identifiable, Hashable {
    let id: String
    let customer_email: String
    let total_amount: Double
    let status: String
    let created_at: String
    let items: [SellerOrderItem]
    
    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case customer_email
        case total_amount
        case status
        case created_at
        case items
    }
}

struct UpdateOrderStatusRequest: Encodable {
    let status: String
}
