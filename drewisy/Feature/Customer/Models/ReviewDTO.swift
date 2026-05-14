//
//  ReviewDTO.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import Foundation

struct ReviewResponse: Decodable, Identifiable {
    let id: String
    let rating: Int
    let comment: String
    let created_at: String
    let user_email: String
}

struct ProductReviewsSummary: Decodable {
    let average_rating: Double
    let total_reviews: Int
    let reviews: [ReviewResponse]
}

struct CreateReviewRequest: Encodable {
    let rating: Int
    let comment: String
}

struct AISummaryResponse: Decodable {
    let summary: String
}
