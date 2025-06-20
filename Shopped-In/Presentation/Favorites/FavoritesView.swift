import SwiftUI


struct FavoriteProductsView: View {
    @StateObject var viewModel: FavoriteViewModel
    @State private var selectedProductID: String?
    @State private var navigateToDetails = false

    @State private var showAlert = false
    @State private var productToDelete: Product?

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.favoriteProducts.isEmpty {
                Text("No favorite products yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.favoriteProducts, id: \.title) { product in
                    Button {
                        selectedProductID = product.id
                        print("selected pro: \(product.id)")
                        navigateToDetails = true
                    } label: {
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
                    viewModel.removeFavorite(product)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .background(
            NavigationLink(
                destination: Group {
                    if let productID = selectedProductID, !productID.isEmpty {
                        ProductDetailView(productID: productID)
                    } else {
                        EmptyView()
                    }
                },
                isActive: $navigateToDetails,
                label: { EmptyView() }
            )
            .hidden()
        )
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.fetchFavorites()
        }
    }
}


