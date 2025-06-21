import SwiftUI

struct RecentOrdersView: View {
    @StateObject var viewModel: OrdersViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Your Orders")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("See more") {}
            }
            
            switch viewModel.recentOrdersState {
                case .initial:
                    EmptyView()
                    
                case .loading:
                    ProgressView("Loading recent orders...")
                    
                case .success(let orders):
                    let orderDMs = orders.map({ $0.toDisplayModel() })
                    
                    VStack(alignment: .leading) {
                        ForEach(orderDMs, id: \.id) { order in
                            NavigationLink {
                                EmptyView()
                            } label: {
                                HStack(spacing: 16) {
                                    AsyncImage(url: order.imageURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(width: 70, height: 70)
                                            .foregroundStyle(Color.gray)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(order.title)
                                            .lineLimit(2)
                                            .font(.callout)
                                        
                                        Text(order.totalAmount)
                                            .font(.callout.weight(.medium))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .tint(.blue)
                                        .padding(.trailing, 8)
                                }
                            }
                            .tint(.black)
                            
                            Divider()
                                .padding(.top, -2)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemFill))
                    )
                    
                case .failure(let errorMessage):
                    Text(errorMessage)
                        .foregroundStyle(Color.red)
            }
        }
        .padding(.vertical, 16)
        .onAppear {
            viewModel.loadRecentOrders()
        }
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

private struct Preview: View {
    @State var orderDMs = orders.map({ $0.toDisplayModel() })
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(orderDMs, id: \.id) { order in
                NavigationLink {
                    EmptyView()
                } label: {
                    HStack(spacing: 16) {
                        AsyncImage(url: order.imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 70, height: 70)
                                .foregroundStyle(Color.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(order.title)
                                .lineLimit(2)
                                .font(.callout)
                            
                            Text(order.totalAmount)
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .tint(.blue)
                            .padding(.trailing, 8)
                    }
                }
                .tint(.black)
                
                Divider()
                    .padding(.top, -2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemFill))
        )
    }
}

#Preview {
    NavigationStack {
        Preview()
    }
}

