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
