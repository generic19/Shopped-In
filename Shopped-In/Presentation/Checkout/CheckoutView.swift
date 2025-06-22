
import SwiftUI

struct CheckoutView: View {
    let onComplete: () -> Void
    
    @StateObject var viewModel: CheckoutViewModel = DIContainer.resolve()
    @State var isAddAddressPresented = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if let loadingMessage: String = viewModel.loadingMessage {
                ProgressView {
                    Text(loadingMessage)
                }
            } else if let errorMessage: String = viewModel.errorMessage {
                VStack {
                    Spacer()
                    
                    Text(errorMessage)
                        .foregroundStyle(.red)
                    
                    Spacer()
                    
                    if let errorActions = viewModel.errorActions, !errorActions.isEmpty {
                        HStack(spacing: 8) {
                            Button(action: errorActions[0].action) {
                                Text(errorActions[0].title)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                            ForEach(errorActions[1..<errorActions.count], id: \.title) { errorAction in
                                Button(action: errorAction.action) {
                                    Text(errorAction.title)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            } else if let cart: Cart = viewModel.cart {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Order Items")
                            .font(.title2.weight(.bold))
                            .padding(.bottom, 16)
                        
                        VStack(spacing: 12) {
                            ForEach(cart.items, id: \.id) { (item: CartItem) in
                                HStack(spacing: 12) {
                                    AsyncImage(url: item.imageURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(Color(.tertiarySystemFill))
                                            .aspectRatio(contentMode: .fill)
                                            .scaledToFit()
                                    }
                                    
                                    LazyVStack(alignment: .leading, spacing: 0) {
                                        Spacer()
                                        
                                        Text(item.title)
                                            .font(.callout)
                                            .lineLimit(1)
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text("Qty:")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.secondary)
                                            
                                            Text("\(item.quantity)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            
                                            Spacer()
                                            
                                            Text(String(format: "EGP %.2f", item.price))
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Divider()
                                            .padding(.top, 2)
                                            .padding(.trailing, -4)
                                        
                                        Spacer()
                                    }
                                }
                                .frame(height: 36, alignment: .leading)
                            }
                        }
                        .padding(.trailing, 4)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemFill))
                        )
                        
                        Text("Shipping Address")
                            .font(.title2.weight(.bold))
                            .padding(.top, 32)
                            .padding(.bottom, 16)
                        
                        Button {
                            self.isAddAddressPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("New Shipping Address")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemFill))
                            }
                        }
                        .padding(.bottom, 8)
                        
                        if let addresses: [Address] = viewModel.addresses {
                            LazyVStack(alignment: .leading) {
                                ForEach(addresses, id: \.id) { (address: Address) in
                                    Button {
                                        viewModel.selectedAddress = address
                                    } label: {
                                        HStack(alignment: .top) {
                                            Image(
                                                systemName: address.id == viewModel.selectedAddress?.id
                                                ? "checkmark.circle.fill"
                                                : "circle"
                                            )
                                            .padding()
                                            
                                            VStack(alignment: .leading) {
                                                Text(address.name)
                                                    .font(.callout)
                                                
                                                Text(address.address1)
                                                    .font(.caption)
                                                
                                                if let address2 = address.address2 {
                                                    Text(address2)
                                                        .font(.caption)
                                                }
                                                
                                                Text("\(address.city), \(address.country). Phone: \(address.phone)")
                                                    .font(.caption)
                                                
                                                if address.id != addresses.last?.id {
                                                    Divider()
                                                }
                                            }
                                            .tint(Color.primary)
                                            .scaledToFill()
                                        }
                                        .scaledToFill()
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemFill))
                            }
                        }
                        
                        Text("Payment Method")
                            .font(.title2.weight(.bold))
                            .padding(.top, 32)
                            .padding(.bottom, 16)
                        
                        VStack(alignment: .leading) {
                            ForEach(PaymentMethod.allCases, id: \.self) { (paymentMethod: PaymentMethod) in
                                Button {
                                    viewModel.selectedPaymentMethod = paymentMethod
                                } label: {
                                    HStack(alignment: .center) {
                                        Image(
                                            systemName: paymentMethod == viewModel.selectedPaymentMethod
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                        )
                                        .padding(4)
                                        .scaledToFit()
                                        
                                        Text(paymentMethod.title)
                                            .tint(.primary)
                                        
                                        Spacer()
                                    }
                                }
                                
                                if paymentMethod != PaymentMethod.allCases.last {
                                    Divider()
                                        .padding(.leading, 30)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal, -16)
                            
                            Group {
                                HStack {
                                    Text("Subtotal")
                                    Spacer()
                                    Text(String(format: "EGP %.2f", cart.subtotal))
                                }
                                
                                if let discountAmount = cart.discountAmount {
                                    HStack {
                                        Text("Discount")
                                        Spacer()
                                        Text(String(format: "EGP %.2f", -discountAmount))
                                    }
                                }
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            
                            HStack {
                                Text("Total")
                                    .font(.callout.bold())
                                Spacer()
                                Text(String(format: "EGP %.2f", cart.total))
                                    .font(.callout.bold())
                            }
                            
                        }
                        .padding()
                        .padding(.bottom, -8)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemFill))
                        }
                        
                        switch viewModel.selectedPaymentMethod {
                            case .applePay:
                                Button {
                                    viewModel.checkoutWithApplePay()
                                } label: {
                                    Text("Pay with Pay")
                                        .font(.title3)
                                        .frame(maxWidth: .infinity)
                                }
                                .tint(Color.primary)
                                .disabled(viewModel.isCheckoutDisabled)
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .padding(.vertical)
                                
                            default:
                                Button {
                                    viewModel.completeCheckout()
                                } label: {
                                    Text("Complete Order")
                                        .font(.body)
                                        .frame(maxWidth: .infinity)
                                }
                                .disabled(viewModel.isCheckoutDisabled)
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .padding(.vertical)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isAddAddressPresented, content: {
            AddressFormView(viewModel: DIContainer.shared.resolve())
                .onDisappear {
                    viewModel.loadAddresses()
                }
        })
        .alert("Order Placed", isPresented: $viewModel.showCheckoutSuccess) {
            Button("Okay") {
                viewModel.clearCart()
                dismiss()
                onComplete()
            }
        } message: {
            Text("Thank you for shopping with us!")
        }
        .onAppear {
            viewModel.load()
        }
    }
}
