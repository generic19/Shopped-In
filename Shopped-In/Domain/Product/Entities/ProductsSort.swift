//
//  ProductsSort.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 05/06/2025.
//

enum ProductsSort: CaseIterable, Identifiable {
    case bestSellers
    case relevance
    case price
    case title
    case mostRecent
    
    var id: Self { self }
}
