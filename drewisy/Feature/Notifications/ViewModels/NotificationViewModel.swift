//
//  NotificationViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI
import Observation

@Observable
final class NotificationViewModel {
    var notifications: [NotificationDTO] = []
    var isLoading = false
    var errorMessage: String?
    
    @MainActor
    func fetchNotifications(token: String?) async {
        guard let token else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            notifications = try await NetworkManager.shared.fetchNotifications(token: token)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Bildirimler yüklenemedi."
        }
        
        isLoading = false
    }
    
    @MainActor
    func markAsRead(notificationId: String, token: String?) async {
        guard let token else { return }
        
        // Optimistic UI Güncellemesi (Hızlı ve akıcı hissettirmesi için önce arayüzü güncelliyoruz)
        guard let index = notifications.firstIndex(where: { $0.id == notificationId }) else { return }
        
        let current = notifications[index]
        notifications[index] = NotificationDTO(
            id: current.id, type: current.type, reference_id: current.reference_id,
            title: current.title, body: current.body, is_read: true, created_at: current.created_at
        )
        
        do {
            _ = try await NetworkManager.shared.markNotificationAsRead(id: notificationId, token: token)
        } catch {
            // Hata olursa UI'ı eski haline (okunmamış) geri al
            notifications[index] = current
        }
    }
    
    // WebSocket'ten gelen yeni bildirimi listeye anlık eklemek için
    @MainActor
    func handleIncomingWSNotification(_ newNotification: NotificationDTO) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            notifications.insert(newNotification, at: 0)
        }
    }
}
