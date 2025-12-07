import AppKit
import Foundation
import Carbon

final class ViewController: NSViewController {
  init(model: Model) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var sliders = [NSSlider]()
  private let model: Model

  override func keyDown(with event: NSEvent) {
    switch Int(event.keyCode) {
    case kVK_ANSI_H:
      decrease(nil)
    case kVK_ANSI_J:
      minimize(nil)
    case kVK_ANSI_K:
      maximize(nil)
    case kVK_ANSI_L:
      increase(nil)
    default:
      super.keyDown(with: event)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let stack = NSStackView(views: [])
    stack.orientation = .vertical
    stack.spacing = 20
    stack.edgeInsets = .init(top: 60, left: 0, bottom: 20, right: 0)

    for setting in AdjustableMetric.allCases {
      // https://wwdcnotes.com/documentation/wwdcnotes/wwdc23-10258-animate-symbols-in-your-app/
      let image = NSImage(systemSymbolName: setting.imageName, accessibilityDescription: nil)
      let imageView = NSImageView(image: image ?? .init())
      let slider = NSSlider(
        value: .zero,
        minValue: .zero,
        maxValue: 1,
        target: self,
        action: #selector(changeSliderValue)
      )
      slider.tag = setting.rawValue

      if #available(macOS 26.0, *) {
        slider.controlSize = .extraLarge
      } else {
        slider.controlSize = .large
      }

      let innerStack = NSStackView(views: [imageView, slider])
      innerStack.edgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)

      sliders.append(slider)
      stack.addArrangedSubview(innerStack)
    }

    let button = NSPopUpButton(
      image: NSImage(named: NSImage.actionTemplateName) ?? .init(),
      pullDownMenu: .general()
    )
    button.isBordered = false
    button.refusesFirstResponder = true
    button.translatesAutoresizingMaskIntoConstraints = false

    stack.addSubview(button)

    let container: NSView

    if #available(macOS 26.0, *) {
      let glass = NSGlassEffectView()
      glass.contentView = stack
      container = glass
    } else {
      // Fallback on earlier versions
      let box = NSBox()
      box.boxType = .custom
      box.borderWidth = 1
      box.borderColor = .separatorColor
      box.cornerRadius = 8
      box.fillColor = .windowBackgroundColor
      box.contentViewMargins = .zero

      let shadow = NSShadow()
      shadow.shadowOffset = .init(width: 0, height: -6)
      shadow.shadowBlurRadius = 20
      shadow.shadowColor = .black.withAlphaComponent(0.5)
      box.shadow = shadow

      let visualEffectView = NSVisualEffectView()
      visualEffectView.material = .hudWindow
      visualEffectView.wantsLayer = true
      visualEffectView.layer?.cornerRadius = 8
      visualEffectView.addSubview(stack)

      box.contentView = visualEffectView
      container = box
    }

    container.wantsLayer = true
    container.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(container)

    self.container = container

    NSLayoutConstraint.activate(
      [
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        stack.topAnchor.constraint(equalTo: container.topAnchor),
        stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),

        button.topAnchor.constraint(equalTo: stack.topAnchor, constant: 14),
        button.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -20),

        container.topAnchor.constraint(equalTo: view.topAnchor),
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        container.widthAnchor.constraint(equalToConstant: .knobbyWidth),
      ]
    )
  }

  private var container: NSView?
  private var isViewVisible = false

  override func updateViewConstraints() {
    super.updateViewConstraints()

    for metric in model.values {
      self.sliders[metric.rawValue].animator().floatValue = metric.currentValue
    }


    if model.isVisible != isViewVisible {
      isViewVisible = model.isVisible
      guard
        let window = view.window,
        let frame = NSScreen.main?.frame,
        let targetView = container,
        let targetLayer = targetView.layer
      else { return assertionFailure() }

      targetLayer.anchorPoint = .init(x: 0.5, y: 1)
      targetLayer.position = .init(x: targetView.frame.midX, y: targetView.frame.maxY)
      let springAnimation = CASpringAnimation(perceptualDuration: 0.3, bounce: 0.3)
      springAnimation.keyPath = "transform.scale"
      if model.isVisible {
        window.setFrame(frame, display: true, animate: false)
        window.makeKeyAndOrderFront(nil)
        window.animator().alphaValue = 1
        springAnimation.fromValue = CATransform3DMakeScale(0, 0, 0)
        targetLayer.add(springAnimation, forKey: "transformAnim")
        sliders.forEach { $0.isEnabled = true }
        window.makeFirstResponder(sliders.first)
      } else {
        springAnimation.toValue = CATransform3DMakeScale(0, 0, 0)
        targetLayer.add(springAnimation, forKey: "transformAnim")
        sliders.forEach { $0.isEnabled = false }
        window.animator().alphaValue = 0
        NSApplication.shared.deactivate()
      }
    }
  }

  @IBAction func increase(_ sender: Any?) {
    model.onIncrease()
  }

  @IBAction func decrease(_ sender: Any?) {
    model.onDecrease()
  }

  @IBAction func minimize(_ sender: Any?) {
    model.onMinimize()
  }

  @IBAction func maximize(_ sender: Any?) {
    model.onMaximize()
  }

  @objc func changeSliderValue(_ sender: Any?) {
    model.onSliderValueChanged(sender: sender)
  }

  override func cancelOperation(_ sender: Any?) {
    model.onEscapePress()
  }

  override func loadView() {
    view = NSView()
  }

}

