import SwiftUI

struct Content: Identifiable {
    var id = UUID()
    var name: String
}

struct VerticalPageExperimentView: View {
    var pageViewModel: PageViewModel // these MUST NOT be @StateObject or we get the broken behavior again
    var progressViewModel: ProgressViewModel // we also need a DIFFERENT viewModel each for progress and then other unrelated updates

    var body: some View {
        ZStack {
            PagesRelatedView(viewModel: pageViewModel)
            ProgressRelatedView(viewModel: progressViewModel)
        }
    }
}

struct ProgressRelatedView: View {
    @StateObject var viewModel: ProgressViewModel

    var body: some View {
        Text("progress: \(viewModel.progress)")
    }
}

struct PagesRelatedView: View {
    @StateObject var viewModel: PageViewModel

    var body: some View {
        VerticalPageView(viewModel.pages, currentPage: $viewModel.currentPage) { page in
            Text("page \(page.name) - \(page.id.uuidString)")
        }
    }
}
