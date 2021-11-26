import SwiftUI

struct Content: Identifiable {
    var id = UUID()
    var name: String
}

struct ViewModel {
    var pages: [Content]
    @Binding var currentPage: UUID
}

struct PageViewModel {
    var pages: [Content]
    @Binding var currentPage: UUID
}

struct ContentView: View {
    var pageViewModel: MainViewModel2
    var progressViewModel: ProgressViewModel

    var body: some View {
        ZStack {
            SillyViewWrapper(viewModel: pageViewModel)
            OtherSillyViewWrapper(viewModel: progressViewModel)
        }
    }
}

struct OtherSillyViewWrapper: View {
    @StateObject var viewModel: ProgressViewModel

    var body: some View {
        Text("progress: \(viewModel.progress)")
    }
}

struct SillyViewWrapper: View {
    @StateObject var viewModel: MainViewModel2

    var body: some View {
        VerticalPageView(viewModel.pages, currentPage: $viewModel.currentPage) { page in
            Text("page \(page.name) - \(page.id.uuidString)")
        }
    }
}
#if DEBUG
//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            ContentView(viewModel: ViewModel(value: .constant(0.2), value2: .constant(0.4)))
//        }
//    }
#endif
