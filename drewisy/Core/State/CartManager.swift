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
    
    func addToCart(product: ProductResponse) {
        cartItems[product, default: 0] += 1
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
