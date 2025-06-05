//
//  BrandsSort.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 05/06/2025.
//


enum BrandsSort: CaseIterable, Identifiable {
    case title
    case mostRecent
    case relevance
    
    var id: Self { self }
}