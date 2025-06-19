
import CoreLocation
import MapKit
import SwiftUI

struct AddressFormView: View {
    @StateObject var viewModel: AddressFormViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var selectedCoordinates: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Address Info")) {
                    TextField("Name*", text: $viewModel.name)
                    TextField("Address 1*", text: $viewModel.address1)
                    TextField("Address 2", text: $viewModel.address2)
                    TextField("City*", text: $viewModel.city)
                    TextField("Country*", text: $viewModel.country)
                    TextField("Phone*", text: $viewModel.phone)
                }
                Section(header: Text("Coordinates")) {
                    Map(
                        coordinateRegion: $viewModel.mapRegion,
                        interactionModes: .all,
                        showsUserLocation: true,
                        annotationItems: viewModel.annotationItems
                    ) { item in
                        MapMarker(coordinate: item.coordinate, tint: .red)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let tapLocation = value.location
                                let mapFrame = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
                                let mapSize = CGSize(width: 300, height: 300)
                                let region = viewModel.mapRegion
                                let coordinates = convertTapToCoordinate(tapLocation, in: mapSize, region: region)
                                selectedCoordinates = coordinates
                                viewModel.fetchAddressDetails(for: coordinates)
                            }
                    )
                    .frame(height: 300)

                    Button("Use My Location") {
                        viewModel.requestUserLocation { coord in
                            selectedCoordinates = coord
                            viewModel.annotationItems = [AddressFormViewModel.MapPinItem(coordinate: coord)]
                            viewModel.mapRegion.center = coord
                        }
                    }
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                Button(action: {
                    let address = Address(
                        id: UUID().uuidString,
                        name: viewModel.name,
                        address1: viewModel.address1,
                        address2: viewModel.address2.isEmpty ? nil : viewModel.address2,
                        city: viewModel.city,
                        country: viewModel.country,
                        phone: viewModel.phone,
                    )
                    if viewModel.isEditing {
                        viewModel.updateAddress(address)
                    } else {
                        viewModel.addAddress(address)
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onChange(of: viewModel.successMessage) { _, newValue in
                if let newValue {
                    toastMessage = newValue
                    showToast = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showToast = false
                        viewModel.successMessage = nil
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedCoordinates) { _, newValue in
                guard let coord = newValue else { return }
                viewModel.fetchAddressDetails(for: coord)
            }

            if viewModel.doWaiting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
            }

            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .padding()
                        .background(Color.green.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                        .transition(.opacity)
                }
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

#Preview {
    let remote = AddressRemoteDataSourceImpl(service: BuyAPIService.shared)
    let repo = AddressRepositoryImpl(remote: remote)
    let tokenRepo = TokenRepoImpl()
    let viewModel = AddressFormViewModel(repo: repo, tokenRepo: tokenRepo)
    AddressFormView(viewModel: viewModel)
}

private func convertTapToCoordinate(_ tap: CGPoint, in mapSize: CGSize, region: MKCoordinateRegion) -> CLLocationCoordinate2D {
    let span = region.span
    let center = region.center

    let xPercent = tap.x / mapSize.width
    let yPercent = tap.y / mapSize.height

    let longitude = center.longitude - span.longitudeDelta / 2 + span.longitudeDelta * Double(xPercent)
    let latitude = center.latitude + span.latitudeDelta / 2 - span.latitudeDelta * Double(yPercent)

    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}
