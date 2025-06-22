import SwiftUI

import SwiftUI

struct FavoriteProductsView: View {
    @StateObject var viewModel: FavoriteViewModel
    @State private var selectedProductID: String?
    @State private var showAlert = false
    @State private var productToDelete: Product?

    @State private var currencyConverter: CurrencyConverter = DIContainer.shared.resolve()

    @State private var currentExchangeRate: Double = 1
    @State private var currentCurrency: String = "EGP"

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.favoriteProducts.isEmpty {
                Text("No favorite products yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.favoriteProducts, id: \.id) { product in
                    NavigationLink(
                        destination: ProductDetailView(productID: product.id),
                        tag: product.id,
                        selection: $selectedProductID
                    ) {
                        HStack {
                            AsyncImage(url: URL(string: product.images.first ?? "")) { image in
                                image
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .frame(width: 50, height: 50)
                            }

                            VStack(alignment: .leading) {
                                Text(product.title).bold()
                                if let priceValue = Double(product.price) {
                                    Text("\(priceValue * currentExchangeRate, specifier: "%.2f") \(currentCurrency)")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Invalid price")
                                        .foregroundColor(.red)
                                }
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
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.fetchFavorites()
            if (currencyConverter.usdExchangeRate != nil) && currencyConverter.getCurrency() == "USD" {
                currentCurrency = "USD"
                currentExchangeRate = currencyConverter.usdExchangeRate!
            }
        }
    }
}
