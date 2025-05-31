
import SwiftUI

struct BrandsView: View {
    @ObservedObject var viewModel = BrandsViewModel(getBrandsUseCase: GetBrandsUseCase(repository: BrandRepositoryImpl(remote: BrandRemoteDataSourceImpl(service: APIService.shared))))
    
    @State var query = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Featured Brands")
                    .font(.title.bold())
                
                if viewModel.isLoading {
                    ProgressView {
                        Text("Loading brands...")
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(viewModel.brands, id: \.id) { brand in
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .searchable(text: $query, prompt: "Search")
        .onAppear {
            viewModel.getBrands()
        }
    }
}


#Preview {
    BrandsView()
}

private struct BrandItemView: View {
    let brand: Brand
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: brand.image) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
            } placeholder: {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(.secondary)
            }
            Text(brand.title)
        }
    }
}
