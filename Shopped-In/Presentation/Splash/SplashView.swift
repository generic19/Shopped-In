
import SwiftUI
import AVKit
import Combine

struct SplashView: View {
    @EnvironmentObject private var appSwitch: AppSwitch
    @State private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: SplashViewModel = DIContainer.shared.resolve()
    
    private let player: AVPlayer = {
        let url = Bundle.main.url(forResource: "splash", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        return player
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        viewModel.$destination.sink { destination in
                            if let destination {
                                appSwitch.switchTo(destination)
                            }
                        }.store(in: &cancellables)
                        
                        viewModel.splashStarted()
                        addVideoObserver()
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                        removeVideoObserver()
                    }
            }
        }
    }

    private func playVideo() {
        try! AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
        try! AVAudioSession.sharedInstance().setActive(true)
        
        player.play()
    }
    
    private func addVideoObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            viewModel.splashEnded()
        }
    }
    
    private func removeVideoObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
