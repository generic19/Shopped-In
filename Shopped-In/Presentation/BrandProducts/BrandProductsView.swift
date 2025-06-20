
import SwiftUI

struct BrandProductsView: View {
    let brand: Brand

    @ObservedObject var viewModel: BrandProductsViewModel = DIContainer.shared.resolve()
    
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
                } else if let products = viewModel.products {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(products, id: \.id) { product in
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
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                ProductsSortMenu(sort: $viewModel.sort)
            }
        })
        .searchable(text: $viewModel.query, prompt: "Search")
        .onAppear {
            if viewModel.brand != self.brand {
                viewModel.getProducts(brand: self.brand)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BrandProductsView(brand: Brand(id: "gid://shopify/Collection/466411978788", title: "FAKE", image: nil))
    }
}
