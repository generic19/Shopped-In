//
//  OrderView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 21/06/2025.
//
import SwiftUI

struct OrderView: View {
    let order: Order
    
    var body: some View {
        Group {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 8) {
                        ForEach(order.items, id: \.variantID) { (item: Order.Item) in
                            HStack(spacing: 12) {
                                AsyncImage(url: item.image) { image in
                                    image
                                        .resizable()
                                        .frame(width: 70, height: 70)
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundStyle(Color(.tertiarySystemFill))
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFit()
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(item.productTitle)
                                        .font(.body)
                                        .lineLimit(1)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("Unit Price")
                                            .font(.callout.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                        
                                        let quantity = Int((item.totalPrice.value / item.unitPrice.value).rounded())
                                        
                                        if quantity != 1 {
                                            Text("(\(quantity)x)")
                                                .font(.callout.weight(.semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Text(String(format: "\(item.unitPrice.currency.rawValue) %.2f", item.unitPrice.value))
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("Total")
                                            .font(.callout.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(String(format: "\(item.totalPrice.currency.rawValue) %.2f", item.totalPrice.value))
                                            .font(.callout.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                    .padding(.trailing, 4)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemFill))
                    )
                    
                    Text("Payment Details")
                        .font(.title2.weight(.bold))
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                    
                    Group {
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text(String(format: "\(order.subtotal.currency.rawValue) %.2f", order.subtotal.value))
                        }
                        .padding(.bottom, 4)
                        
                        if order.discount.value != 0 {
                            HStack {
                                Text("Discount (\(order.discountCodes.joined(separator: ", ")))")
                                Spacer()
                                Text(String(format: "\(order.discount.currency.rawValue) %.2f", -order.discount.value))
                            }
                            .padding(.bottom, 4)
                        }
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(String(format: "\(order.total.currency.rawValue) %.2f", order.total.value))
                    }
                    .font(.headline.bold())
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Past Order")
    }
}

private let items: [Order.Item] = [
    Order.Item(productID: "1", variantID: "1", productTitle: "NIKE SHOES", variantTitle: "White / 42", unitPrice: 1200.asAmount(.EGP), totalPrice: 2400.asAmount(.EGP), image: URL(string: "https://cdn.shopify.com/s/files/1/0727/3997/9300/files/product_1_image1.jpg?v=1748176753")),
    Order.Item(productID: "2", variantID: "1", productTitle: "ADIDAS SHOES", variantTitle: "White / 42", unitPrice: 1200.asAmount(.EGP), totalPrice: 2400.asAmount(.EGP), image: URL(string: "https://cdn.shopify.com/s/files/1/0727/3997/9300/files/product_1_image1.jpg?v=1748176753")),
    Order.Item(productID: "3", variantID: "1", productTitle: "CONVERSE SHOES", variantTitle: "White / 42", unitPrice: 1200.asAmount(.EGP), totalPrice: 2400.asAmount(.EGP), image: URL(string: "https://cdn.shopify.com/s/files/1/0727/3997/9300/files/product_1_image1.jpg?v=1748176753")),
]

private let orders: [Order] = [
    Order(id: "1", items: items, discountCodes: ["FREE20"], subtotal: 7200.asAmount(.EGP), discount: 170.asAmount(.EGP), total: 7030.asAmount(.EGP)),
    Order(id: "2", items: items, discountCodes: ["FREE20"], subtotal: 7200.asAmount(.EGP), discount: 170.asAmount(.EGP), total: 7030.asAmount(.EGP)),
    Order(id: "3", items: items, discountCodes: ["FREE20"], subtotal: 7200.asAmount(.EGP), discount: 170.asAmount(.EGP), total: 7030.asAmount(.EGP)),
]

#Preview {
    NavigationStack {
        OrderView(order: orders[0])
    }
}

