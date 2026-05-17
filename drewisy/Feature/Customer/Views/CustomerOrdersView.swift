//
//  CustomerOrdersView.swift
//  drewisy
//
//  Created by Onur Zaim on 17.05.2026.
//

import SwiftUI

struct CustomerOrdersView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = CustomerOrdersViewModel()
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.orders.isEmpty {
                ProgressView().tint(Theme.primary)
            } else if viewModel.orders.isEmpty {
                ContentUnavailableView("Sipariş Yok", systemImage: "shippingbox", description: Text("Henüz bir sipariş vermediniz."))
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.orders) { order in
                            CustomerOrderCard(order: order)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.fetchOrders(token: appState.token)
                }
            }
        }
        .navigationTitle("Siparişlerim")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchOrders(token: appState.token)
        }
    }
}

// MARK: - Alt Bileşen: Sipariş Kartı
fileprivate struct CustomerOrderCard: View {
    let order: CustomerOrderResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(order.created_at.prefix(10)) // Sadece tarihi al
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                statusBadge(status: order.status)
            }
            
            Divider()
            
            // Eğer item detayları gelirse ilk ürünü göster, gelmezse genel bilgi bas
            if let firstItem = order.items?.first {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: NetworkManager.baseURL + firstItem.product_image)) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Theme.background
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstItem.product_title).font(Theme.bodyFont.bold()).lineLimit(1)
                        let moreCount = (order.items?.count ?? 1) - 1
                        if moreCount > 0 {
                            Text("+ \(moreCount) ürün daha").font(Theme.captionFont).foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("Sipariş #\(order.id.prefix(8).uppercased())")
                    .font(Theme.bodyFont.bold())
            }
            
            Divider()
            
            HStack {
                Text("Toplam Tutar")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text(String(format: "₺%.2f", order.total_amount))
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.primary)
            }
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func statusBadge(status: String) -> some View {
        let (text, color) = statusTuple(for: status)
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
    
    private func statusTuple(for status: String) -> (String, Color) {
        switch status.lowercased() {
        case "pending": return ("Sipariş Alındı", .orange)
        case "shipped": return ("Kargoda", .blue)
        case "delivered": return ("Teslim Edildi", .green)
        case "cancelled": return ("İptal Edildi", .red)
        default: return (status.capitalized, .gray)
        }
    }
}
