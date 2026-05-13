//
//  CustomerCatalogViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Observation

@Observable
final class CustomerCatalogViewModel {
    var products: [ProductResponse] = []
    var isLoading = false
    var errorMessage: String?
    
    // Arama State'leri
    var searchText = ""
    var isAIEnabled = false
    
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            products = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/products",
                body: String?.none,
                token: nil
            )
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Ürünler yüklenemedi."
        }
        isLoading = false
    }
    
    @MainActor
    func searchProducts() async {
        // Metin boşsa ana kataloğa dön (Empty State Yönetimi)
        guard !searchText.isEmpty else {
            await loadProducts()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isAIEnabled {
                // AI Destekli Arama (POST)
                let req = SmartSearchRequest(query: searchText)
                let response: SmartSearchResponse = try await NetworkManager.shared.request(
                    url: "\(NetworkManager.baseURL)/api/v1/ai/search",
                    method: "POST",
                    body: req,
                    token: nil
                )
                products = response.products
            } else {
                // Standart Arama (GET - URL Safe)
                var components = URLComponents(string: "\(NetworkManager.baseURL)/api/v1/products")
                components?.queryItems = [URLQueryItem(name: "q", value: searchText)]
                
                guard let urlString = components?.url?.absoluteString else { return }
                
                products = try await NetworkManager.shared.request(
                    url: urlString,
                    body: String?.none,
                    token: nil
                )
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            products = [] // Hata durumunda listeyi temizle
        } catch {
            errorMessage = "Arama sırasında bir hata oluştu."
        }
        isLoading = false
    }
}
