//
//  ProfileSettingsView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.primary)
                    .padding(.top, 40)
                
                Text("Role: \(appState.userRole?.uppercased() ?? "")")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Button {
                    withAnimation { appState.logout() }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sistemden Çıkış Yap")
                    }
                    .font(Theme.bodyFont.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.inputHeight)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(Theme.cornerRadius)
                }
                .padding(Theme.spacing)
                .padding(.bottom, 20)
            }
        }
    }
}
