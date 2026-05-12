//
//  AuthViewModel.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

// Feature/Auth/ViewModels/AuthViewModel.swift
import Foundation
import Observation

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var role = "staff"
    var isLoading = false
    var errorMessage: String?
    var isRegisterMode = false
    
    private let baseURL = "http://localhost:8080/api/v1"
    
    @MainActor
    func authenticate() async -> AuthData? {
        isLoading = true
        errorMessage = nil
        let path = isRegisterMode ? "/register" : "/login"
        var resultData: AuthData? = nil
        
        do {
            if isRegisterMode {
                let req = RegisterRequest(email: email, password: password, role: role)
                let _: User = try await NetworkManager.shared.request(url: baseURL + path, method: "POST", body: req)
                isRegisterMode = false
                errorMessage = "Kayıt başarılı! Giriş yapabilirsiniz."
            } else {
                let req = LoginRequest(email: email, password: password)
                resultData = try await NetworkManager.shared.request(url: baseURL + path, method: "POST", body: req)
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Bağlantı hatası."
        }
        isLoading = false
        return resultData
    }
}
