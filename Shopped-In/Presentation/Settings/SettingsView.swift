
import SwiftUI

struct SettingsView: View {
    @State private var showCurrencyActionSheet = false
    @State private var selectedCurrency: String? = nil
    @State private var showContactSheet = false
    @State private var showAboutSheet = false

    var body: some View {
        List {
            NavigationLink(destination: AddressesView(viewModel: DIContainer.shared.resolve())) {
                HStack {
                    Image(systemName: "house")
                        .foregroundStyle(.blue)
                    Text("Address")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.vertical)

            Button {
                showCurrencyActionSheet = true
            } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                    Text("Currency")
                        .font(.title2)
                }
                .padding(.vertical)
            }
            .padding(.vertical)
            .confirmationDialog("Choose Currency", isPresented: $showCurrencyActionSheet, titleVisibility: .visible) {
                Button("USD") {
                    selectedCurrency = "USD"
                    CurrencyPreference.save(selectedCurrency ?? "USD")
                }
                
                Button("EGP") {
                    selectedCurrency = "EGP"
                    CurrencyPreference.save(selectedCurrency ?? "EGP")
                }
            }

            Button {
                showContactSheet = true
            } label: {
                HStack {
                    Image(systemName: "envelope")
                    Text("Contact Us")
                        .font(.title2)
                }
                .padding(.vertical)
            }
            .padding(.vertical)
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

            Button {
                showAboutSheet = true
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                    Text("About Us")
                        .font(.title2)
                }
                .padding(.vertical)
            }
            .padding(.vertical)
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
