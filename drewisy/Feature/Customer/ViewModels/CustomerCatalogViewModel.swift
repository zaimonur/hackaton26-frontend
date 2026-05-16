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
    // MARK: - State Properties
    var products: [ProductResponse] = []
    
    // YENİ: Anasayfa Koleksiyonları
    var bestsellers: [ProductResponse] = []
    var categories: [String] = []
    var history: [ProductResponse] = []
    var aiRecommendation: AIRecommendationResponse? = nil
    
    var isLoading = false
    var errorMessage: String?
    
    // Arama State'leri
    var searchText = ""
    var isAIEnabled = false
    
    // Debouncing için referans task
    private var searchTask: Task<Void, Never>?
    
    // MARK: - API Calls (Paralel Yükleme)
    
    @MainActor
        func fetchHomePageData(token: String?) async {
            isLoading = true
            // Alert fırlatmasını tamamen engellemek için errorMessage'ı set etmiyoruz.
            
            // 1. Kategoriler (Fail-Safe)
            do {
                categories = try await NetworkManager.shared.request(url: "\(NetworkManager.baseURL)/api/v1/categories", body: String?.none, token: nil)
            } catch { print("Kategori çekilemedi: \(error)") }
            
            // 2. Çok Satanlar (Fail-Safe)
            do {
                bestsellers = try await NetworkManager.shared.request(url: "\(NetworkManager.baseURL)/api/v1/products/bestsellers", body: String?.none, token: nil)
            } catch { print("Bestsellers çekilemedi: \(error)") }
            
            // Auth Gerektirenler
            if let token = token {
                // 3. Geçmiş (Fail-Safe)
                do {
                    history = try await NetworkManager.shared.request(url: "\(NetworkManager.baseURL)/api/v1/users/history", body: String?.none, token: token)
                } catch { print("History çekilemedi: \(error)") }
                
                // 4. AI Vitrini (Fail-Safe - Patlarsa sayfayı bozmaz, sadece banner çıkmaz)
                do {
                    aiRecommendation = try await NetworkManager.shared.request(url: "\(NetworkManager.baseURL)/api/v1/ai/recommendations", body: String?.none, token: token)
                } catch {
                    print("🤖 AI Recommendation patladı, sessizce yutuldu: \(error)")
                    aiRecommendation = nil
                }
            }
            
            isLoading = false
        }
    
    @MainActor
    func loadProducts() async {
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
    }
    
    // MARK: - Arama (Debounced)
    
    @MainActor
    func searchWithDebounce() {
        // Eski aramayı iptal et
        searchTask?.cancel()
        
        guard !searchText.isEmpty else {
            Task { await loadProducts() }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        searchTask = Task {
            do {
                // 500ms Debounce beklemesi (Cancellation tetiklenebilir)
                try await Task.sleep(nanoseconds: 500_000_000)
                
                // Task iptal edildiyse işlemi kes
                guard !Task.isCancelled else { return }
                
                await executeSearch()
                
            } catch {
                // Task.sleep iptal edildiğinde fırlatılan hatayı yut
            }
        }
    }
    
    @MainActor
    private func executeSearch() async {
        do {
            if isAIEnabled {
                let req = SmartSearchRequest(query: searchText)
                let response: SmartSearchResponse = try await NetworkManager.shared.request(
                    url: "\(NetworkManager.baseURL)/api/v1/ai/search",
                    method: "POST",
                    body: req,
                    token: nil
                )
                products = response.products
            } else {
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
            products = []
        } catch {
            errorMessage = "Arama sırasında hata oluştu."
            products = []
        }
        isLoading = false
    }
    
    // MARK: - Geçmiş (History) Kaydı
    
    @MainActor
    func recordHistory(productId: String, token: String?) async {
        guard let token = token else { return }
        
        let requestBody = HistoryRequest(product_id: productId)
        do {
            // Sadece backend'e kayıt atıyoruz, response body önemli değil (örneğin başarı için String dönebilir)
            let _: String? = try await NetworkManager.shared.request(
                url: "\(NetworkManager.baseURL)/api/v1/users/history",
                method: "POST",
                body: requestBody,
                token: token
            )
        } catch {
            // Silently fail: Arayüz akışını bölmemek için geçmiş ekleme hatalarını kullanıcıya yansıtmıyoruz.
            print("History record error: \(error.localizedDescription)")
        }
    }
}
