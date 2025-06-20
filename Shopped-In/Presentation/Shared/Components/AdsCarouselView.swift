import SwiftUI

struct AdsCarouselView: View {
    let images: [String] // image names or URLs
    let onTap: (Int) -> Void
    
    @State private var currentIndex = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(images.indices, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .onTapGesture {
                                onTap(index)
                            }
                    }
                }
                .frame(width: geometry.size.width * CGFloat(images.count), alignment: .leading)
                .offset(x: -CGFloat(currentIndex) * geometry.size.width + dragOffset)
                .animation(.easeInOut, value: currentIndex)
                .gesture(
                    DragGesture()
                        .updating($dragOffset, body: { value, state, _ in
                            state = value.translation.width
                        })
                        .onEnded { value in
                            let threshold = geometry.size.width / 2
                            var newIndex = currentIndex
                            if value.translation.width < -threshold {
                                newIndex = (currentIndex + 1) % images.count
                            } else if value.translation.width > threshold {
                                newIndex = (currentIndex - 1 + images.count) % images.count
                            }
                            currentIndex = newIndex
                        }
                )
                .onReceive(timer) { _ in
                    currentIndex = (currentIndex + 1) % images.count
                }
            }
            .frame(height: 280)

            HStack(spacing: 8) {
                ForEach(images.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
        }
    }
}

#Preview{
    AdsCarouselView(images: ["Discount20Percent", "Discount100EGP"]) { index in
        if index == 0 {
            UIPasteboard.general.string = "FREE200";
        } else if index == 1 {
            UIPasteboard.general.string = "SHOP100";
        }
    }
}
