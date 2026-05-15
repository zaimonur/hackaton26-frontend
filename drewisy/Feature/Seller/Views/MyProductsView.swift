//
//  MyProductsView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

fileprivate enum EditMode {
    case none
    case price
    case stock
}

struct MyProductsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = MyProductsViewModel()
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Kategori Barı
                categoryBar
                
                // MARK: - İçerik Yönetimi
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(Theme.primary)
                    Spacer()
                } else if viewModel.filteredProducts.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "bag.badge.minus")
                            .font(.system(size: 48)).foregroundColor(Theme.textSecondary)
                        Text("Bu kategoride ürün bulunamadı.")
                            .font(Theme.bodyFont).foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                } else {
                    // Accordion Listesi
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredProducts) { product in
                                ExpandableProductRow(
                                    product: product,
                                    viewModel: viewModel,
                                    token: appState.token
                                )
                            }
                        }
                        .padding(Theme.spacing)
                    }
                }
            }
        }
        .navigationTitle("Ürünlerim (Envanter 2.0)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadProducts(token: appState.token)
            }
        }
    }
    
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.uniqueCategories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(Theme.bodyFont.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedCategory == category ? Theme.primary : Color.clear)
                            .foregroundColor(viewModel.selectedCategory == category ? .white : Theme.textPrimary)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(viewModel.selectedCategory == category ? Color.clear : Theme.textSecondary.opacity(0.3), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, Theme.spacing)
            .padding(.vertical, 12)
        }
        .background(Theme.surface)
        .overlay(Rectangle().frame(height: Theme.borderWidth).foregroundColor(Theme.textSecondary.opacity(0.1)), alignment: .bottom)
    }
}

// MARK: - Accordion Row Component

fileprivate struct ExpandableProductRow: View {
    let product: ProductResponse
    var viewModel: MyProductsViewModel
    var token: String?
    
    @State private var isExpanded = false
    @State private var editMode: EditMode = .none
    @State private var tempPrice: String
    @State private var tempStock: Int
    
    init(product: ProductResponse, viewModel: MyProductsViewModel, token: String?) {
        self.product = product
        self.viewModel = viewModel
        self.token = token
        _tempPrice = State(initialValue: String(format: "%.2f", product.price))
        _tempStock = State(initialValue: product.stock)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                    if let image = phase.image { image.resizable().scaledToFill() }
                    else { Image(systemName: "photo").foregroundColor(Theme.textSecondary) }
                }
                .frame(width: 60, height: 60).background(Theme.background).clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title).font(Theme.bodyFont.bold()).foregroundColor(Theme.textPrimary).lineLimit(1)
                    Text(product.category).font(Theme.captionFont).foregroundColor(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(product.price, specifier: "%.2f") ₺").font(Theme.bodyFont.bold()).foregroundColor(Theme.primary)
                    if product.stock <= 10 {
                        Text("Son \(product.stock) Ürün").font(.system(size: 10, weight: .bold)).padding(.horizontal, 6).padding(.vertical, 2).background(Color.red.opacity(0.15)).foregroundColor(.red).cornerRadius(4)
                    } else {
                        Text("Stok: \(product.stock)").font(Theme.captionFont).foregroundColor(Theme.textSecondary)
                    }
                }
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down").font(.caption.bold()).foregroundColor(Theme.textSecondary)
            }
            .padding().contentShape(Rectangle())
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isExpanded.toggle(); editMode = .none }
            }
            
            if isExpanded {
                Divider().background(Theme.textSecondary.opacity(0.2)).padding(.horizontal)
                VStack(spacing: 12) {
                    // Stok Düzenleme
                    HStack {
                        if editMode == .stock {
                            Stepper("Stok: \(tempStock)", value: $tempStock, in: 0...9999).font(Theme.bodyFont)
                            Button { Task { if await viewModel.updateProductInline(id: product.id, newPrice: nil, newStock: tempStock, token: token) { withAnimation { editMode = .none } } } } label: { Image(systemName: "checkmark.circle.fill").font(.title2).foregroundColor(.green) }
                        } else {
                            Button { withAnimation { editMode = .stock } } label: { HStack { Image(systemName: "shippingbox.fill"); Text("Stok Güncelle"); Spacer() }.font(Theme.bodyFont.bold()).foregroundColor(Theme.textPrimary) }
                        }
                    }.padding(.horizontal).padding(.vertical, 8).background(Theme.background).cornerRadius(8)
                    
                    // Fiyat Düzenleme
                    HStack {
                        if editMode == .price {
                            TextField("Fiyat", text: $tempPrice).keyboardType(.decimalPad).font(Theme.bodyFont).padding(8).background(Theme.surface).cornerRadius(6).overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.primary, lineWidth: 1))
                            Button { Task { let formatted = tempPrice.replacingOccurrences(of: ",", with: "."); if let dbl = Double(formatted) { if await viewModel.updateProductInline(id: product.id, newPrice: dbl, newStock: nil, token: token) { withAnimation { editMode = .none } } } } } label: { Image(systemName: "checkmark.circle.fill").font(.title2).foregroundColor(.green) }
                        } else {
                            Button { withAnimation { editMode = .price } } label: { HStack { Image(systemName: "tag.fill"); Text("Fiyat Güncelle"); Spacer() }.font(Theme.bodyFont.bold()).foregroundColor(Theme.textPrimary) }
                        }
                    }.padding(.horizontal).padding(.vertical, 8).background(Theme.background).cornerRadius(8)
                    
                    HStack(spacing: 12) {
                        // DEĞİŞİKLİK BURADA: Müşteri Gözü artık Preview ekranına gider.
                        NavigationLink(destination: SellerProductPreviewView(product: product)) {
                            HStack { Image(systemName: "eye.fill"); Text("Müşteri Gözü") }
                            .font(Theme.captionFont.bold()).frame(maxWidth: .infinity).padding(.vertical, 10).background(Theme.primary.opacity(0.1)).foregroundColor(Theme.primary).cornerRadius(8)
                        }
                        
                        NavigationLink(destination: SellerProductDetailView(product: product)) {
                            HStack { Image(systemName: "slider.horizontal.3"); Text("Detaylı Düzenle") }
                            .font(Theme.captionFont.bold()).frame(maxWidth: .infinity).padding(.vertical, 10).background(Theme.textSecondary.opacity(0.1)).foregroundColor(Theme.textPrimary).cornerRadius(8)
                        }
                    }
                }.padding().background(Theme.surface.opacity(0.5))
            }
        }
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth))
        .onChange(of: product.price) { _, n in tempPrice = String(format: "%.2f", n) }
        .onChange(of: product.stock) { _, n in tempStock = n }
    }
}
