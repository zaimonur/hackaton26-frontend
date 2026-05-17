//
//  InboxView.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI

struct InboxView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = InboxViewModel()
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.inboxItems.isEmpty {
                ProgressView().tint(Theme.primary)
            } else if viewModel.inboxItems.isEmpty {
                ContentUnavailableView(
                    "Mesaj Yok",
                    systemImage: "tray",
                    description: Text("Henüz kimseyle sohbet başlatmadınız.")
                )
            } else {
                List {
                    ForEach(viewModel.inboxItems) { item in
                        NavigationLink(destination: ChatView(targetId: item.target_id, targetName: item.target_name)) {
                            InboxRowView(item: item)
                        }
                        .listRowBackground(Theme.surface)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Mesajlarım")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchInbox(token: appState.token)
        }
    }
}

fileprivate struct InboxRowView: View {
    let item: InboxItemResponse
    
    var body: some View {
        HStack(spacing: 16) {
            // HIG Standart Avatar Placeholder
            Circle()
                .fill(Theme.primary.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(item.target_name.prefix(1).uppercased()))
                        .font(Theme.titleFont)
                        .foregroundColor(Theme.primary)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.target_name)
                        .font(Theme.bodyFont.bold())
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text(item.created_at)
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textSecondary)
                }
                Text(item.last_message)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
