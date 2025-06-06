//
//  ProductItemView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 06/06/2025.
//


import SwiftUI

struct ProductItemView: View {
    let product: ProductListItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: product.image) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
            } placeholder: {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(.secondary)
            }
            
            Text(product.title)
                .font(.title2.weight(.light))
                .lineLimit(2)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(product.price.currency.rawValue)
                    .font(.caption.weight(.light))
                    .lineLimit(1)
                
                Text(String(format: "%.2f", product.price.value))
                    .font(.body.weight(.medium))
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}