
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
                Menu {
                    Button("Best Selling") { viewModel.sort = .bestSellers }
                    Button("Trending") { viewModel.sort = .relevance }
                    Button("Price") { viewModel.sort = .price }
                    Button("Name") { viewModel.sort = .title }
                    Button("New") { viewModel.sort = .mostRecent }
                } label: {
                    switch viewModel.sort {
                        case .bestSellers:
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.red)
                            
                        case .relevance:
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundStyle(.blue)
                            
                        case .price:
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundStyle(.green)
                            
                        case .title:
                            Image(systemName: "textformat.characters")
                                .foregroundStyle(.blue)
                            
                        case .mostRecent:
                            Image(systemName: "clock.badge.fill")
                                .symbolRenderingMode(.multicolor)
                    }
                }
                
                Picker("Sort", selection: $viewModel.sort) {
                    Text("Hot").tag(ProductsSort.bestSellers)
                    Text("Trending").tag(ProductsSort.relevance)
                    Text("Price").tag(ProductsSort.price)
                    Text("Name").tag(ProductsSort.title)
                    Text("New").tag(ProductsSort.mostRecent)
                }
                .pickerStyle(.menu)
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


private struct ProductItemView: View {
    let product: ProductListItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: product.image) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
            } placeholder: {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
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
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        BrandProductsView(brand: Brand(id: "gid://shopify/Collection/466411978788", title: "FAKE", image: nil))
    }
}
