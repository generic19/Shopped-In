
import SwiftUI

struct BrandProductsView: View {
    let brand: Brand
    
    @ObservedObject var viewModel = BrandProductsViewModel(getProductsByBrandUseCase: GetProductsByBrandUseCase(repository: ProductRepositoryImpl(remote: ProductRemoteDataSourceImpl(service: APIService.shared))))
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView {
                        Text("Loading products...")
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(viewModel.products, id: \.id) { product in
                            ProductItemView(product: product)
                                .padding(16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(brand.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if viewModel.brand != self.brand {
                viewModel.getProducts(brand: self.brand)
            }
        }
    }
}


private struct ProductItemView: View {
    let product: ProductListItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: product.image) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
            } placeholder: {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(.secondary)
            }
            Text(product.title)
                .font(.title2.weight(.light))
                .lineLimit(2)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(product.price.currency.rawValue)
                    .font(.caption.weight(.light))
                    .lineLimit(1)
                
                Text(String(format: "%.2f", product.price.value))
                    .font(.body.weight(.medium))
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    ProductItemView(product: ProductListItem(id: "", title: "Product Title Product Title Product Title Product Title", image: nil, price: .init(value: 120, currency: .EGP)))
}
