
import SwiftUI
import AVKit

struct SplashView: View {
    @State private var isVideoFinished = false
    
    private let player: AVPlayer = {
        let url = Bundle.main.url(forResource: "splash", withExtension: "mp4")!
        return AVPlayer(url: url)
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            
                        }
                    }
                    .onDisappear {
                        player.pause()
                        NotificationCenter.default.removeObserver(self)
                    }
            }
        }
    }

    func playVideo() {
        try! AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
        try! AVAudioSession.sharedInstance().setActive(true)
        
        player.play()
    }
}
