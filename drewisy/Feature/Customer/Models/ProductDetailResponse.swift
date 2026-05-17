//
//  ProductDetailResponse.swift
//  drewisy
//
//  Created by Onur Zaim on 15.05.2026.
//

import Foundation

struct ProductDetailResponse: Decodable {
    let id: String
    let storeId: String
    let storeName: String
    let seller_id: String?
    let title: String
    let description: String
    let price: Double
    let stock: Int
    let category: String
    let imagePath: String
    let gallery: [String]
    let aiSummary: String
    let aiSentimentBadge: String
    let recentReviews: [ReviewResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case storeName = "store_name"
        case seller_id = "seller_id"
        case title
        case description
        case price
        case stock
        case category
        case imagePath = "image_path"
        case gallery
        case aiSummary = "ai_summary"
        case aiSentimentBadge = "ai_sentiment_badge"
        case recentReviews = "recent_reviews"
    }
}
