import SwiftUI

struct ProfileView: View {
    var body: some View {
        let apiService = BuyAPIService.shared
        let remote = CartRemoteDataSourceImpl(service: apiService)
        let repo = CartRepositoryImpl(remote: remote)
        let cartViewModel = CartViewModel(cartRepo: repo)
        CartView(viewModel: cartViewModel)
//        Text("profile tab")
    }
}
