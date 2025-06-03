
import SwiftUI

struct AddressFormView: View {
    @StateObject var viewModel: AddressFormViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Address Info")) {
                    TextField("Name", text: $viewModel.name)
                    TextField("Address 1", text: $viewModel.address1)
                    TextField("Address 2", text: $viewModel.address2)
                    TextField("City", text: $viewModel.city)
                    TextField("Country", text: $viewModel.country)
                    TextField("Phone", text: $viewModel.phone)
                    TextField("Latitude", text: $viewModel.latitude)
                    TextField("Longitude", text: $viewModel.longitude)
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
                        latitude: Double(viewModel.latitude),
                        longitude: Double(viewModel.longitude)
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
