import SwiftUI

struct ProfileView: View {
    @State private var navigateToSettings = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome Name")
                    .font(.title)
                    .bold()
                    .padding(.top)
                // CartButton
                NavigationLink(destination: CartView(viewModel: DIContainer.shared.resolve())) {
                    HStack {
                        Image(systemName: "cart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .foregroundStyle(.white)

                        Text("Go to Cart")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }

                // Orders Section
                RecentOrdersView(viewModel: DIContainer.shared.resolve())
                
                // Favorites Section
                VStack(alignment: .leading) {
                    HStack {
                        Text("Favorites")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button("See more") {
                            // Action to see more favorites
                        }
                    }
                    ForEach(0 ..< 2) { index in
                        FavoriteItemView(itemIndex: index)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        navigateToSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
        }
    }
}

struct FavoriteItemView: View {
    let itemIndex: Int
    var body: some View {
        Text("Favorite Item \(itemIndex + 1)")
            .padding()
            .background(Color.pink.opacity(0.2))
            .cornerRadius(8)
    }
}
