//
//  SellerRootView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct SellerRootView: View {
    @Environment(AppState.self) private var appState
    @State private var hasStore: Bool? = nil // nil: Loading, false: Mağaza Yok, true: Mağaza Var
    
    var body: some View {
        Group {
            if let exists = hasStore {
                if exists {
                    SellerMainTabView()
                } else {
                    CreateStoreView(onSuccess: { checkStoreStatus() })
                }
            } else {
                ProgressView("Kontrol ediliyor...")
                    .tint(Theme.primary)
            }
        }
        .task { checkStoreStatus() }
    }
    
    private func checkStoreStatus() {
        Task {
            do {
                let _: [ProductResponse] = try await NetworkManager.shared.request(
                    url: "\(NetworkManager.baseURL)/api/v1/seller/products",
                    method: "GET",
                    body: String?.none,
                    token: appState.token
                )
                hasStore = true
            } catch let error as APIError {
                print("Store Check API Error: \(error.localizedDescription)")
                if case .serverError(let code, _) = error, code == 404 {
                    hasStore = false
                } else {
                    hasStore = false
                }
            } catch {
                print("Store Check General Error: \(error.localizedDescription)")
                hasStore = false
            }
        }
    }
}
