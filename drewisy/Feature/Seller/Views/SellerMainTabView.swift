//
//  SellerMainTabView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct SellerMainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var notificationViewModel = NotificationViewModel()
    
    // Okunmamış bildirim sayısını hesaplayan reaktif özellik
    private var unreadNotificationCount: Int {
        notificationViewModel.notifications.filter { !$0.is_read }.count
    }
    
    var body: some View {
        TabView {
            SellerOrdersView()
                .tabItem { Label("Siparişler", systemImage: "shippingbox.fill") }

            PanelRootView()
                .tabItem { Label("Panel", systemImage: "square.grid.2x2.fill") }
                
            // GÜNCELLENDİ: Gerçek Asimetrik Mesajlaşma InboxView Bileşeni
            NavigationStack {
                InboxView()
            }
            .tabItem { Label("Mesajlar", systemImage: "message.fill") }
            
            // GÜNCELLENDİ: Gerçek Canlı Bildirim Listesi ve Dinamik Badge Yönetimi
            NotificationListView()
                .tabItem { Label("Bildirimler", systemImage: "bell.fill") }
                .badge(unreadNotificationCount > 0 ? unreadNotificationCount : 0)
                
            ProfileSettingsView()
                .tabItem { Label("Profil", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
        .task {
            // Tab açıldığında mevcut bildirimleri arka planda çekip badge'i doldurur
            await notificationViewModel.fetchNotifications(token: appState.token)
        }
        // WebSocket üzerinden gelen yeni bildirimleri yakalayıp badge sayısını anlık günceller
        .onChange(of: WebSocketManager.shared.incomingNotification) { _, incoming in
            if let newNotification = incoming {
                notificationViewModel.handleIncomingWSNotification(newNotification)
            }
        }
    }
}
