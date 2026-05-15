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
    var productDetail: ProductDetailResponse?
    var isLoading = false
    var errorMessage: String?
    var isSubmittingReview = false
    
    // MARK: - AI Assistant States
    var chatMessages: [ChatMessage] = []
    var isAskingQuestion = false
    
    @MainActor
    func fetchProductDetail(productId: String) async {
        isLoading = true
        errorMessage = nil
        
        let url = "\(NetworkManager.baseURL)/api/v1/products/\(productId)"
        
        do {
            let response: ProductDetailResponse = try await NetworkManager.shared.request(
                url: url,
                method: "GET",
                body: String?.none,
                token: nil
            )
            self.productDetail = response
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ürün detayları yüklenemedi."
        }
        
        isLoading = false
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
            
            await fetchProductDetail(productId: productId)
            
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
    
    @MainActor
    func askQuestion(productId: String, question: String) async {
        let userMsg = ChatMessage(text: question, isUser: true)
        chatMessages.append(userMsg)
        
        isAskingQuestion = true
        let url = "\(NetworkManager.baseURL)/api/v1/products/\(productId)/ask"
        let requestBody = ProductAskRequest(question: question)
        
        do {
            let response: ProductAskResponse = try await NetworkManager.shared.request(
                url: url,
                method: "POST",
                body: requestBody,
                token: nil
            )
            
            let aiMsg = ChatMessage(text: response.answer, isUser: false)
            self.chatMessages.append(aiMsg)
            
        } catch {
            let errorMsg = ChatMessage(text: "Üzgünüm, şu an bağlantı kuramıyorum. Lütfen tekrar dene.", isUser: false)
            self.chatMessages.append(errorMsg)
        }
        
        isAskingQuestion = false
    }
}
