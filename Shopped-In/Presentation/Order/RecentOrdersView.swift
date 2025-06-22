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
                NavigationLink {
                    OrdersView(viewModel: DIContainer.resolve())
                } label: {
                    Text("See more")
                }
            }
            
            switch viewModel.recentOrdersState {
                case .initial:
                    EmptyView()
                    
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 16)
                        
                case .success(let orders):
                    VStack(alignment: .leading) {
                        if orders.isEmpty {
                            HStack {
                                Spacer()
                                
                                Text("No orders yet.")
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                        } else {
                            ForEach(orders, id: \.id) { (order: Order) in
                                let orderDM = order.toDisplayModel()
                                
                                NavigationLink {
                                    OrderView(order: order)
                                } label: {
                                    HStack(spacing: 16) {
                                        AsyncImage(url: orderDM.imageURL) { image in
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
                                            Text(orderDM.title)
                                                .font(.callout)
                                                .multilineTextAlignment(.leading)
                                                .lineSpacing(-2)
                                                .lineLimit(2)
                                            
                                            Text(orderDM.totalAmount)
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
