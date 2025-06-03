import SwiftUI

struct ProfileView: View {
    var body: some View {
        let apiService = APIService.shared
        let remote = AddressRemoteDataSourceImpl(service: apiService)
        let repo = AddressRepositoryImpl(remote: remote)
        let getAddressUseCase = GetAddressesUseCase(repository: repo)
        let getDefaultAddressUseCase = GetDefaultAddressUseCase(repository: repo)
        let deleteAddressUseCase = DeleteAddressUseCase(repository: repo)
        let setDefaultAddressUseCase = SetDefaultAddressUseCase(repository: repo)

        let tokenRepo: TokenRepo = TokenRepoImpl()
        let addressesViewModel = AddressViewModel(getAddressUseCase: getAddressUseCase,
                                                  getDefaultAddressUseCase: getDefaultAddressUseCase,
                                                  deleteAddressUseCase: deleteAddressUseCase,
                                                  setDefaultAddressUseCase: setDefaultAddressUseCase,
                                                  tokenRepo: tokenRepo)
        AddressesView(viewModel: addressesViewModel)
//        Text("profile tab")
    }
}
