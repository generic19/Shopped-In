

import Buy
import SwiftUI
import FirebaseAuth

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
    @StateObject private var viewModel: ProductDetailViewModel = DIContainer.shared.resolve()
    @StateObject private var favoriteViewModel: FavoriteViewModel = DIContainer.shared.resolve()
    @StateObject private var cartViewModel: CartViewModel = DIContainer.shared.resolve()
    @State private var currencyConverter: CurrencyConverter = DIContainer.shared.resolve()
    
    let productID: String
    @State var toastMessage = ""
    @State var toastColor = Color.green

    @State private var currentExchangeRate: Double = 1
    @State private var currentCurrency: String = "EGP"

    @State private var navigateToFavorites = false

    init(productID: String) {
        self.productID = productID
    }

    var body: some View {
        ZStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let product = viewModel.product {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Images
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
                                    Auth.auth().currentUser?.reload { error in
                                        if let error = error {
                                            print("Error reloading user: \(error)")
                                        } else if Auth.auth().currentUser != nil {
                                            viewModel.toggleFavorite()
                                            navigateToFavorites = true
                                        } else {
                                            print("User not signed in")
                                        }
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

                                // Title and Price
                                Text(product.title)
                                    .font(.title2).bold()

                                if let priceValue = Double(product.price) {
                                    Text("\(priceValue * currentExchangeRate, specifier: "%.2f") \(currentCurrency)")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Invalid price")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                }

                                // Rating
                                HStack {
                                    ForEach(0 ..< 5) { index in
                                        Image(systemName: index < product.rating ? "star.fill" : "star")
                                            .foregroundColor(.orange)
                                    }
                                }

                                // Sizes
                                Text("Sizes").font(.headline)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(product.sizes, id: \.self) { size in
                                            Text(size)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, size.count > 1 ? 16 : 12)
                                                .background(viewModel.selectedSize == size ? Color.orange.opacity(0.7) : Color.gray.opacity(0.2))
                                                .foregroundColor(.black)
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    viewModel.selectedSize = size
                                                    viewModel.updateSelectedVariant()
                                                }
                                        }
                                    }
                                }

                                // Colors
                                Text("Colors").font(.headline)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(product.colors, id: \.name) { colorOption in
                                            Circle()
                                                .fill(Color(hex: colorOption.hexCode))
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Circle()
                                                        .stroke(viewModel.selectedColor == colorOption.name ? Color.orange : Color.clear, lineWidth: 3)
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                                .onTapGesture {
                                                    viewModel.selectedColor = colorOption.name
                                                    viewModel.updateSelectedVariant()
                                                }
                                        }
                                    }
                                }

                                // Description
                                Text("Description").font(.headline)
                                Text(product.description)

                                // Reviews
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

                                Spacer(minLength: 80)
                            }
                            .padding()
                        }
                        VStack {
                            Divider()
                            if let selectedVariantId = viewModel.selectedVariantId, let cartItem = cartViewModel.cartItemFor(variantId: selectedVariantId) {
                                HStack(spacing: 100) {
                                    Button(action: {
                                        if cartItem.quantity == 1 {
                                            cartViewModel.removeItem(lineItemId: cartItem.id)
                                        } else {
                                            cartViewModel.onMinusQuantityTapped(lineItemId: cartItem.id)
                                        }
                                    }) {
                                        Text("-")
                                            .font(.title2)
                                            .bold()
                                            .frame(width: 40, height: 40)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }

                                    Text("\(cartItem.quantity)")
                                        .font(.title3)
                                        .frame(minWidth: 40)
                                        .padding(.horizontal)

                                    Button(action: {
                                        cartViewModel.onAddQuantityTapped(lineItemId: cartItem.id)

                                    }) {
                                        Text("+")
                                            .font(.title2)
                                            .bold()
                                            .frame(width: 40, height: 40)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            } else {
                                Button(action: {
                                    if let variantId = viewModel.selectedVariantId {
                                        cartViewModel.addToCart(variantId: variantId, quantity: 1)
                                        toastMessage = "Added to cart successfully!"
                                        toastColor = Color.green
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            toastMessage = ""
                                        }
                                    } else {
                                        toastMessage = "Failed to add to cart,\nplease choose Color and Size!"
                                        toastColor = Color.red
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            toastMessage = ""
                                        }
                                    }
                                }) {
                                    Text("Add to Cart")
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                        .background(Color.white.shadow(radius: 5))
                    }
                } else {
                    Text("Product not found.")
                        .foregroundColor(.red)
                }
            }

            NavigationLink(destination: FavoriteProductsView(viewModel: favoriteViewModel), isActive: $navigateToFavorites) {
                EmptyView()
            }

            .onAppear {
                viewModel.fetchProduct(by: productID)
                cartViewModel.loadCart()
                if (currencyConverter.usdExchangeRate != nil) && currencyConverter.getCurrency() == "USD" {
                    currentCurrency = "USD"
                    currentExchangeRate = currencyConverter.usdExchangeRate!
                }
            }

            if !toastMessage.isEmpty {
                ToastView(message: toastMessage, backgroundColor: toastColor)
            }
        }
    }
}

// MARK: - Preview

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(productID: "gid://shopify/Product/8327391827341")
    }
}

// MARK: - Extension CartViewModel

extension CartViewModel {
    func cartItemFor(variantId: String?) -> CartItem? {
        guard let variantId, let cart else { return nil }

        for ct in cart.items {
            if ct.variantId == variantId {
                return ct
            }
        }

        return nil
    }
}
