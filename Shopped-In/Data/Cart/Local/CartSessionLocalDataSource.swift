//
//  CartSessionLocalDataSource.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

protocol CartSessionLocalDataSource {
    var cartId: String? { get set }
    func clear()
}
