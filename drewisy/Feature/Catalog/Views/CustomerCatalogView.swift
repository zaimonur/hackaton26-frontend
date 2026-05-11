//
//  CustomerCatalogView.swift
//  drewisy
//
//  Created by Onur Zaim on 11.05.2026.
//

import SwiftUI

struct CustomerCatalogView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.primary)
                
                Text("Katalog")
                    .font(Theme.titleFont)
                    .foregroundColor(Theme.textPrimary)
                
                Text("Ürünleri inceleme ve sepet alanı.")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }
}
