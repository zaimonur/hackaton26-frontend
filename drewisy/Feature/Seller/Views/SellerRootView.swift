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
                    // body parametresine String?.none vererek Generic B tipini derleyiciye tanıtıyoruz.
                    let _: [ProductResponse] = try await NetworkManager.shared.request(
                        url: "http://localhost:8080/api/v1/seller/products",
                        body: String?.none,
                        token: appState.token
                    )
                    hasStore = true
                } catch let error as APIError {
                    if case .serverError(let code, _) = error, code == 404 {
                        hasStore = false
                    } else {
                        hasStore = false
                    }
                } catch {
                    hasStore = false
                }
            }
        }
}
