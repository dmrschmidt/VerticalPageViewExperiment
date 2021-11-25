import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var value1: Float = 0.5
    @Published var value2: Float = 0.4
}

class MainViewModel2: ObservableObject {
    @Published var currentPage: UUID
    @Published var progress: Float

    private var timer: Timer?

    init(currentPage: UUID) {
        self.currentPage = currentPage
        self.progress = 0

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
//                print("will change progress")
//                self.progress = Float.random(in: 0...1)
            }
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
