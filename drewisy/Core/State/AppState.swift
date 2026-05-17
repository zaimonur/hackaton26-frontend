//
//  AppState.swift
//  drewisy
//
//  Created by Onur Zaim on 12.05.2026.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class AppState {
    var isAuthenticated: Bool
    var userRole: String?
    var token: String?

    init() {
        let savedToken = UserDefaults.standard.string(forKey: "jwt_token")
        let savedRole = UserDefaults.standard.string(forKey: "user_role")
        
        self.token = savedToken
        self.userRole = savedRole
        self.isAuthenticated = (savedToken != nil)
        
        // Uygulama ilk açıldığında aktif bir oturum varsa WebSocket'e bağlan
        if let validToken = savedToken {
            WebSocketManager.shared.connect(token: validToken)
        }
    }

    func login(token: String, role: String) {
        UserDefaults.standard.set(token, forKey: "jwt_token")
        UserDefaults.standard.set(role, forKey: "user_role")
        self.token = token
        self.userRole = role
        self.isAuthenticated = true
        
        // Başarılı giriş sonrası WebSocket'i başlat
        WebSocketManager.shared.connect(token: token)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "jwt_token")
        UserDefaults.standard.removeObject(forKey: "user_role")
        self.token = nil
        self.userRole = nil
        self.isAuthenticated = false
        
        // Oturum kapandığında WebSocket bağlantısını kopar
        WebSocketManager.shared.disconnect()
    }
}
