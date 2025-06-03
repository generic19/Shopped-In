
import SwiftUI

struct AddressesView: View {
    @StateObject var viewModel: AddressViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showAddressForm = false

    
    var body: some View {
        ZStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading addresses...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if !viewModel.addresses.isEmpty {
                    List(viewModel.addresses) { address in
                        let isDefault = address.id == viewModel.defaultAddress?.id
                        AddressCell(address: address, isDefault: isDefault)
                        
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteAddress(address)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                if address.id != viewModel.defaultAddress?.id {
                                    Button {
                                        viewModel.setDefaultAddress(address)
                                    } label: {
                                        Label("Make Default", systemImage: "star")
                                    }
                                    .tint(.yellow)
                                }
                            }
                    }
                } else {
                    Text("No addresses found.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Addresses")
                        .font(.headline)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddressForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .onChange(of: viewModel.successMessage) { _, newValue in
                guard let newValue else { return }
                toastMessage = newValue
                showToast = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showToast = false
                    viewModel.successMessage = nil
                }
            }

            .sheet(isPresented: $showAddressForm) {
                let apiService = APIService.shared
                let remote = AddressRemoteDataSourceImpl(service: apiService)
                let repo = AddressRepositoryImpl(remote: remote)
                let addAddressUseCase = AddAddressUseCase(repository: repo)
                let updateAddressUseCase = UpdateAddressUseCase(repository: repo)

                let addressFormViewModel = AddressFormViewModel(
                    addAddressUseCase: addAddressUseCase,
                    updateAddressUseCase: updateAddressUseCase,
                    tokenRepo: viewModel.tokenRepo,
                    address: nil
                )
                AddressFormView(viewModel: addressFormViewModel)
            }

            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .padding()
                        .background(Color.green.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showToast)
                }
            }
        }
    }
}

struct AddressCell: View {
    let address: Address
    let isDefault: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(address.address1)
                    .font(.headline)
                if let address2 = address.address2 {
                    Text(address2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("\(address.city), \(address.country)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Phone: \(address.phone)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isDefault {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
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
}
