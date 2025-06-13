
import Foundation
import SwiftData

class AddressViewModel: ObservableObject {
    let addressRepository: AddressRepository
    private let getAddressUseCase: GetAddressesUseCase
    private let deleteAddressUseCase: DeleteAddressUseCase
    private let setDefaultAddressUseCase: SetDefaultAddressUseCase
    let tokenRepo: TokenRepo
    let customerAccessToken: String?

    @Published var addresses: [Address] = []
    @Published var defaultAddress: Address?
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading: Bool = true
    
    init(repository: AddressRepository ,tokenRepo: TokenRepo){
        self.addressRepository = repository
        self.getAddressUseCase = GetAddressesUseCase(repository: repository)
        self.deleteAddressUseCase = DeleteAddressUseCase(repository: repository)
        self.setDefaultAddressUseCase = SetDefaultAddressUseCase(repository: repository)
        self.tokenRepo = tokenRepo
               customerAccessToken = self.tokenRepo.loadToken()
        //customerAccessToken = "1dd921119342d6a204b65d6e4243d015"
//         todo eb2a sheel el satr ele foo2 w uncomment el satr ele fo2eeh, 3ashan ngeeb accesstoken kol client b3eno

    }

    func getAddresses() {
        guard let customerAccessToken else { return }
        getAddressUseCase.execute(customerAccessToken: customerAccessToken) { [weak self] addressResponse in
            self?.isLoading = false
            switch addressResponse {
            case let .success(myAddresses):
                self?.defaultAddress = myAddresses.defaultAddress
                self?.addresses = myAddresses.addresses
            case let .error(error):
                self?.errorMessage = error
            }
        }
    }


    func deleteAddress(_ address: Address) {
        guard let customerAccessToken else { return }

        deleteAddressUseCase.execute(customerAccessToken: customerAccessToken, addressId: address.id) { [weak self] addressOperationResponse in
            switch addressOperationResponse {
            case .success:
                self?.successMessage = "Address deleted successfully"
                self?.getAddresses()
            case let .errorMessage(errorMsg):
                self?.errorMessage = errorMsg
            case let .failure(error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func setDefaultAddress(_ address: Address) {
        guard let customerAccessToken else { return }

        setDefaultAddressUseCase.execute(customerAccessToken: customerAccessToken, addressId: address.id) { [weak self] addressOperationResponse in
            switch addressOperationResponse {
            case .success:
                self?.successMessage = "Default address set successfully"
                self?.getAddresses()
            case let .errorMessage(errorMsg):
                self?.errorMessage = errorMsg
            case let .failure(error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
}
