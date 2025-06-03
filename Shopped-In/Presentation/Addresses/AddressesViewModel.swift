
import Foundation
import SwiftData

class AddressViewModel: ObservableObject {
    let getAddressUseCase: GetAddressesUseCase
    let getDefaultAddressUseCase: GetDefaultAddressUseCase
    let deleteAddressUseCase: DeleteAddressUseCase
    let setDefaultAddressUseCase: SetDefaultAddressUseCase
    let tokenRepo: TokenRepo
    let customerAccessToken: String?

    @Published var addresses: [Address] = []  {
        didSet{
            print("addresses : \(addresses)")
        }
    }
    @Published var defaultAddress: Address? {
        didSet{
            print(defaultAddress)
        }
    }
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading: Bool = true

    init(getAddressUseCase: GetAddressesUseCase,
         getDefaultAddressUseCase: GetDefaultAddressUseCase,
         deleteAddressUseCase: DeleteAddressUseCase,
         setDefaultAddressUseCase: SetDefaultAddressUseCase,
         tokenRepo: TokenRepo) {
        self.getAddressUseCase = getAddressUseCase
        self.getDefaultAddressUseCase = getDefaultAddressUseCase
        self.deleteAddressUseCase = deleteAddressUseCase
        self.setDefaultAddressUseCase = setDefaultAddressUseCase
        self.tokenRepo = tokenRepo
//        customerAccessToken = self.tokenRepo.loadToken()
        customerAccessToken = "1dd921119342d6a204b65d6e4243d015"
//         todo eb2a sheel el satr ele foo2 w uncomment el satr ele fo2eeh, 3ashan ngeeb accesstoken kol client b3eno
    }

    func fetchData() {
        getDefaultAddress { [weak self] in
            self?.getAddresses()
        }
    }

    func getAddresses() {
        guard let customerAccessToken else { return }
        getAddressUseCase.execute(customerAccessToken: customerAccessToken) { [weak self] addressResponse in
            self?.isLoading = false
            switch addressResponse {
            case let .success(myAddresses):
                self?.addresses = myAddresses
            case let .error(error):
                self?.errorMessage = error
            }
        }
    }

    func getDefaultAddress(completion: (() -> Void)? = nil) {
        guard let customerAccessToken else { return }
        getDefaultAddressUseCase.execute(customerAccessToken: customerAccessToken) { [weak self] addressResponse in

            switch addressResponse {
            case let .success(myAddresses):
                completion?()
                self?.defaultAddress = myAddresses.first
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
            case let .errorMessage(errorMsg):
                self?.errorMessage = errorMsg
            case let .failure(error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}
