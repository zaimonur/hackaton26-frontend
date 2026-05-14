//
//  CartManager.swift
//  drewisy
//
//  Created by Onur Zaim on 13.05.2026.
//

import SwiftUI
import Observation

@Observable
final class CartManager {
    var cartItems: [ProductResponse: Int] = [:]
    
    var totalItemCount: Int {
        cartItems.values.reduce(0, +)
    }
    
    var totalPrice: Double {
        cartItems.reduce(0) { result, item in
            result + (item.key.price * Double(item.value))
        }
    }
    
    /// Ürünü sepete ekler. Varsayılan olarak 1 adet ekler.
    func addToCart(product: ProductResponse, quantity: Int = 1) {
        cartItems[product, default: 0] += quantity
    }
    
    func removeFromCart(product: ProductResponse) {
        guard let count = cartItems[product] else { return }
        if count > 1 {
            cartItems[product] = count - 1
        } else {
            cartItems.removeValue(forKey: product)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
}
