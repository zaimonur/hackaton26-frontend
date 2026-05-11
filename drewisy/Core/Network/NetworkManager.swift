//
//  NetworkManager.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import Foundation

// APIResponse'u en üste taşıyarak NetworkManager içinde görünür kılıyoruz
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: String?
    let code: Int
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case decodingError
    case serverError(code: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Geçersiz URL."
        case .decodingError: return "Veri işleme hatası."
        case .serverError(_, let msg): return msg
        }
    }
}

actor NetworkManager {
    static let shared = NetworkManager()
    
    // Hem dönen tip (T) hem gönderilen body tipi (B) için generic tanımlama
    func request<T: Decodable, B: Encodable>(url: String, method: String = "GET", body: B? = nil) async throws -> T {
        guard let urlObj = URL(string: url) else { throw APIError.invalidURL }
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            // APIResponse artık burada tanınacaktır
            let response = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            guard response.success, let responseData = response.data else {
                throw APIError.serverError(code: response.code, message: response.error ?? "Hata")
            }
            return responseData
        } catch {
            throw APIError.decodingError
        }
    }
}
