import SwiftUI

struct ViewModel2 {
    @Binding var value: Float
    @Binding var value2: Float
}

struct ContentView2: View {
    let viewModel: ViewModel2

    var body: some View {
        VStack(alignment: .leading) {
            Text("value: \(viewModel.value)")
            Text("value2: \(viewModel.value2)")
            Slider(value: viewModel.$value, in: 0...1)
            Slider(value: viewModel.$value2, in: 0...1).foregroundColor(Color.red)
            SliderView(value: viewModel.$value)
        }.padding()
    }
}

struct SliderView: View {
    let value: Binding<Float>

    init(value: Binding<Float>) {
        self.value = value
        print("creating a new SliderView")
    }

    var body: some View {
        SliderViewControllerRepresentable(value: value)
    }
}

struct SliderViewControllerRepresentable: UIViewControllerRepresentable {
    private let value: Binding<Float>

    init(value: Binding<Float>) {
        print("creating a new SliderViewControllerRepresentable")
        self.value = value
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: value)
    }

    func makeUIViewController(context: Context) -> SliderViewController {
        let sliderViewController = SliderViewController(delegate: context.coordinator)
        context.coordinator.sliderViewController = sliderViewController
        return sliderViewController
    }

    func updateUIViewController(_ pageViewController: SliderViewController, context: Context) {
        context.coordinator.sliderViewController.slider.value = self.value.wrappedValue
    }

    class Coordinator: NSObject, SliderViewControllerDelegate {
        private let value: Binding<Float>
        var sliderViewController: SliderViewController!

        func didChangeSliderValue(value newValue: Float) {
            value.wrappedValue = newValue
        }

        init(value: Binding<Float>) {
            self.value = value
            super.init()
            print("creating a new coordinator")
        }
    }
}

protocol SliderViewControllerDelegate: AnyObject {
    func didChangeSliderValue(value: Float)
}

class SliderViewController: UIViewController {
    private weak var delegate: SliderViewControllerDelegate?

    init(delegate: SliderViewControllerDelegate) {
        self.delegate = delegate
        print("created a new SliderViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let slider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    @objc func didChangeSliderValue() {
        delegate?.didChangeSliderValue(value: slider.value)
    }

    override func viewDidLoad() {
        view.addSubview(slider)
        slider.addTarget(self, action: #selector(didChangeSliderValue), for: .valueChanged)

        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: view.topAnchor),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

#if DEBUG
    struct ContentView2_Previews: PreviewProvider {
        static var previews: some View {
            ContentView2(viewModel: ViewModel2(value: .constant(0.2), value2: .constant(0.4)))
        }
    }
#endif
