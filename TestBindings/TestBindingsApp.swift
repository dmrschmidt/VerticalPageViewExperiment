import SwiftUI
import Combine
import AVFoundation

class MainViewModel: ObservableObject {
    @Published var value1: Float = 0.5
    @Published var value2: Float = 0.4
}

class MainViewModel2: ObservableObject {
    @Published var currentPage: UUID
    var app: TestBindingsApp?
    var pages: [Content] {
        TestBindingsApp.pages
    }

    init(currentPage: UUID) {
        self.currentPage = currentPage
    }
}

class ProgressViewModel: ObservableObject {
    @Published var progress: Float = 0

    private let player: AVPlayer

    init() {
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
    @ObservedObject var progressViewModel = ProgressViewModel()

    init() {
        mainViewModel2.app = self
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(
                    pageViewModel: mainViewModel2,
                    progressViewModel: progressViewModel
                )
                ContentView2()
            }
        }
    }
}
