
import SwiftUI

struct SettingsView: View {
    @State private var showCurrencyActionSheet = false
    @State private var selectedCurrency: String? = nil
    @State private var showContactSheet = false
    @State private var showAboutSheet = false

    var body: some View {
        List {
            NavigationLink(destination: AddressesView(viewModel: AddressViewModel(repository: AddressRepositoryImpl(remote: AddressRemoteDataSourceImpl(service: BuyAPIService.shared)), tokenRepo: TokenRepoImpl()))) {
                Text("Address")
            }

            Button("Currency") {
                showCurrencyActionSheet = true
            }
            .confirmationDialog("Choose Currency", isPresented: $showCurrencyActionSheet, titleVisibility: .visible) {
                Button("USD") {
                    selectedCurrency = "USD"
                    // Perform USD-specific actions here
                }
                Button("EGP") {
                    selectedCurrency = "EGP"
                    // Perform EGP-specific actions here
                }
            }

            Button("Contact Us") {
                showContactSheet = true
            }
            .sheet(isPresented: $showContactSheet) {
                VStack {
                    Text("Contact Us")
                        .font(.title)
                        .padding()
                    Text("You can reach us at support@example.com.")
                    Spacer()
                    Button("Close") {
                        showContactSheet = false
                    }
                    .padding()
                }
                .padding()
            }

            Button("About Us") {
                showAboutSheet = true
            }
            .sheet(isPresented: $showAboutSheet) {
                VStack {
                    Text("About Us")
                        .font(.title)
                        .padding()
                    Text("We are a leading shopping app helping people find and buy what they love.")
                    Spacer()
                    Button("Close") {
                        showAboutSheet = false
                    }
                    .padding()
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
    }
}
