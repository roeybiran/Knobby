import Cocoa
import KeyboardShortcuts
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private let mainWindow = NSWindow.main
  private let settingsWindow = NSWindow.settings
  private let model = Model()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)

     let rootView = NSHostingView(
      rootView: ContentView(
        model: model,
        onToggle: { [weak self] in self?.toggleKnobby(nil) },
        onOpenSettings: { [weak self] in self?.orderFrontSettingsWindow(nil) },
        onDismiss: { [weak self] in self?.dismissKnobby(nil) },
        onQuit: { NSApplication.shared.terminate(nil) }
      )
    )

    guard let contentView = mainWindow.contentView else {
      assertionFailure()
      return
    }

    rootView.translatesAutoresizingMaskIntoConstraints = false
    rootView.wantsLayer = true

    contentView.addSubview(rootView)
    NSLayoutConstraint.activate([
      rootView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      rootView.topAnchor.constraint(equalTo: contentView.topAnchor)
    ])

    mainWindow.delegate = self

    let settingsView = NSHostingView(rootView: SettingsView(statusItem: statusItem))
    settingsWindow.contentView = settingsView

    KeyboardShortcuts.onKeyDown(for: .toggleKnobby) { [weak self] in
      self?.toggleKnobby(nil)
    }
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    true
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    toggleKnobby(sender)
    NSApplication.shared.activate()
    return false
  }

  @objc func toggleKnobby(_ sender: Any?) {
    model.onToggleApp()

    if model.isVisible {
      showMainWindow()
    } else {
      hideMainWindow(deactivateApp: true)
    }
  }

  @objc func dismissKnobby(_ sender: Any?) {
    if model.isVisible {
      model.onEscapePress()
    }
    hideMainWindow(deactivateApp: true)
  }

  @IBAction func orderFrontSettingsWindow(_ sender: Any?) {
    settingsWindow.makeKeyAndOrderFront(sender)
    settingsWindow.orderFrontRegardless()
  }

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

  private func showMainWindow() {
    let screenFrame = NSScreen.main?.frame ?? .zero
//    mainWindow.setFrameTopLeftPoint(
//      .init(
//        x: round(screenFrame.midX - mainWindow.frame.width / 2),
//        y: round(screenFrame.maxY)
//      )
//    )
//
    mainWindow.setFrame(screenFrame, display: true)
    mainWindow.alphaValue = 0
    mainWindow.makeKeyAndOrderFront(nil)

    if let targetView = mainWindow.contentView, let targetLayer = targetView.layer {
      targetLayer.anchorPoint = .init(x: 0.5, y: 1)
      targetLayer.position = .init(x: targetView.frame.midX, y: targetView.frame.maxY)
      let springAnimation = CASpringAnimation(perceptualDuration: 0.3, bounce: 0.3)
      springAnimation.keyPath = "transform.scale"
      springAnimation.fromValue = CATransform3DMakeScale(0.001, 0.001, 1)
      targetLayer.add(springAnimation, forKey: "transformAnim")
    }
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.3
      mainWindow.animator().alphaValue = 1
    }
  }

  private func hideMainWindow(deactivateApp: Bool) {
    guard mainWindow.isVisible else { return }

    if let targetView = mainWindow.contentView, let targetLayer = targetView.layer {
      targetLayer.anchorPoint = .init(x: 0.5, y: 1)
      targetLayer.position = .init(x: targetView.frame.midX, y: targetView.frame.maxY)
      let springAnimation = CASpringAnimation(perceptualDuration: 0.3, bounce: 0.3)
      springAnimation.keyPath = "transform.scale"
      springAnimation.toValue = CATransform3DMakeScale(0.001, 0.001, 1)
      targetLayer.add(springAnimation, forKey: "transformAnim")
    }
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.3
      mainWindow.animator().alphaValue = 0
    } completionHandler: {
      self.mainWindow.orderOut(nil)
      self.mainWindow.alphaValue = 1
      if deactivateApp {
        NSApplication.shared.deactivate()
      }
    }
  }
}

extension AppDelegate: NSWindowDelegate {
  func windowDidResignKey(_ notification: Notification) {
    model.onResignKey()
    hideMainWindow(deactivateApp: false)
  }
}
