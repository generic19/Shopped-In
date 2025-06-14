
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
        self.customerAccessToken = self.tokenRepo.loadToken()
        print(customerAccessToken ?? "no access token saved")
        guard customerAccessToken != nil else {
            self.isLoading = false
            self.errorMessage = "No customer access token found"
            return }

    }

    func getAddresses() {
        errorMessage = nil
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
