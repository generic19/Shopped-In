//
//  ProductsSortMenu.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 06/06/2025.
//


import SwiftUI

struct ProductsSortMenu: View {
    @Binding var sort: ProductsSort
    
    var body: some View {
        Menu {
            Button("Best Selling") { sort = .bestSellers }
            Button("Trending") { sort = .relevance }
            Button("Price") { sort = .price }
            Button("Name") { sort = .title }
            Button("New") { sort = .mostRecent }
        } label: {
            switch sort {
                case .bestSellers:
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.red)
                    
                case .relevance:
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundStyle(.blue)
                    
                case .price:
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.green)
                    
                case .title:
                    Image(systemName: "textformat.characters")
                        .foregroundStyle(.blue)
                    
                case .mostRecent:
                    Image(systemName: "clock.badge.fill")
                        .symbolRenderingMode(.multicolor)
            }
        }
    }
}