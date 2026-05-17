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

// MARK: - Güncellenen ProductResponse
struct ProductResponse: Decodable, Identifiable, Hashable, Equatable {
    let id: String
    let store_id: String
    let store_name: String
    let seller_id: String?
    let title: String
    let description: String
    let price: Double
    let category: String
    let image_path: String
    let gallery: [String]
    let stock: Int
    // Opsiyonel AI Rozeti
    let aiSentimentBadge: String?
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

struct AIDashboardSummaryResponse: Decodable {
    let summary: String
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
    let customer_id: String
    let customer_email: String
    let total_amount: Double
    let status: String
    let created_at: String
    let items: [SellerOrderItem]
    
    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case customer_id
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

// MARK: - Dashboard İstatistik Modelleri

struct CategoryStat: Decodable, Identifiable, Hashable {
    let category: String
    let sales_count: Int
    let revenue: Double
    
    var id: String { category }
}

struct ProductSalesStat: Decodable, Identifiable, Hashable {
    let product_id: String
    let title: String
    let image_path: String
    let category: String
    let sales_count: Int
    let revenue: Double
    
    var id: String { product_id }
}

struct SalesDashboardResponse: Decodable, Hashable {
    let total_revenue: Double
    let successful_orders: Int
    let average_order_value: Double
    let cancelled_orders: Int
    let cancelled_revenue: Double
    let category_sales: [CategoryStat]
    let product_sales: [ProductSalesStat]
}

struct UpdateProductRequest: Encodable {
    let price: Double
    let stock: Int
}

// MARK: - Tavsiye Response
struct AIRecommendationResponse: Decodable, Hashable, Equatable {
    let heroTitle: String
    let recommendedProducts: [ProductResponse]
    
    // JSON'dan gelen snake_case isimleri, Swift'in camelCase isimlerine bağlıyoruz.
    enum CodingKeys: String, CodingKey {
        case heroTitle = "hero_title"
        case recommendedProducts = "recommended_products"
    }
}

struct HistoryRequest: Encodable {
    let product_id: String
}
