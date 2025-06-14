//
//  AddressFormViewModel.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 01/06/2025.
//

import Combine
import CoreLocation
import MapKit

class AddressFormViewModel: ObservableObject {
    var address: Address?
    var isEditing: Bool { address != nil }

    var name: String = ""
    var address1: String = ""
    var address2: String = ""
    var city: String = ""
    var country: String = ""
    var phone: String = ""

    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var doWaiting: Bool = false

    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 26.8206, longitude: 30.8025),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @Published var annotationItems: [MapPinItem] = []

    struct MapPinItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    let addAddressUseCase: AddAddressUseCase
    let updateAddressUseCase: UpdateAddressUseCase

    let tokenRepo: TokenRepo
    let customerAccessToken: String?

    private var locationDelegate = LocationManagerDelegate()
    private var locationManager: CLLocationManager?

    init(repo: AddressRepository, tokenRepo: TokenRepo, address: Address? = nil) {
        addAddressUseCase = AddAddressUseCase(repository: repo)
        updateAddressUseCase = UpdateAddressUseCase(repository: repo)
        self.tokenRepo = tokenRepo
        customerAccessToken = self.tokenRepo.loadToken()
        self.address = address
        if let address {
            name = address.name
            address1 = address.address1
            address2 = address.address2 ?? ""
            city = address.city
            country = address.country
            phone = address.phone
        }
    }

    func addAddress(_ myAddress: Address) {
        guard let customerAccessToken else { return }

        if AddressValidator.validate(myAddress) {
            if AddressValidator.validateCountry(myAddress.country) {

            doWaiting = true
                addAddressUseCase.execute(forCustomerWithAccessToken: customerAccessToken, address: myAddress) { [weak self] addressOperationResult in
                    switch addressOperationResult {
                    case .success:
                        self?.successMessage = "address added successfully"
                    case let .errorMessage(errorMsg):
                        self?.errorMessage = errorMsg
                    case let .failure(error):
                        self?.errorMessage = error.localizedDescription
                    }
                    self?.doWaiting = false
                }
            } else {
                errorMessage = "we can't deliver outside Egypt"
            }
        } else {
            errorMessage = "please provide all required cells"
        }
    }

    func updateAddress(_ myAddress: Address) {
        guard let customerAccessToken, let address else { return }
        if AddressValidator.validate(myAddress) {
            if AddressValidator.validateCountry(myAddress.country) {
                doWaiting = true
                updateAddressUseCase.execute(customerAccessToken: customerAccessToken, addressId: address.id, address: myAddress) { [weak self] addressOperationResult in
                    switch addressOperationResult {
                    case .success:
                        self?.successMessage = "address updated successfully"
                    case let .errorMessage(errorMsg):
                        self?.errorMessage = errorMsg
                    case let .failure(error):
                        self?.errorMessage = error.localizedDescription
                    }
                    self?.doWaiting = false
                }
            } else {
                errorMessage = "we can't deliver outside Egypt"
            }
        } else {
            errorMessage = "please provide all required cells"
        }
    }

    func requestUserLocation(completion: ((CLLocationCoordinate2D) -> Void)? = nil) {
        let manager = CLLocationManager()
        locationManager = manager
        manager.delegate = locationDelegate
        locationDelegate.onLocationFix = { [weak self] coord in
            self?.mapRegion.center = coord
            self?.annotationItems = [MapPinItem(coordinate: coord)]
            self?.fetchAddressDetails(for: coord)
            completion?(coord)
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            errorMessage = "Location access denied. Please enable it in Settings."
        }
    }

    func fetchAddressDetails(for coord: CLLocationCoordinate2D) {
        annotationItems = [MapPinItem(coordinate: coord)]
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, error == nil else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch address details."
                }
                return
            }

            DispatchQueue.main.async {
                self.city = placemark.administrativeArea ?? ""
                self.country = placemark.country ?? ""
                self.address1 = placemark.name ?? ""
            }
        }
    }

    class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
        var onLocationFix: ((CLLocationCoordinate2D) -> Void)?

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let coord = locations.last?.coordinate {
                onLocationFix?(coord)
                manager.stopUpdatingLocation()
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}

struct AddressValidator {
    static func validate(_ address: Address) -> Bool {
        return !address.name.trimmingCharacters(in: .whitespaces).isEmpty &&
            !address.address1.trimmingCharacters(in: .whitespaces).isEmpty &&
            !address.city.trimmingCharacters(in: .whitespaces).isEmpty &&
            !address.country.trimmingCharacters(in: .whitespaces).isEmpty &&
            !address.phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static func validateCountry(_ country: String) -> Bool {
        return country.lowercased() == "eg" || country.lowercased() == "egypt"
    }
}
