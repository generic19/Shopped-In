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
        }
    }
}
