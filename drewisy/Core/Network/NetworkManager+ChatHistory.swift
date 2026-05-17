//
//  NetworkManager+ChatHistory.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import Foundation

extension NetworkManager {
    func fetchChatHistory(targetId: String, token: String?) async throws -> [MessageDTO] {
        return try await request(
            url: "\(NetworkManager.baseURL)/api/v1/messages/history/\(targetId)",
            method: "GET",
            body: String?.none,
            token: token
        )
    }
}
