import Combine
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel = DIContainer.resolve()
    @State private var navigateToSettings = false
    @EnvironmentObject private var appSwitch: AppSwitch

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome \(viewModel.user?.firstName ?? "Guest")")
                        .font(.title)
                        .bold()
                        .padding(.top)
                    if viewModel.user != nil {
                        // CartButton
                        NavigationLink(destination: CartView()) {
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
                        FavoriteSectionView()
                    } else {
                        HStack {
                            Spacer()
                            Image(systemName: "person.fill.questionmark")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                            Spacer()
                        }.padding(.top, 80)

                        Button {
                            viewModel.signOutUser {
                                appSwitch.switchTo(.authentication)
                            }
                        } label: {
                            Text("Sign In to Access Your Profile")
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
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
                    if viewModel.user != nil {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                viewModel.signOutUser {
                                    appSwitch.switchTo(.authentication)
                                }
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
        }
        .onAppear {
            viewModel.load()
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
