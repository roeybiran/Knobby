import Cocoa

final class MainWindowController: NSWindowController {
  convenience init() {
    self.init(windowNibName: "")
  }

  override func loadWindow() {
    let panel = Panel()
    panel.isFloatingPanel = true
    panel.becomesKeyOnlyIfNeeded = false
    window = panel
  }

  var viewModel: ViewModel!

  public override func windowDidLoad() {
    super.windowDidLoad()

    guard let window else { assertionFailure(); return }

    shouldCascadeWindows = false

    NSWindow.removeFrame(usingName: window.frameAutosaveName)

    window.hidesOnDeactivate = false
    window.delegate = self
    window.level = .floating
    window.title = "Knobby"
    window.styleMask = [
      .closable,
      .borderless,
      .nonactivatingPanel,
    ]

    window.hasShadow = false
    window.backgroundColor = .clear
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    window.standardWindowButton(.closeButton)?.isHidden = true
    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    window.standardWindowButton(.zoomButton)?.isHidden = true

    window.setContentSize(.init(width: 480, height: 180))

    guard let screen = window.screen else { assertionFailure(); return }
    let x = screen.frame.midX - (window.frame.width / 2)
    window.setFrameTopLeftPoint(NSPoint(x: x, y: screen.visibleFrame.maxY))
  }

  override func showWindow(_ sender: Any?) {
    super.showWindow(sender)
    animate(show: true)
  }

  override func close() {
    animate(show: false)
  }

  func animate(show: Bool) {
    guard let view = contentViewController?.view else { return }

    let anim = CABasicAnimation(keyPath: "position.y")
    anim.duration = 0.2
    anim.timingFunction = .init(name: .easeInEaseOut)

    if show {
      anim.delegate = nil
      anim.fromValue = view.bounds.maxY
      anim.toValue = 0
    } else {
      anim.delegate = self
      anim.fromValue = 0
      anim.toValue = view.bounds.maxY
    }

    anim.isRemovedOnCompletion = false
    anim.fillMode = .forwards
    view.layer?.add(anim, forKey: nil)
  }

}

extension MainWindowController: NSWindowDelegate {
  func windowDidBecomeKey(_ notification: Notification) {
    viewModel.onAppear()
  }

  func windowDidResignKey(_ notification: Notification) {
    animate(show: false)
  }
}

extension MainWindowController: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    super.close()
  }
}

final class Panel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}
