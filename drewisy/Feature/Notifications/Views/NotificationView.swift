//
//  NotificationView.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI

struct NotificationListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = NotificationViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else if viewModel.notifications.isEmpty {
                    ContentUnavailableView(
                        "Bildirim Yok",
                        systemImage: "bell.slash",
                        description: Text("Şu an için yeni bir bildiriminiz bulunmuyor.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRowView(notification: notification)
                            .contentShape(Rectangle()) // Tüm satırın tıklanabilir olmasını sağlar
                            .onTapGesture {
                                if !notification.is_read {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    Task { await viewModel.markAsRead(notificationId: notification.id, token: appState.token) }
                                }
                            }
                            .listRowBackground(Theme.surface)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if viewModel.notifications.isEmpty {
                    await viewModel.fetchNotifications(token: appState.token)
                }
            }
            .refreshable {
                await viewModel.fetchNotifications(token: appState.token)
            }
            // 🚀 KRİTİK NOKTA: WebSocket üzerinden gelen anlık bildirimleri dinliyoruz
            .onChange(of: WebSocketManager.shared.incomingNotification) { _, incoming in
                if let newNotification = incoming {
                    viewModel.handleIncomingWSNotification(newNotification)
                }
            }
        }
    }
}

// KISS Prensibi: Alt satır bileşeni (Row)
fileprivate struct NotificationRowView: View {
    let notification: NotificationDTO
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // HIG Standart Okunmamış Noktası
            Circle()
                .fill(notification.is_read ? Color.clear : Theme.primary)
                .frame(width: 10, height: 10)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.is_read ? Theme.textSecondary : Theme.textPrimary)
                
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
                
                Text(notification.created_at)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}
