//
//  SellerOrderDetailView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct SellerOrderDetailView: View {
    @Environment(AppState.self) private var appState
    var viewModel: SellerOrdersViewModel
    let order: SellerOrderResponse
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header (Müşteri & Tarih)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Müşteri Bilgileri")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    Text(order.customer_email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Tarih: \(order.created_at)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.surface)
                .cornerRadius(12)
                
                // Ürünler Listesi
                Text("Ürünler")
                    .font(.headline)
                    .padding(.horizontal, 4)
                
                ForEach(order.items, id: \.self) { item in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: NetworkManager.baseURL + item.product_image)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Theme.surface // Yüklenirken surface rengi skeleton hissiyatı verir
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product_title)
                                .font(.subheadline).bold()
                                .lineLimit(2)
                            Text("\(item.quantity) Adet x ₺\(String(format: "%.2f", item.unit_price))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "₺%.2f", item.total_price))
                            .font(.subheadline).bold()
                            .foregroundColor(Theme.primary)
                    }
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(12)
                }
                
                actionButtonSection
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Sipariş Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Sadece gerekli olduğunda renderlanan buton modülü
    @ViewBuilder
    private var actionButtonSection: some View {
        if order.status == "pending" {
            Button(action: {
                Task { await viewModel.updateOrderStatus(orderId: order.id, newStatus: "shipped", token: appState.token) }
            }) {
                Text("Kargoya Ver")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .cornerRadius(12)
            }
            .padding(.top, 16)
        } else if order.status == "shipped" {
            Button(action: {
                Task { await viewModel.updateOrderStatus(orderId: order.id, newStatus: "delivered", token: appState.token) }
            }) {
                Text("Teslim Edildi İşaretle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.top, 16)
        }
    }
}
