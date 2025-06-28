
import SwiftUI
import FirebaseAuth


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
            .disabled(Auth.auth().currentUser == nil)
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
            .sheet(isPresented: $showContactSheet) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contact Us")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    
                    Text("We’d love to hear from you! Whether you have questions, feedback, or collaboration opportunities, feel free to reach out.")
                        .font(.body)
                    
                    Group {
                        Label("teamshoppedin@gmail.com", systemImage: "envelope")
                            .onTapGesture {
                                openURL("mailto:teamshoppedin@gmail.com")
                            }
                        
                        Label("Basel Alasadi", systemImage: "link")
                            .onTapGesture {
                                openURL("https://www.linkedin.com/in/basel-alasadi/")
                            }
                        
                        Label("Omar Abdelaziz", systemImage: "link")
                            .onTapGesture {
                                openURL("www.linkedin.com/in/omarabdulaziz259")
                            }
                        
                        Label("Ayatullah Salah", systemImage: "link")
                            .onTapGesture {
                                openURL("https://www.linkedin.com/in/ayatullah-salah/")
                            }
                        
                        Label("github.com/team-shopped-in", systemImage: "link")
                            .onTapGesture {
                                openURL("https://github.com/team-shopped-in")
                            }
                    }
                    .foregroundColor(.blue)
                    .font(.callout)
                    
                    Spacer()
                    Button("Close") {
                        showContactSheet = false
                    }
                    .frame(maxWidth: .infinity)
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
            .sheet(isPresented: $showAboutSheet) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("About Us")
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                        Text("Shopped In is a modern m-commerce mobile application designed to enhance the online shopping experience with a fast, intuitive, and personalized interface. Our app allows users to explore curated product collections, manage their carts seamlessly, and complete purchases with ease using Cash on Delivery and Apple Pay.")
                        
                        Text("This project was developed with a focus on performance, functionality, and a clean user experience. It integrates the Shopify Storefront API using GraphQL, and follows clean architecture principles with MVVM for scalable development.")
                            .padding(.top, 8)
                        
                        Text("Team Members")
                            .font(.title2.bold())
                            .padding(.vertical)
                        
                        HStack {
                            Image("member_basel")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                            
                            Text("Basel Alasadi")
                        }
                        
                        HStack {
                            Image("member_omar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                            
                            Text("Omar Abdulaziz")
                        }
                        
                        HStack {
                            Image("member_aya")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                            
                            Text("Ayatullah Salah")
                        }
                        
                        Spacer()
                        Button("Close") {
                            showAboutSheet = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Settings")
        
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
