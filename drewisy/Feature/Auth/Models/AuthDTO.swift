//
//  AuthDTO.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import Foundation

struct User: Decodable, Identifiable {
    let id: String
    let email: String
    let role: String
}

struct AuthData: Decodable {
    let token: String
    let user: User
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

// Backend domain/user.go ile uyumlu yapı
struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let role: String
}
