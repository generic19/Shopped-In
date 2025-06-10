import Foundation
import FirebaseAuth
import FirebaseFirestore

class FavoriteViewModel: ObservableObject {
    @Published var favoriteProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let addFavoriteUseCase: AddFavoriteProductUseCase
    private let removeFavoriteUseCase: RemoveFavoriteProductUseCase
    private let checkFavoriteUseCase: CheckFavoriteProductUseCase
    private let db = Firestore.firestore()
    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    init(
        addFavoriteUseCase: AddFavoriteProductUseCase,
        removeFavoriteUseCase: RemoveFavoriteProductUseCase,
        checkFavoriteUseCase: CheckFavoriteProductUseCase
    ) {
        self.addFavoriteUseCase = addFavoriteUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
        self.checkFavoriteUseCase = checkFavoriteUseCase
    }

    func fetchFavorites() {
        guard let uid = userID else {
            self.favoriteProducts = []
            return
        }

        isLoading = true
        db.collection("users").document(uid).collection("favorites").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let docs = snapshot?.documents {
                    self?.favoriteProducts = docs.compactMap { doc -> Product? in
                        let data = doc.data()
                        let title = data["title"] as? String ?? ""
                        let price = data["price"] as? String ?? ""
                        let images = data["images"] as? [String] ?? []
                        let description = data["description"] as? String ?? ""
                        return Product(title: title, price: price, images: images, sizes: [], colors: [], rating: 0, description: description, reviews: [])
                    }
                } else {
                    self?.favoriteProducts = []
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }

    func removeFavorite(_ product: Product) {
        removeFavoriteUseCase.removeFavorite(productID: product.title) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    self?.favoriteProducts.removeAll { $0.title == product.title }
                } else {
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }

    func addFavorite(_ product: Product) {
        addFavoriteUseCase.addFavorite(product: product) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchFavorites()
                }
            }
        }
    }

    func isProductFavorite(productID: String, completion: @escaping (Bool) -> Void) {
        checkFavoriteUseCase.checkFavorite(productID: productID, completion: completion)
    }
}

