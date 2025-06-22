//
//  FavoriteSectionView.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 22/06/2025.
//

import SwiftUI

struct FavoriteSectionView: View {
    @StateObject var viewModel: FavoriteViewModel = DIContainer.resolve()
    
    @State private var showAlert = false
    @State private var productToDelete: Product?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Your Favorites")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                NavigationLink {
                    FavoriteProductsView(viewModel: viewModel)
                } label: {
                    Text("See more")
                }
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 16)
            } else if viewModel.favoriteProducts.isEmpty {
                Text("No favorite products yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemFill))
                    )
            } else {
                ForEach(viewModel.favoriteProducts.prefix(2), id: \.id) { product in
                    NavigationLink {
                        ProductDetailView(productID: product.id)
                    } label: {
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
                                Text("\(product.price) EGP")
                                    .foregroundColor(.gray)
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
            Button("Cancel", role: .cancel) { }
        }
        .padding(.vertical, 16)
        .onAppear {
            viewModel.fetchFavorites()
        }
    }
}
