//
//  AuthView.swift
//  drewisy
//
//  Created by Onur Zaim on 10.05.2026.
//

// Feature/Auth/Views/AuthView.swift
import SwiftUI

struct AuthView: View {
    @State private var viewModel = AuthViewModel()
    @Environment(AppState.self) private var appState
    
    var body: some View {
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
                            Text("Satıcı").tag("seller")
                            Text("Admin").tag("admin")
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
                    Task {
                        // Sadece başarılı olursa AppState'i tetikle ve ekranı değiştir
                        if let authData = await viewModel.authenticate() {
                            appState.login(token: authData.token, role: authData.user.role)
                        }
                    }
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
