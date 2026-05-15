//
//  NetworkManager.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import Foundation

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
    static let baseURL = "http://localhost:8080"
    
    func request<T: Decodable, B: Encodable>(
        url: String,
        method: String = "GET",
        body: B? = nil,
        token: String? = nil
    ) async throws -> T {
        guard let urlObj = URL(string: url) else { throw APIError.invalidURL }
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Token varsa Header'a enjekte et
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        // HTTP Statüsünü kontrol et
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode(APIResponse<T>.self, from: data))?.error
            throw APIError.serverError(code: httpResponse.statusCode, message: errorMsg ?? "Sunucu Hatası")
        }
        
        do {
            let responseObj = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            guard responseObj.success, let responseData = responseObj.data else {
                throw APIError.serverError(code: responseObj.code, message: responseObj.error ?? "İşlem başarısız")
            }
            return responseData
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - Tekil Dosya Yükleme (Legacy)
    func uploadMultipart<T: Decodable>(url: String, method: String = "POST", fields: [String: String], fileData: Data, fileName: String, mimeType: String, token: String?) async throws -> T {
        guard let urlObj = URL(string: url) else { throw APIError.invalidURL }
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        
        let boundary = UUID().uuidString
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in fields {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode(APIResponse<T>.self, from: data))?.error
            throw APIError.serverError(code: httpResponse.statusCode, message: errorMsg ?? "Sunucu Hatası")
        }
        
        do {
            let response = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            guard response.success, let responseData = response.data else {
                throw APIError.serverError(code: response.code, message: response.error ?? "Yükleme Hatası")
            }
            return responseData
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - Çoklu Dosya Yükleme (Envanter 2.0 / Premium Studio)
    func uploadMultipartImages<T: Decodable>(url: String, method: String = "POST", fields: [String: String], filesData: [Data], fileField: String = "images", mimeType: String = "image/jpeg", token: String?) async throws -> T {
        guard let urlObj = URL(string: url) else { throw APIError.invalidURL }
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        
        let boundary = UUID().uuidString
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        // Form Text Alanları
        for (key, value) in fields {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Çoklu Dosya Alanları
        for (index, fileData) in filesData.enumerated() {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fileField)\"; filename=\"image_\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = (try? JSONDecoder().decode(APIResponse<T>.self, from: data))?.error
            throw APIError.serverError(code: httpResponse.statusCode, message: errorMsg ?? "Sunucu Hatası")
        }
        
        do {
            let responseObj = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            guard responseObj.success, let responseData = responseObj.data else {
                throw APIError.serverError(code: responseObj.code, message: responseObj.error ?? "İşlem başarısız")
            }
            return responseData
        } catch {
            throw APIError.decodingError
        }
    }
}
