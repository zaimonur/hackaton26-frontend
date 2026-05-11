//
//  AuthView.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

import SwiftUI

struct AuthView: View {
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.primary)
                        Text(viewModel.isRegisterMode ? "Yeni Hesap" : "Hoş Geldiniz")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.textPrimary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 12) {
                        customTextField(placeholder: "E-posta", text: $viewModel.email, icon: "envelope")
                        customSecureField(placeholder: "Şifre", text: $viewModel.password, icon: "lock")
                        
                        if viewModel.isRegisterMode {
                            Picker("Rol", selection: $viewModel.role) {
                                Text("Müşteri").tag("customer")
                                // UI'da Satıcı görünüyor, DB 'admin' kısıtlamasına takılmamak için tag 'admin' kalıyor
                                Text("Satıcı").tag("admin")
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 8)
                        }
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(Theme.captionFont)
                            .foregroundColor(error.contains("başarılı") ? .green : .red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task { await viewModel.authenticate() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(viewModel.isRegisterMode ? "Kayıt Ol" : "Giriş Yap").font(Theme.bodyFont.bold())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.inputHeight)
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.cornerRadius)
                    
                    Button {
                        withAnimation { viewModel.isRegisterMode.toggle() }
                    } label: {
                        Text(viewModel.isRegisterMode ? "Zaten hesabım var" : "Yeni hesap oluştur")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(Theme.spacing)
            }
            // ROL BAZLI YÖNLENDİRME (RBAC) BURADA YAPILIYOR
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                Group {
                    if viewModel.currentUser?.role == "admin" {
                        AdminDashboardView()
                    } else {
                        CustomerCatalogView()
                    }
                }
                .navigationBarBackButtonHidden(true) // Geri dönmeyi engelle
            }
        }
    }
    
    func customTextField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(Theme.textSecondary)
            TextField(placeholder, text: text)
                .foregroundColor(Theme.textPrimary)
                .autocapitalization(.none)
        }
        .padding()
        .frame(height: Theme.inputHeight)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth))
    }

    func customSecureField(placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(Theme.textSecondary)
            SecureField(placeholder, text: text)
                .foregroundColor(Theme.textPrimary)
        }
        .padding()
        .frame(height: Theme.inputHeight)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth))
    }
}
