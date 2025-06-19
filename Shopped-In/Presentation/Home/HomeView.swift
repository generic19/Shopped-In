import SwiftUI

enum HomeRoute: Route {
    case home
    case brandProducts(Brand)
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                BrandsView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Shopped In")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .kerning(-0.8)
                        .opacity(0.75)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(in: RoundedRectangle(cornerRadius: 3))
                        .backgroundStyle(.background)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        CheckoutView()
                    } label: {
                        Image(systemName: "cart")
                    }

                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}
