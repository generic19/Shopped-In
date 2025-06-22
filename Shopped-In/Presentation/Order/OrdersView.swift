//
//  OrdersView.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 21/06/2025.
//
import SwiftUI

struct OrdersView: View {
    @StateObject var viewModel: OrdersViewModel
    
    var body: some View {
        VStack {
            switch viewModel.ordersState {
                case .initial:
                    EmptyView()
                    
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    
                case .failure(let errorMessage):
                    Text(errorMessage)
                        .foregroundStyle(Color.red)
                        
                case .success(let orders):
                    if orders.isEmpty {
                        ZStack {
                            Text("No orders yet.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading) {
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemFill))
                            )
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                        }
                    }
            }
        }
        .navigationTitle("Your Orders")
        .onAppear {
            viewModel.loadOrders()
        }
    }
}
