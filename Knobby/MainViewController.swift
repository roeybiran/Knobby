import Cocoa
import SwiftUI

final class MainViewController: NSViewController {
  private let contentView: NSView

  init(contentView: NSView) {
    self.contentView = contentView
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

    let fxView = NSVisualEffectView()
    fxView.material = .fullScreenUI

    view.addSubview(fxView)
    fxView.addSubview(contentView)

    view.wantsLayer = true
    view.layer!.borderWidth = 0
    view.layer!.cornerRadius = 16

    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.trailingAnchor.constraint(equalTo: fxView.trailingAnchor).isActive = true
    contentView.leadingAnchor.constraint(equalTo: fxView.leadingAnchor).isActive = true
    contentView.topAnchor.constraint(equalTo: fxView.topAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: fxView.bottomAnchor).isActive = true

    fxView.translatesAutoresizingMaskIntoConstraints = false
    fxView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    fxView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    fxView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    fxView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

  }
}
