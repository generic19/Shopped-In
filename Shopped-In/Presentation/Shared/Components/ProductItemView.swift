//
//  ProductItemView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 06/06/2025.
//

import SwiftUI

struct ProductItemView: View {
    let product: ProductListItem
    let currencyConverter: CurrencyConverter = DIContainer.shared.resolve()
    
    @State var isFavorite: Bool = false
    @State private var currentExchangeRate: Double = 1
    @State private var currentCurrency: String = "EGP"


    var body: some View {
        NavigationLink {
            ProductDetailView(productID: product.id)
        } label: {
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
                    Text(currentCurrency)
                        .font(.caption.weight(.light))
                        .lineLimit(1)

                    Text(String(format: "%.2f", product.price.value * currentExchangeRate))
                        .font(.body.weight(.medium))
                        .lineLimit(1)
                }

                Spacer()
            }
        }
        .tint(.primary)
        .onAppear{
            if (currencyConverter.usdExchangeRate != nil) && currencyConverter.getCurrency() == "USD" {
                currentCurrency = "USD"
                currentExchangeRate = currencyConverter.usdExchangeRate!
            }
        }
    }
}
