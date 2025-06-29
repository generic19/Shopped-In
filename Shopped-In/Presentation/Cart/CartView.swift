//
//  CartView.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 13/06/2025.
//

import SwiftUI

struct CartView: View {
    @StateObject var viewModel: CartViewModel = DIContainer.resolve()
    @Environment(\.dismiss) var dismiss
    
    private let currencyConverter: CurrencyConverter = DIContainer.shared.resolve()
    @State private var currentExchangeRate: Double = 1
    @State private var currentCurrency: String = "EGP"
    
    @State private var showSummarySheet = false
    
    var body: some View {
        ZStack {
            if viewModel.errorMessage != nil || (viewModel.cart?.items.isEmpty ?? false) {
                VStack {
                    Image(systemName: "cart.badge.questionmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 256)
                        .foregroundStyle(.tertiary)
                    
                    Text(viewModel.errorMessage ?? CartViewModel.noProductsAddedErrorMsg).padding(32).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
            } else if let cart = viewModel.cart {
                VStack {
                    List {
                        ForEach(cart.items, id: \.id) { item in
                            CartItemRow(
                                item: item,
                                onAddQuantity: {
                                    viewModel.onAddQuantityTapped(lineItemId: $0.id)
                                },
                                
                                onMinusQuantity: {
                                    viewModel.onMinusQuantityTapped(lineItemId: $0.id)
                                },
                                onRemove: {
                                    viewModel.removeItem(lineItemId: $0.id)
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                    .buttonStyle(BorderlessButtonStyle())
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Discount code entry and feedback
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("Enter Discount Code", text: $viewModel.discountCode)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(cart.discount?.isApplicable ?? false)
                                    .foregroundColor((cart.discount?.isApplicable ?? false) ? .gray : .primary)
                                
                                if let clipboardText = UIPasteboard.general.string, !clipboardText.isEmpty, let isApplicable = viewModel.cart?.discount?.isApplicable, !isApplicable {
                                    Button(action: {
                                        viewModel.discountCode = clipboardText
                                    }) {
                                        Image(systemName: "doc.on.clipboard")
                                            .font(.title2)
                                            .foregroundStyle(.black)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .help("Paste from clipboard")
                                }
                                Button("Apply") {
                                    viewModel.applyDiscountCode(viewModel.discountCode)
                                }
                                .disabled(cart.discount?.isApplicable ?? false || viewModel.discountCode.isEmpty)
                            }
                            if !viewModel.discountFeedback.isEmpty {
                                Text(viewModel.discountFeedback)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            if cart.discount?.isApplicable ?? false {
                                HStack {
                                    if let fixedAmount = cart.discount?.fixedAmount {
                                        Text("Applied: \(Int(fixedAmount)) EGP discount")
                                            .foregroundColor(.green)
                                        
                                    } else if let percentage = cart.discount?.percentage {
                                        Text("Applied: \(Int(percentage))% off")
                                            .foregroundColor(.green)
                                    }
                                    Spacer()
                                    Button("Remove") {
                                        viewModel.removeDiscountCode()
                                    }
                                }
                            }
                        }
                        
                        Button("View Summary") {
                            showSummarySheet = true
                        }
                        .padding(.top, 6)
                        
                        Button("Place Order") {
                            viewModel.proceedToCheckout()
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Your Cart")
        .sheet(isPresented: $showSummarySheet) {
            VStack(spacing: 12) {
                Text("Summary")
                    .font(.title)
                Text("Subtotal: \(((viewModel.cart?.subtotal ?? 0.0) * currentExchangeRate), specifier: "%.2f") \(currentCurrency)")
                if let _ = viewModel.cart?.discount?.isApplicable,
                   let discountAmount = viewModel.cart?.discount?.actualDiscountAmount {
                    if discountAmount > 0 {
                        Text("Discount: -\((discountAmount * currentExchangeRate), specifier: "%.2f") \(currentCurrency)")
                    }
                }
                Text("Total: \(((viewModel.cart?.total ?? 0.0) * currentExchangeRate), specifier: "%.2f") \(currentCurrency)")
                    .font(.headline)
                Button("Close") {
                    showSummarySheet = false
                }
                .padding(.top)
            }
            .padding()
            .presentationDetents([.height(250)])
        }
        .onAppear {
            viewModel.loadCart()
            if (currencyConverter.usdExchangeRate != nil) && currencyConverter.getCurrency() == "USD" {
                currentCurrency = "USD"
                currentExchangeRate = currencyConverter.usdExchangeRate!
            }
        }
        .onChange(of: viewModel.toastMessage) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewModel.toastMessage = ""
            }
        }
        .navigationDestination(isPresented: $viewModel.showCheckout) {
            CheckoutView() {
                dismiss()
            }
        }
        
        if !viewModel.toastMessage.isEmpty {
            VStack {
                ToastView(message: viewModel.toastMessage, backgroundColor: .green.opacity(85))
            }
        }
        
    }
}

struct CartItemRow: View {
    private let currencyConverter: CurrencyConverter = DIContainer.shared.resolve()
    @State private var currentExchangeRate: Double = 1
    @State private var currentCurrency: String = "EGP"
    
    let item: CartItem
    let onAddQuantity: (CartItem) -> Void
    let onMinusQuantity: (CartItem) -> Void
    
    let onRemove: (CartItem) -> Void
    
    let colorHexMap = [
        "burgandy": "#FF660033",
        "red": "#FFFF0000",
        "white": "#FFFFFFFF",
        "blue": "#FF0000FF",
        "black": "#FF000000",
        "gray": "#FF808080",
        "light_brown": "#FFA52A2A",
        "beige": "#FFF5F5DC",
        "yellow": "#FFFFFF00",
    ]
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: item.imageURL) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 80)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).bold()
                HStack(spacing: 8) {
                    let sizeThenColor = item.variantTitle.split(separator: " / ")
                    if let size = sizeThenColor.first, let color = sizeThenColor.last {
                        Text("Size: \(size)")
                        Text("Color:")
                        Circle()
                            .fill(Color(hex: colorHexMap[String(color)] ?? "FFFFFFFF"))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.clear, lineWidth: 3)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                Text("Unit Price: \(item.price * currentExchangeRate, specifier: "%.2f") \(currentCurrency)")
                Text("Total: \(item.price * currentExchangeRate * Double(item.quantity), specifier: "%.2f") \(currentCurrency)")
                
                HStack {
                    Button(action: { onMinusQuantity(item) }) {
                        Image(systemName: "minus.circle")
                    }.disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)").padding(.horizontal, 8)
                    
                    Button(action: { onAddQuantity(item) }) {
                        Image(systemName: "plus.circle")
                    }.disabled(item.quantity == item.availableQuantity)
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .alert("Remove Item", isPresented: $showDeleteAlert) {
                        Button("Yes", role: .destructive) {
                            onRemove(item)
                        }
                        Button("No", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to remove \(item.title) from the cart?")
                    }
                }
            }
        }.padding(.vertical, 8)
            .onAppear {
                if (currencyConverter.usdExchangeRate != nil) && currencyConverter.getCurrency() == "USD" {
                    currentCurrency = "USD"
                    currentExchangeRate = currencyConverter.usdExchangeRate!
                }
            }
    }
}
