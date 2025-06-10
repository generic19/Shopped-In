import SwiftUI
import FirebaseAuth
import Buy

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - ProductDetailView
struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @StateObject private var favoriteViewModel: FavoriteViewModel

    let productID: String
    @State private var navigateToFavorites = false

    init(productID: String) {
        self.productID = productID

        let apiService = APIService.shared
        let remote = ProductRemoteDataSourceImpl(service: apiService)
        let productRepo = ProductRepositoryImpl(remote: remote)
        let favoriteRepo = FavoriteRepositoryImpl()
        let fetchUseCase = FetchProductUseCase(repository: productRepo)
        let addFavoriteUseCase = AddFavoriteProductUseCase(favoriteProductRepository: favoriteRepo)
        let removeFavoriteUseCase = RemoveFavoriteProductUseCase(favoriteProductRepository: favoriteRepo)
        let checkFavoriteUseCase = CheckFavoriteProductUseCase(favoriteProductRepository: favoriteRepo)

        _viewModel = StateObject(
            wrappedValue: ProductDetailViewModel(
                fetchProductUseCase: fetchUseCase,
                addFavoriteUseCase: addFavoriteUseCase,
                removeFavoriteUseCase: removeFavoriteUseCase,
                checkFavoriteUseCase: checkFavoriteUseCase
            )
        )

        _favoriteViewModel = StateObject(
            wrappedValue: FavoriteViewModel(addFavoriteUseCase:addFavoriteUseCase, removeFavoriteUseCase: removeFavoriteUseCase, checkFavoriteUseCase: checkFavoriteUseCase)
        )
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let product = viewModel.product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Image + Heart
                        ZStack(alignment: .topTrailing) {
                            TabView {
                                ForEach(product.images, id: \.self) { image in
                                    AsyncImage(url: URL(string: image)) { img in
                                        img.resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                            }
                            .frame(height: 300)
                            .tabViewStyle(PageTabViewStyle())

                            Button(action: {
                                if Auth.auth().currentUser != nil {
                                    viewModel.toggleFavorite()
                                    navigateToFavorites = true
                                } else {
                                    print("User not signed in")
                                }
                            }) {
                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                    .padding(12)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                        }

                        Text(product.title)
                            .font(.title2).bold()
                        Text("\(product.price) EGP")
                            .font(.title3)
                            .foregroundColor(.gray)

                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < product.rating ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                            }
                        }

                        Text("Sizes").font(.headline)
                        HStack {
                            ForEach(product.sizes, id: \.self) { size in
                                Text(size)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }

                        Text("Colors").font(.headline)
                        HStack {
                            ForEach(product.colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 30, height: 30)
                            }
                        }

                        Text("Description").font(.headline)
                        Text(product.description)

                        Text("Customer Reviews").font(.headline)
                        ForEach(product.reviews, id: \.name) { review in
                            HStack(alignment: .top) {
                                Image(uiImage: review.avatar)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(review.name).bold()
                                    Text(review.comment)
                                }
                            }
                        }

                        Button(action: {
                            print("Add to cart pressed")
                        }) {
                            Text("Add to Cart")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)

                        // Navigation to Favorites View
                        NavigationLink(destination: FavoriteProductsView(viewModel: favoriteViewModel), isActive: $navigateToFavorites) {
                            EmptyView()
                        }
                    }
                    .padding()
                }
            } else {
                Text("Product not found.")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            viewModel.fetchProduct(by: productID)
        }
    }
}

// MARK: - Preview
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductDetailView(productID: "gid://shopify/Product/8327391827341")
        }
    }
}

