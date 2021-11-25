import SwiftUI

struct Content: Identifiable {
    var id = UUID()
    var name: String
}

struct ViewModel {
    var pages: [Content]
    @Binding var progress: Float
    @Binding var currentPage: UUID
}

struct ContentView: View {
    let viewModel: ViewModel

    var body: some View {
        VerticalPageView(viewModel.pages, currentPage: viewModel.$currentPage, tempStableId: viewModel.pages.first!.id) { page in
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
