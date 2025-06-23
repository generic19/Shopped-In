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
            Text("Sort")
        }
    }
}
