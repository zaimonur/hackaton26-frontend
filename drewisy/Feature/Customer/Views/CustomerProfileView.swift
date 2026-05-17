//
//  CustomerProfileView.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI

struct CustomerProfileView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: CustomerOrdersView()) {
                            Label("Siparişlerim / Kargo Takibi", systemImage: "shippingbox.fill")
                        }
                        
                        NavigationLink(destination: InboxView()) {
                            Label("Mesajlarım", systemImage: "tray.fill")
                        }
                    }
                    .listRowBackground(Theme.surface)
                    .foregroundColor(Theme.textPrimary)
                    
                    Section {
                        Button(role: .destructive) {
                            withAnimation { appState.logout() }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sistemden Çıkış Yap")
                                    .font(Theme.bodyFont.bold())
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Theme.surface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Hesabım")
        }
    }
}
