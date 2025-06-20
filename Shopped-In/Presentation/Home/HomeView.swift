import SwiftUI

enum HomeRoute: Route {
    case home
    case brandProducts(Brand)
}

struct HomeView: View {
    @State var showCopyMessage: Bool = false
    @ObservedObject var brandsViewModel: BrandsViewModel = DIContainer.shared.resolve()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        AdsCarouselView(images: ["Discount20Percent", "Discount100EGP"]) { index in
                            showCopyMessage = true
                            if index == 0 {
                                UIPasteboard.general.string = "FREE20"
                            } else if index == 1 {
                                UIPasteboard.general.string = "SHOP100"
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopyMessage = false
                            }
                        }

                        BrandsView(viewModel: brandsViewModel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                if showCopyMessage {
                    ToastView(message: "Discount Code Copied to Clipboard", backgroundColor: .green)
                }
            }
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
