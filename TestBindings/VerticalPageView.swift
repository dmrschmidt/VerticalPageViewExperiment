import SwiftUI
import UIKit

struct VerticalPageView<Content: View, Data>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Data.Index == Int {
    let data: Data
    @Binding var currentPage: Data.Element.ID
    let contentBuilder: (Data.Element) -> Content

    init(_ data: Data, currentPage: Binding<Data.Element.ID>, contentBuilder: @escaping (Data.Element) -> Content) {
        print("*** did create new VerticalPageView")
        self.data = data
        _currentPage = currentPage
        self.contentBuilder = contentBuilder
    }

    var body: some View {
        VerticalPageViewControllerRepresentable(data, currentPage: $currentPage, contentBuilder: contentBuilder)
    }
}

struct VerticalPageViewControllerRepresentable<Content: View, Data>: UIViewControllerRepresentable where Data: RandomAccessCollection, Data.Element: Identifiable, Data.Index == Int {
    let data: Data
    @Binding private var currentPageId: Data.Element.ID
    private let contentBuilder: (Data.Element) -> Content

    init(_ data: Data, currentPage: Binding<Data.Element.ID>, contentBuilder: @escaping (Data.Element) -> Content) {
        print("*** did create a new VerticalPageViewControllerRepresentable")
        self.data = data
        self.contentBuilder = contentBuilder
        _currentPageId = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(data: data, currentPageId: $currentPageId, contentBuilder: contentBuilder)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        print("*** \(#function)")
        let pageViewController = OurPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        print("*** \(#function)")

        // we still need to compare against some "last known id" - formerly that 'stableId' - to tell when we must re-render new VCs
        if data.first?.id != context.coordinator.lastKnownId {
            context.coordinator.update(data: data, contentBuilder: contentBuilder)
        }
        let currentPage = data.firstIndex { $0.id == currentPageId }!
        pageViewController.setViewControllers([context.coordinator.controllers[currentPage]], direction: .forward, animated: true)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        private var data: Data
        private var pages: [Content]
        private(set) var controllers = [UIViewController]()
        var lastKnownId: Data.Element.ID? // since I don't know how to get the `.id()` ID

        @Binding private var currentPageId: Data.Element.ID

        init(data: Data, currentPageId: Binding<Data.Element.ID>, contentBuilder: (Data.Element) -> Content) {
            self.data = data
            lastKnownId = data.first?.id
            pages = data.map { contentBuilder($0) }
            _currentPageId = currentPageId
            super.init()

            recreateViewControllers()
        }

        func update(data: Data, contentBuilder: (Data.Element) -> Content) {
            self.data = data
            pages = data.map { contentBuilder($0) }
            recreateViewControllers()
        }

        private func recreateViewControllers() {
            controllers = pages.map {
                let viewController = UIHostingController(rootView: $0)
                viewController.view.backgroundColor = .clear
                return viewController
            }
            print("*** recreated \(controllers.count) ViewControllers")
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController), index > 0 else {
                return nil
            }
            return controllers[index - 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController), index + 1 < controllers.count else {
                return nil
            }
            return controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = controllers.firstIndex(of: visibleViewController) {
                print("*** \(#function) will change \(currentPageId) to \(data[index].id)")
                currentPageId = data[index].id
            }
        }
    }
}

class OurPageViewController: UIPageViewController {
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey: Any]? = nil) {
        print("*** we have a new OurPageViewController")
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
