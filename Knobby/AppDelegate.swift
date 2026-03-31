import Cocoa
import KeyboardShortcuts
import SwiftUI

// MARK: - AppDelegate

@main
final class AppDelegate: NSObject, NSApplicationDelegate {

  // MARK: Internal

  func applicationDidFinishLaunching(_: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)

    mainWindow.contentViewController = ViewController(model: model) { [weak self] in
      self?.dismissKnobby()
    }
    mainWindow.contentView?.wantsLayer = true
    mainWindow.delegate = self

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem).fixedSize())
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleKnobby(nil)
    }
  }

  func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
    true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    showKnobby()
    NSApplication.shared.activate()
    return false
  }

  @objc
  func toggleKnobby(_: Any?) {
    if isVisible {
      dismissKnobby()
    } else {
      showKnobby()
    }
  }

  @IBAction
  func orderFrontSettingsWindow(_ sender: Any?) {
    settingsWindow.makeKeyAndOrderFront(sender)
    settingsWindow.orderFrontRegardless()
  }

  // MARK: Private

  private let mainWindow = NSWindow.main
  private let settingsWindow = NSWindow.settings
  private let model = Model()
  private var isVisible = false

  private let showScaleAnimation: CASpringAnimation = {
    let animation = CASpringAnimation(perceptualDuration: 0.3, bounce: 0.3)
    animation.keyPath = "transform.scale"
    animation.fromValue = CATransform3DMakeScale(0.001, 0.001, 1)
    return animation
  }()

  private let hideScaleAnimation: CASpringAnimation = {
    let animation = CASpringAnimation(perceptualDuration: 0.3, bounce: 0.3)
    animation.keyPath = "transform.scale"
    animation.toValue = CATransform3DMakeScale(0.001, 0.001, 1)
    return animation
  }()

  private let statusItem: NSStatusItem = {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    item.button?.image = NSImage(named: "MenuBarExtra")
    item.button?.image?.isTemplate = true
    #if DEBUG
    item.button?.title = "DEV"
    #endif
    item.menu = .general()
    return item
  }()

  private func showKnobby() {
    guard let frame = NSScreen.main?.frame else { return }

    mainWindow.setFrame(frame, display: true, animate: false)
    mainWindow.alphaValue = 0
    mainWindow.makeKeyAndOrderFront(nil)
    mainWindow.makeFirstResponder(nil)

    if let targetView = mainWindow.contentView, let targetLayer = targetView.layer {
      targetLayer.anchorPoint = .init(x: 0.5, y: 1)
      targetLayer.position = .init(x: targetView.frame.midX, y: targetView.frame.maxY)
      targetLayer.add(showScaleAnimation, forKey: "transformAnim")
    }
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.3
      mainWindow.animator().alphaValue = 1
    } completionHandler: {
      Task { @MainActor in
        guard
          let viewController = self.mainWindow.contentViewController as? ViewController,
          let slider = viewController.firstSlider
        else { return }

        self.mainWindow.makeFirstResponder(slider)
      }
    }
  }

  private func dismissKnobby() {
    guard isVisible else { return }
    isVisible = false
    mainWindow.makeFirstResponder(nil)

    if let targetView = mainWindow.contentView, let targetLayer = targetView.layer {
      targetLayer.anchorPoint = .init(x: 0.5, y: 1)
      targetLayer.position = .init(x: targetView.frame.midX, y: targetView.frame.maxY)
      targetLayer.add(hideScaleAnimation, forKey: "transformAnim")
    }
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.3
      mainWindow.animator().alphaValue = 0
    } completionHandler: {
      Task { @MainActor in
        self.mainWindow.orderOut(nil)
        self.mainWindow.alphaValue = 1
        NSApplication.shared.deactivate()
      }
    }
  }

}

// MARK: NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
  func windowDidBecomeKey(_: Notification) {
    isVisible = true
    model.refresh()
  }

  func windowDidResignKey(_: Notification) {
    dismissKnobby()
  }
}
