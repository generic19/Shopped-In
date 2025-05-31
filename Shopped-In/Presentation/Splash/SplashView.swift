
import SwiftUI
import AVKit

struct SplashView: View {
    @EnvironmentObject private var appSwitch: AppSwitch
    
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
            appSwitch.switchTo(.onboarding)
        }
    }
    
    private func removeVideoObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
