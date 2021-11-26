import SwiftUI
import Combine
import AVFoundation

class PageViewModel: ObservableObject {
    static var pages = (1...10).map { Content(name: String($0)) }

    @Published var currentPage: UUID

    var pages: [Content] {
        PageViewModel.pages
    }

    init(currentPage: UUID) {
        self.currentPage = currentPage
    }
}

class ProgressViewModel: ObservableObject {
    @Published var progress: Float = 0

    private let player: AVPlayer

    init() {
        self.player = AVPlayer(url: Bundle(for: Self.self).url(forResource: "example_sound", withExtension: "wav")!)
        startPlayerAndProgressObservations()
    }

    func startPlayerAndProgressObservations() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(seconds: 0.05, preferredTimescale: timeScale)
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            self.handlePlaybackTimeChange(time: time, player: self.player)
        }

        self.player.play()
    }

    func handlePlaybackTimeChange(time: CMTime, player: AVPlayer) {
        DispatchQueue.main.async {
            self.progress = Float(time.seconds) / 30.0
        }
    }
}

@main
struct TestBindingsApp: App {
    @ObservedObject var pageViewModel: PageViewModel = {
        PageViewModel(currentPage: PageViewModel.pages.first!.id)
    }()

    @ObservedObject var progressViewModel = ProgressViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                VerticalPageExperimentView(
                    pageViewModel: pageViewModel,
                    progressViewModel: progressViewModel
                )
                SliderExperimentView()
            }
        }
    }
}
