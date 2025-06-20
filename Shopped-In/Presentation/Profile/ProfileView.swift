import SwiftUI

struct ProfileView: View {
    var body: some View {
        CartView(viewModel: DIContainer.shared.resolve())
//        Text("profile tab")
    }
}
