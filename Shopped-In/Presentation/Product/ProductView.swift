import Buy
import SwiftUI

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
    let productID: String

    init(productID: String) {
        let apiService = BuyAPIService.shared
        let remote = ProductRemoteDataSourceImpl(service: apiService)
        let repo = ProductRepositoryImpl(remote: remote)
        let useCase = FetchProductUseCase(repository: repo)
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(fetchProductUseCase: useCase))
        self.productID = productID
    }

    var body: some View {
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

                            // Title and Price
                            Text(product.title)
                                .font(.title2).bold()
                            Text("\(product.price) EGP")
                                .font(.title3)
                                .foregroundColor(.gray)

                            // Rating
                            HStack {
                                ForEach(0..<5) { index in
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
                        Button(action: {
                            if let variantId = viewModel.selectedVariantId {
                                print("Add to cart: \(variantId)")
                            } else {
                                print("choose color and image")
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
                    .background(Color.white.shadow(radius: 5))
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
        ProductDetailView(productID: "gid://shopify/Product/8327391827341")
    }
}

