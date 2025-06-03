//
//  AddressFormViewModel.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 01/06/2025.
//

import Combine

class AddressFormViewModel: ObservableObject {
    var address: Address?
    var isEditing: Bool { address != nil }

    var name: String = ""
    var address1: String = ""
    var address2: String = ""
    var city: String = ""
    var country: String = ""
    var phone: String = ""
    var longitude: String = ""
    var latitude: String = ""

    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var doWaiting: Bool = false


    let addAddressUseCase: AddAddressUseCase
    let updateAddressUseCase: UpdateAddressUseCase
    
    let tokenRepo: TokenRepo
    let customerAccessToken: String?


    init(addAddressUseCase: AddAddressUseCase,
         updateAddressUseCase: UpdateAddressUseCase,
         tokenRepo: TokenRepo,
         address: Address? = nil) {
        self.addAddressUseCase = addAddressUseCase
        self.updateAddressUseCase = updateAddressUseCase
        self.tokenRepo = tokenRepo
        //        customerAccessToken = self.tokenRepo.loadToken()
                customerAccessToken = "1dd921119342d6a204b65d6e4243d015"
        //todo eb2a sheel el satr ele foo2 w uncomment el satr ele fo2eeh, 3ashan ngeeb accesstoken kol client b3eno
        self.address = address
        if let address {
            name = address.name
            address1 = address.address1
            address2 = address.address2 ?? ""
            city = address.city
            country = address.country
            guard let long = address.longitude, let lat = address.latitude else { return }
            longitude = "\(long)"
            latitude = "\(lat)"
        }
    }

    func addAddress(_ myAddress: Address) {
        guard let customerAccessToken else {return}
        doWaiting = true
        addAddressUseCase.execute(forCustomerWithAccessToken: customerAccessToken, address: myAddress) { [weak self] addressOperationResult in
            switch addressOperationResult{
            case .success:
                self?.successMessage = "address added successfully"
            case let .errorMessage(errorMsg):
                self?.errorMessage = errorMsg
            case let .failure(error):
                self?.errorMessage = error.localizedDescription
            }
            self?.doWaiting = false
        }
    }

    func updateAddress(_ myAddress: Address) {
        guard let customerAccessToken, let address else {return}
        doWaiting = true
        updateAddressUseCase.execute(customerAccessToken: customerAccessToken, addressId: address.id, address: address) { [weak self] addressOperationResult in
            switch addressOperationResult{
            case .success:
                self?.successMessage = "address updated successfully"
            case let .errorMessage(errorMsg):
                self?.errorMessage = errorMsg
            case let .failure(error):
                self?.errorMessage = error.localizedDescription
            }
            self?.doWaiting = false


        }
    }
}
