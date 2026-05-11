//
//  AuthViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import Foundation
import Observation

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var role = "customer"
    var isLoading = false
    var errorMessage: String?
    
    var isAuthenticated = false
    var isRegisterMode = false
    var currentUser: User? // EKLENDİ: Yönlendirme için kullanıcıyı tutuyoruz
    
    private let baseURL = "http://localhost:8080/api/v1"
    
    @MainActor
    func authenticate() async {
        isLoading = true
        errorMessage = nil
        let path = isRegisterMode ? "/register" : "/login"
        
        do {
            if isRegisterMode {
                let req = RegisterRequest(email: email, password: password, role: role)
                let _: User = try await NetworkManager.shared.request(url: baseURL + path, method: "POST", body: req)
                isRegisterMode = false
                errorMessage = "Kayıt başarılı! Giriş yapabilirsiniz."
            } else {
                let req = LoginRequest(email: email, password: password)
                let authData: AuthData = try await NetworkManager.shared.request(url: baseURL + path, method: "POST", body: req)
                self.currentUser = authData.user // EKLENDİ: Rolü yakalıyoruz
                self.isAuthenticated = true
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Bağlantı hatası."
        }
        isLoading = false
    }
}
