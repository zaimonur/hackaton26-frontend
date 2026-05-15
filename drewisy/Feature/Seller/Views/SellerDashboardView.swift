//
//  SellerDashboardView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Charts

enum MetricType {
    case revenue
    case count
}

struct SellerDashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SellerDashboardViewModel()
    @State private var selectedMetric: MetricType = .revenue
    
    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacing),
        GridItem(.flexible(), spacing: Theme.spacing)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Zaman Filtresi
                    Picker("Zaman Aralığı", selection: $viewModel.period) {
                        Text("Günlük").tag("daily")
                        Text("Haftalık").tag("weekly")
                        Text("Aylık").tag("monthly")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.spacing)
                    .onChange(of: viewModel.period) {
                        Task { await viewModel.loadData(token: appState.token) }
                    }
                    
                    if viewModel.isLoading && viewModel.dashboardData == nil {
                        ProgressView()
                            .tint(Theme.primary)
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else if let data = viewModel.dashboardData {
                        
                        // MARK: - KPI Kartları
                        LazyVGrid(columns: columns, spacing: Theme.spacing) {
                            KPICard(
                                title: "Toplam Ciro",
                                value: String(format: "%.2f ₺", data.total_revenue),
                                icon: "turkishlirasign.circle.fill",
                                iconColor: .green
                            )
                            
                            KPICard(
                                title: "Başarılı Sipariş",
                                value: "\(data.successful_orders)",
                                icon: "checkmark.circle.fill",
                                iconColor: Theme.primary
                            )
                            
                            KPICard(
                                title: "Sepet Ortalaması",
                                value: String(format: "%.2f ₺", data.average_order_value),
                                icon: "cart.fill",
                                iconColor: .blue
                            )
                            
                            KPICard(
                                title: "İptal Ciro",
                                value: String(format: "%.2f ₺", data.cancelled_revenue),
                                icon: "xmark.octagon.fill",
                                iconColor: .red
                            )
                        }
                        .padding(.horizontal, Theme.spacing)
                        
                        // MARK: - Gösterim Birimi (Ciro / Adet)
                        Picker("Gösterim Birimi", selection: $selectedMetric) {
                            Text("Ciro (₺)").tag(MetricType.revenue)
                            Text("Adet").tag(MetricType.count)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, Theme.spacing)
                        
                        // MARK: - Kategori Dağılımı Grafiği (Donut)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Kategori Dağılımı")
                                .font(Theme.titleFont)
                                .foregroundColor(Theme.textPrimary)
                            
                            Chart(data.category_sales) { stat in
                                SectorMark(
                                    angle: .value("Değer", selectedMetric == .revenue ? stat.revenue : Double(stat.sales_count)),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 2
                                )
                                .foregroundStyle(by: .value("Kategori", stat.category))
                                .cornerRadius(4)
                            }
                            .frame(height: 220)
                            .chartLegend(position: .bottom, alignment: .center, spacing: 16)
                        }
                        .padding(Theme.spacing)
                        .background(Theme.surface)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth))
                        .padding(.horizontal, Theme.spacing)
                        
                        // MARK: - Ürün Satışları Grafiği (Horizontal Bar)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ürün Satış Performansı")
                                .font(Theme.titleFont)
                                .foregroundColor(Theme.textPrimary)
                            
                            Chart(data.product_sales) { stat in
                                BarMark(
                                    x: .value("Değer", selectedMetric == .revenue ? stat.revenue : Double(stat.sales_count)),
                                    y: .value("Ürün", stat.title)
                                )
                                .foregroundStyle(Theme.primary.gradient)
                                .cornerRadius(4)
                            }
                            // Ürün sayısına göre dinamik yükseklik (UX/Scroll deneyimi için)
                            .frame(height: max(200, CGFloat(data.product_sales.count * 45)))
                        }
                        .padding(Theme.spacing)
                        .background(Theme.surface)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth))
                        .padding(.horizontal, Theme.spacing)
                        
                        // MARK: - Sipariş Durumu Grafiği (Donut)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sipariş Durumu")
                                .font(Theme.titleFont)
                                .foregroundColor(Theme.textPrimary)
                            
                            let orderStats: [(id: String, count: Int, color: Color)] = [
                                ("Başarılı", data.successful_orders, .green),
                                ("İptal", data.cancelled_orders, .red)
                            ]
                            
                            Chart(orderStats, id: \.id) { stat in
                                SectorMark(
                                    angle: .value("Adet", stat.count),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 2
                                )
                                .foregroundStyle(stat.color)
                                .cornerRadius(4)
                            }
                            .frame(height: 220)
                            .chartBackground { proxy in
                                Text("Siparişler")
                                    .font(Theme.bodyFont.bold())
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .chartLegend(position: .bottom, alignment: .center, spacing: 16)
                        }
                        .padding(Theme.spacing)
                        .background(Theme.surface)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth))
                        .padding(.horizontal, Theme.spacing)
                        .padding(.bottom, 24)
                        
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundColor(.orange)
                            Text(error).font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                            Button("Tekrar Dene") {
                                Task { await viewModel.loadData(token: appState.token) }
                            }
                            .font(Theme.bodyFont.bold())
                            .foregroundColor(Theme.primary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Analitik & Raporlar")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.dashboardData == nil {
                await viewModel.loadData(token: appState.token)
            }
        }
    }
}

// MARK: - UI Alt Bileşenleri

fileprivate struct KPICard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                Text(value)
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth)
        )
    }
}
