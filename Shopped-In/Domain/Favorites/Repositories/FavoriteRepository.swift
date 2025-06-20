//
//  FavoriteRepository.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Foundation

protocol FavoriteRepository {
    func isFavorite(productID: String, completion: @escaping (Bool) -> Void)
    func addToFavorite(product: Product, completion: @escaping (Error?) -> Void)
    func removeFromFavorite(productID: String, completion: @escaping (Error?) -> Void)
}
