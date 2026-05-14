//
//  SellerOrderView.swift
//  drewisy
//
//  Created by Onur Zaim on 14.05.2026.
//

import SwiftUI

struct SellerOrdersView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SellerOrdersViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filtre", selection: $viewModel.selectedFilter) {
                    ForEach(viewModel.filterOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Theme.background)
                
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredOrders) { order in
                            NavigationLink(value: order) {
                                OrderRowView(order: order)
                            }
                            .listRowBackground(Theme.surface)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                    .refreshable {
                        await viewModel.loadOrders(token: appState.token)
                    }
                }
            }
            .navigationTitle("Siparişler")
            .navigationDestination(for: SellerOrderResponse.self) { order in
                SellerOrderDetailView(viewModel: viewModel, order: order)
            }
            .task {
                if viewModel.orders.isEmpty {
                    await viewModel.loadOrders(token: appState.token)
                }
            }
        }
    }
}

// KISS Prensibi: Row görünümü alt bileşen olarak ayrıştırıldı.
fileprivate struct OrderRowView: View {
    let order: SellerOrderResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Sipariş #\(order.id.prefix(8))")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(order.status.uppercased())
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.status).opacity(0.2))
                    .foregroundColor(statusColor(for: order.status))
                    .cornerRadius(8)
            }
            
            Text(order.customer_email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(order.items.count) Ürün")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "₺%.2f", order.total_amount))
                    .font(.subheadline).bold()
                    .foregroundColor(Theme.primary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "pending": return .orange
        case "shipped": return .blue
        case "delivered": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}
