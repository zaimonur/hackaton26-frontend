//
//  CartView.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI

struct CartView: View {
    @Environment(CartManager.self) private var cartManager
    @Environment(AppState.self) private var appState
    @State private var viewModel = CartViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if cartManager.cartItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart.badge.minus")
                            .font(.system(size: 64))
                            .foregroundColor(Theme.textSecondary)
                        Text("Sepetiniz Boş")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.textPrimary)
                        Text("Kataloğa dönüp hemen alışverişe başlayın.")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.textSecondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: Theme.spacing) {
                            let sortedProducts = cartManager.cartItems.keys.sorted { $0.title < $1.title }
                            ForEach(sortedProducts) { product in
                                let quantity = cartManager.cartItems[product] ?? 0
                                cartRow(product: product, quantity: quantity)
                            }
                        }
                        .padding(Theme.spacing)
                    }
                    .safeAreaInset(edge: .bottom) {
                        checkoutFooter
                    }
                }
            }
            .navigationTitle("Sepetim")
            .alert("Bilgi", isPresented: $viewModel.showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
    // MARK: - UI Bileşenleri
    @ViewBuilder
    private func cartRow(product: ProductResponse, quantity: Int) -> some View {
        HStack(spacing: Theme.spacing) {
            // DÜZELTME: BaseURL Eklendi
            AsyncImage(url: URL(string: NetworkManager.baseURL + product.image_path)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                        .overlay(Image(systemName: "photo").foregroundColor(Theme.textSecondary))
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(Theme.bodyFont.bold())
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                Text("\(product.price, specifier: "%.2f") ₺")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.primary)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        cartManager.removeFromCart(product: product)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Text("\(quantity)")
                        .font(Theme.bodyFont.bold())
                        .foregroundColor(Theme.textPrimary)
                        .frame(minWidth: 20, alignment: .center)
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        cartManager.addToCart(product: product)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Theme.textSecondary.opacity(0.1), lineWidth: Theme.borderWidth)
        )
    }
    
    private var checkoutFooter: some View {
        VStack(spacing: Theme.spacing) {
            HStack {
                Text("Toplam")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("\(cartManager.totalPrice, specifier: "%.2f") ₺")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Button {
                Task {
                    let success = await viewModel.checkout(
                        cartItems: cartManager.cartItems,
                        token: appState.token
                    )
                    
                    if success {
                        cartManager.clearCart()
                        viewModel.alertMessage = "Tebrikler, siparişiniz başarıyla alındı!"
                        viewModel.showAlert = true
                    }
                }
            } label: {
                Group {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Siparişi Tamamla")
                    }
                }
                .font(Theme.bodyFont.bold())
                .frame(maxWidth: .infinity)
                .frame(height: Theme.inputHeight)
                .background(Theme.primary)
                .foregroundColor(.white)
                .cornerRadius(Theme.cornerRadius)
            }
            .disabled(viewModel.isSubmitting)
        }
        .padding(Theme.spacing)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height: Theme.borderWidth).foregroundColor(Theme.textSecondary.opacity(0.2)), alignment: .top)
    }
}
