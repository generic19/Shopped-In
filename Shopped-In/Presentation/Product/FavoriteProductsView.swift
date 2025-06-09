import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FavoriteProductsView: View {
    @State private var favoriteProducts: [Product] = []
    @State private var isLoading = true

    @State private var showAlert = false
    @State private var productToDelete: Product?

    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if favoriteProducts.isEmpty {
                Text("No favorite products yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(favoriteProducts, id: \.title) { product in
                    HStack {
                        AsyncImage(url: URL(string: product.images.first ?? "")) { image in
                            image.resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                                .frame(width: 50, height: 50)
                        }

                        VStack(alignment: .leading) {
                            Text(product.title).bold()
                            Text("\(product.price) EGP")
                                .foregroundColor(.gray)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            productToDelete = product
                            showAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .alert("Are you sure you want to remove this product from favorites?", isPresented: $showAlert) {
            Button("Delete", role: .destructive) {
                if let product = productToDelete {
                    deleteFavorite(product)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Favorites")
        .onAppear {
            fetchFavorites()
        }
    }

    func fetchFavorites() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.favoriteProducts = []
            self.isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("favorites").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let docs = snapshot?.documents {
                    let products = docs.compactMap { doc -> Product? in
                        let data = doc.data()
                        let title = data["title"] as? String ?? ""
                        let price = data["price"] as? String ?? ""
                        let images = data["images"] as? [String] ?? []
                        let description = data["description"] as? String ?? ""
                        return Product(title: title, price: price, images: images, sizes: [], colors: [], rating: 0, description: description, reviews: [])
                    }
                    self.favoriteProducts = products
                } else {
                    self.favoriteProducts = []
                }
                self.isLoading = false
            }
        }
    }

    func deleteFavorite(_ product: Product) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("favorites").document(product.title).delete { error in
            if let error = error {
                print("Failed to delete product: \(error.localizedDescription)")
            } else {
                print("Product deleted successfully.")
                favoriteProducts.removeAll { $0.title == product.title }
            }
        }
    }
}

