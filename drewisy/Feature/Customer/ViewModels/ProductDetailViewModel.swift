//
//  ProductDetailViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import Foundation
import Observation

@Observable
final class ProductDetailViewModel {
    var isLoading = false
    var errorMessage: String?
    var reviewsSummary: ProductReviewsSummary?
    var isSubmittingReview = false
    
    // AI Özeti State'leri
    var aiSummary: String?
    var isFetchingAISummary = false
    
    @MainActor
    func fetchReviews(productId: String) async {
        isLoading = true
        errorMessage = nil
        
        let url = "\(NetworkManager.baseURL)/api/v1/products/\(productId)/reviews"
        
        do {
            let summary: ProductReviewsSummary = try await NetworkManager.shared.request(
                url: url,
                method: "GET",
                body: String?.none,
                token: nil
            )
            self.reviewsSummary = summary
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Değerlendirmeler yüklenemedi."
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchAISummary(productId: String) async {
        // Önceki özeti temizle ki butona her basıldığında temiz başlasın
        self.aiSummary = nil
        isFetchingAISummary = true
        
        let url = "\(NetworkManager.baseURL)/api/v1/products/\(productId)/reviews/ai-summary"
        
        do {
            let response: AISummaryResponse = try await NetworkManager.shared.request(
                url: url,
                method: "GET",
                body: String?.none,
                token: nil
            )
            // Yumuşak bir geçiş için küçük bir gecikme eklenebilir (Opsiyonel)
            self.aiSummary = response.summary
        } catch {
            print("AI Özeti çekilemedi: \(error.localizedDescription)")
        }
        
        isFetchingAISummary = false
    }
    
    @MainActor
    func submitReview(productId: String, rating: Int, comment: String, token: String?) async -> Bool {
        guard let token = token else {
            self.errorMessage = "Değerlendirme yapabilmek için oturum açmalısınız."
            return false
        }
        
        isSubmittingReview = true
        errorMessage = nil
        
        let url = "\(NetworkManager.baseURL)/api/v1/products/\(productId)/reviews"
        let requestBody = CreateReviewRequest(rating: rating, comment: comment)
        
        do {
            let _: String = try await NetworkManager.shared.request(
                url: url,
                method: "POST",
                body: requestBody,
                token: token
            )
            
            // Yorum başarıyla eklendikten sonra listeyi VE AI özetini yenile
            await fetchReviews(productId: productId)
            await fetchAISummary(productId: productId)
            
            isSubmittingReview = false
            return true
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
            isSubmittingReview = false
            return false
        } catch {
            self.errorMessage = "Değerlendirme gönderilirken beklenmeyen bir hata oluştu."
            isSubmittingReview = false
            return false
        }
    }
}
