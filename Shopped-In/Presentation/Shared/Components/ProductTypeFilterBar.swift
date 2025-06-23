//
//  ProductTypeFilterBar.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 23/06/2025.
//


import SwiftUI

struct ProductTypeFilterBar: View {
    static let productTypeChoices: [ProductType?] = [nil] + ProductType.allCases
    
    @Binding var selectedProductType: ProductType?
    
    var body: some View {
        Picker("Product Type", selection: $selectedProductType) {
            ForEach(ProductTypeFilterBar.productTypeChoices, id: \.self) { productType in
                Text(productType?.rawValue.capitalized ?? "All").tag(productType)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(.regularMaterial)
        .padding(.horizontal, -16)
    }
}