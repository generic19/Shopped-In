import SwiftUI

private let productTypeChoices: [ProductType?] = [nil] + ProductType.allCases

struct CategoriesView: View {
    @StateObject var viewModel: CategoriesViewModel = DIContainer.shared.resolve()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                    Section {
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
                    } header: {
                        Picker("Product Type", selection: $viewModel.selectedProductType) {
                            ForEach(productTypeChoices, id: \.self) { productType in
                                Text(productType?.rawValue.capitalized ?? "All").tag(productType)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.regularMaterial)
                        .padding(.horizontal, -16)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .searchable(text: $viewModel.query, prompt: "Search")
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        DemographicFilterMenu(categoryFilter: $viewModel.categoryFilter)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    ProductsSortMenu(sort: $viewModel.sort)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.categoryFilter = viewModel.categoryFilter.withOnSale(
                            viewModel.categoryFilter.onSale == true ? nil : true
                        )
                    } label: {
                        Image(
                            systemName: viewModel.categoryFilter.onSale == true ? "tag.circle.fill" : "tag.circle"
                        )
                        .foregroundStyle(.orange)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }
}

struct DemographicFilterMenu: View {
    @Binding var categoryFilter: CategoryFilter
    
    var body: some View {
        Menu {
            Button("All Products") {
                categoryFilter = categoryFilter.withDemographic(nil)
            }
            Button("Women") {
                categoryFilter = categoryFilter.withDemographic(.women)
            }
            Button("Men") {
                categoryFilter = categoryFilter.withDemographic(.men)
            }
            Button("Kids") {
                categoryFilter = categoryFilter.withDemographic(.kids)
            }
        } label: {
            let label = switch categoryFilter.demographic {
                case .men: "Men"
                case .women: "Women"
                case .kids: "Kids"
                default: "All Products"
            }
            
            HStack(alignment: .center, spacing: 4) {
                Text(label)
                Image(systemName: "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

#Preview {
    CategoriesView()
}
