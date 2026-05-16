import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardRootView>?
    private let viewModel = KeyboardViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSwiftUIKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputViewController = self
        viewModel.refreshCurrentText()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        viewModel.refreshCurrentText()
    }

    // MARK: - SwiftUI Integration

    private func setupSwiftUIKeyboard() {
        viewModel.inputViewController = self

        let rootView = KeyboardRootView(viewModel: viewModel, needsGlobe: needsInputModeSwitchKey)
        let hc = UIHostingController(rootView: rootView)
        hostingController = hc

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)

        hc.view.translatesAutoresizingMaskIntoConstraints = false
        hc.view.backgroundColor = .clear
        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // Keep the hosting controller's root view updated if the globe key requirement changes
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hostingController?.rootView = KeyboardRootView(
            viewModel: viewModel,
            needsGlobe: needsInputModeSwitchKey
        )
    }
}
