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

struct ProductResponse: Decodable, Identifiable {
    let id: String
    let store_id: String
    let store_name: String
    let title: String
    let description: String
    let price: Double
    let category: String
    let image_path: String
}
