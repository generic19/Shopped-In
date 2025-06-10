import SwiftUI

struct ProfileView: View {
    var body: some View {
        let apiService = APIService.shared
        let remote = AddressRemoteDataSourceImpl(service: apiService)
        let repo = AddressRepositoryImpl(remote: remote)
        let tokenRepo: TokenRepo = TokenRepoImpl()
        let addressesViewModel = AddressViewModel(repository: repo, tokenRepo: tokenRepo)
        AddressesView(viewModel: addressesViewModel)
//        Text("profile tab")
    }
}
