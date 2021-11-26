import SwiftUI
import Combine
import AVFoundation

class MainViewModel: ObservableObject {
    @Published var value1: Float = 0.5
    @Published var value2: Float = 0.4
}

class MainViewModel2: ObservableObject {
    @Published var currentPage: UUID
    @Published var progress: Float

    private var timer: Timer?
    private let player: AVPlayer

    init(currentPage: UUID) {
        self.currentPage = currentPage
        self.progress = 0
        self.player = AVPlayer(url: Bundle(for: MainViewModel2.self).url(forResource: "example_sound", withExtension: "wav")!)

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(seconds: 0.05, preferredTimescale: timeScale)
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            self.handlePlaybackTimeChange(time: time, player: self.player)
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.player.play()
        }
    }

    func handlePlaybackTimeChange(time: CMTime, player: AVPlayer) {
        DispatchQueue.main.async {
            self.progress = Float(time.seconds) / 30.0
        }
    }
}

@main
struct TestBindingsApp: App {
    static var pages = (1...10).map { Content(name: String($0)) }
    @ObservedObject var mainViewModel = MainViewModel()
    @ObservedObject var mainViewModel2: MainViewModel2 = {
        MainViewModel2(currentPage: TestBindingsApp.pages.first!.id)
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(viewModel: ViewModel(
                    pages: TestBindingsApp.pages,
                    progress: $mainViewModel2.progress,
                    currentPage: $mainViewModel2.currentPage))
                ContentView2()
            }
        }
    }
}
