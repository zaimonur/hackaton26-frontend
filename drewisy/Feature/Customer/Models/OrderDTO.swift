//
//  OrderDTO.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import Foundation

struct OrderItemRequest: Encodable {
    let product_id: String
    let quantity: Int
}

struct CreateOrderRequest: Encodable {
    let items: [OrderItemRequest]
}

struct OrderResponse: Decodable {
    let order_id: String
    let total_amount: Double
    let status: String
}

// AI Arama isteği için
struct SmartSearchRequest: Encodable {
    let query: String
}

// Backend'den sarmalanmış olarak gelen AI yanıtı
struct SmartSearchResponse: Decodable {
    let products: [ProductResponse]
}

struct CustomerOrderItem: Decodable, Hashable {
    let product_title: String
    let product_image: String
    let quantity: Int
    let unit_price: Double
}

struct CustomerOrderResponse: Decodable, Identifiable, Hashable {
    let id: String
    let total_amount: Double
    let status: String
    let created_at: String
    let items: [CustomerOrderItem]?
    
    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case total_amount
        case status
        case created_at
        case items
    }
}
