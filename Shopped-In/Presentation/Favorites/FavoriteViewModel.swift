//
//  FavoriteViewModel.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 10/06/2025.
//


//import Foundation
//
//class FavoriteViewModel: ObservableObject {
//    @Published var favorites: [Product] = []
//    @Published var isLoading = false
//
//    private let fetchUseCase: FetchFavoritesUseCase
//    private let addUseCase: AddFavoriteProductUseCase
//    private let removeUseCase: RemoveFavoriteProductUseCase
//
//    init(repository: FavoriteRepository) {
//        self.fetchUseCase = FetchFavoritesUseCase(repository: repository)
//        self.addUseCase = AddFavoriteProductUseCase(repository: repository)
//        self.removeUseCase = RemoveFavoriteProductUseCase(repository: repository)
//    }
//
//    func loadFavorites() {
//        isLoading = true
//        fetchUseCase.execute { [weak self] products in
//            DispatchQueue.main.async {
//                self?.favorites = products
//                self?.isLoading = false
//            }
//        }
//    }
//
//    func deleteFavorite(_ product: Product) {
//        removeUseCase.execute(productID: product.title) { [weak self] error in
//            if error == nil {
//                DispatchQueue.main.async {
//                    self?.favorites.removeAll { $0.title == product.title }
//                }
//            }
//        }
//    }
//}
