//
//  InboxViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI
import Observation

@Observable
final class InboxViewModel {
    var inboxItems: [InboxItemResponse] = []
    var isLoading = false
    var errorMessage: String?
    
    @MainActor
    func fetchInbox(token: String?) async {
        guard let token else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            inboxItems = try await NetworkManager.shared.fetchInbox(token: token)
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Gelen kutusu yüklenemedi."
        }
        
        isLoading = false
    }
}
