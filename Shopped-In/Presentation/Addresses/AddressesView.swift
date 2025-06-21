import SwiftUI

struct AddressesView: View {
    @ObservedObject var viewModel: AddressViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showAddressForm = false
    @State private var selectedAddress: Address?

    init(viewModel: AddressViewModel) {
        self.viewModel = viewModel
    }

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
                            .onTapGesture(perform: {
                                selectedAddress = address
                                showAddressForm = true
                            })

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
            .toolbar(content: {
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
            })
            .onAppear {
                viewModel.getAddresses()
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
                AddressFormView(viewModel: {
                    let formViewModel: AddressFormViewModel = DIContainer.shared.resolve()
                    formViewModel.setInitialAddress(selectedAddress)
                    return formViewModel
                }())
                .onDisappear {
                    viewModel.getAddresses()
                    selectedAddress = nil
                }
            }

            if showToast {
                VStack {
                    ToastView(message: toastMessage, backgroundColor: .green.opacity(85))
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
                Text(address.name)
                    .font(.headline)
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
