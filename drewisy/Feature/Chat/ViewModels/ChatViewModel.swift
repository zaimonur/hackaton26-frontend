//
//  ChatViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI
import Observation

@Observable
final class ChatViewModel {
    var messages: [MessageDTO] = []
    var isLoading = false
    var isSending = false
    var errorMessage: String?
    var messageText: String = ""
    
    let targetId: String
    let targetName: String
    
    init(targetId: String, targetName: String) {
        self.targetId = targetId
        self.targetName = targetName
    }
    
    @MainActor
    func fetchHistory(token: String?) async {
        guard let token else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            messages = try await NetworkManager.shared.fetchChatHistory(targetId: targetId, token: token)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Sohbet geçmişi yüklenemedi."
        }
        
        isLoading = false
    }
    
    @MainActor
    func sendMessage(token: String?) async {
        let contentToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let token, !contentToSend.isEmpty else { return }
        
        isSending = true
        messageText = "" // UI Optimistic Clear
        
        do {
            let sentMessage = try await NetworkManager.shared.sendMessage(receiverId: targetId, content: contentToSend, token: token)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                messages.append(sentMessage)
            }
        } catch {
            errorMessage = "Mesaj gönderilemedi."
            messageText = contentToSend // Hata durumunda metni geri yükle
        }
        
        isSending = false
    }
    
    @MainActor
    func handleIncomingWSMessage(_ newMessage: MessageDTO) {
        // Sadece anlık konuştuğumuz kişiden (targetId) gelen mesajı bu ekrana yansıtıyoruz
        if newMessage.sender_id == targetId {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                messages.append(newMessage)
            }
        }
    }
}
