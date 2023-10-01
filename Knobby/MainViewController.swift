import Cocoa
import SwiftUI

final class MainViewController: NSViewController {
  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()
  }

  override func doCommand(by selector: Selector) {
    if selector == #selector(NSSavePanel.cancel(_:)){
      view.window?.windowController?.close()
    } else {
      super.doCommand(by: selector)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let contentView = MainView(viewModel: viewModel)
    let hostingView = NSHostingView(rootView: contentView)

    let fxView = NSVisualEffectView()
    fxView.material = .fullScreenUI

    view.addSubview(fxView)
    fxView.addSubview(hostingView)

    view.wantsLayer = true
    view.layer!.borderWidth = 0
    view.layer!.cornerRadius = 16

    hostingView.translatesAutoresizingMaskIntoConstraints = false
    hostingView.trailingAnchor.constraint(equalTo: fxView.trailingAnchor).isActive = true
    hostingView.leadingAnchor.constraint(equalTo: fxView.leadingAnchor).isActive = true
    hostingView.topAnchor.constraint(equalTo: fxView.topAnchor).isActive = true
    hostingView.bottomAnchor.constraint(equalTo: fxView.bottomAnchor).isActive = true

    fxView.translatesAutoresizingMaskIntoConstraints = false
    fxView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    fxView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    fxView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    fxView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

  }
}
