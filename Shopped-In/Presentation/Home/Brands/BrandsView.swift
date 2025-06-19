
import SwiftUI

struct BrandsView: View {
    @ObservedObject var viewModel = BrandsViewModel(getBrandsUseCase: GetBrandsUseCase(repository: BrandRepositoryImpl(remote: BrandRemoteDataSourceImpl(service: BuyAPIService.shared))))
    
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
            ) {
                HStack {
                    Text("Featured Brands")
                        .font(.title.bold())
                    
                    Spacer()
                    
                    Picker("Sort", selection: $viewModel.sort) {
                        Text("Name").tag(BrandsSort.title)
                        Text("New").tag(BrandsSort.mostRecent)
                        Text("Trending").tag(BrandsSort.relevance)
                    }
                    .pickerStyle(.menu)
                }
                ZStack {
                    if viewModel.isLoading {
                        ProgressView {
                            Text("Loading brands...")
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    } else if let brands = viewModel.brands {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 16
                        ) {
                            ForEach(brands, id: \.id) { brand in
                                NavigationLink {
                                    BrandProductsView(brand: brand)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } label: {
                                    BrandItemView(brand: brand)
                                        .padding(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .refreshable {
                viewModel.getBrands(forceNetwork: true)
            }
        }
        .searchable(text: $viewModel.query, prompt: "Search")
        .onAppear {
            if viewModel.brands == nil {
                viewModel.getBrands()
            }
        }
    }
}


private struct BrandItemView: View {
    let brand: Brand
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: brand.image) { image in
                image
                    .resizable()
                    .background(in: .rect)
                    .backgroundStyle(.white)
                    .frame(maxWidth: .infinity)
            } placeholder: {
                Color.secondary
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            Text(brand.title)
        }
    }
}
