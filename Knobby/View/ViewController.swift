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

  private let model: Model
  private let stack: NSStackView = {
    let stack = NSStackView()
    stack.orientation = .vertical
    stack.spacing = 20
    stack.edgeInsets = .init(top: 60, left: 0, bottom: 20, right: 0)
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  private let button: NSPopUpButton = {
    let button = NSPopUpButton(
      image: NSImage(named: NSImage.actionTemplateName) ?? .init(),
      pullDownMenu: .general()
    )
    button.isBordered = false
    button.refusesFirstResponder = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  private var slidersByKind = [AdjustableMetric.Kind: NSSlider]()
  private var sliderKindsByIdentifier = [ObjectIdentifier: AdjustableMetric.Kind]()
  private var visibleMetricKinds = [AdjustableMetric.Kind]()

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

    stack.addSubview(button)
    rebuildMetricRows()

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

    rebuildMetricRows()

    for metric in model.values {
      slidersByKind[metric.id]?.animator().floatValue = metric.currentValue
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
        slidersByKind.values.forEach { $0.isEnabled = true }
        if
          let focusedSetting = model.focusedSetting,
          let slider = slidersByKind[focusedSetting]
        {
          window.makeFirstResponder(slider)
        }
      } else {
        springAnimation.toValue = CATransform3DMakeScale(0, 0, 0)
        targetLayer.add(springAnimation, forKey: "transformAnim")
        slidersByKind.values.forEach { $0.isEnabled = false }
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

  @objc func changeSliderValue(_ sender: NSSlider) {
    guard let kind = sliderKindsByIdentifier[ObjectIdentifier(sender)] else { return }
    model.onSliderValueChanged(kind: kind, value: sender.floatValue)
  }

  override func cancelOperation(_ sender: Any?) {
    model.onEscapePress()
  }

  func kind(for responder: NSResponder?) -> AdjustableMetric.Kind? {
    guard let slider = responder as? NSSlider else { return nil }
    return sliderKindsByIdentifier[ObjectIdentifier(slider)]
  }

  override func loadView() {
    view = NSView()
  }

  private func rebuildMetricRows() {
    let metricKinds = model.values.map(\.id)
    guard metricKinds != visibleMetricKinds else { return }

    visibleMetricKinds = metricKinds
    sliderKindsByIdentifier.removeAll()
    slidersByKind.removeAll()

    stack.arrangedSubviews.forEach { arrangedSubview in
      stack.removeArrangedSubview(arrangedSubview)
      arrangedSubview.removeFromSuperview()
    }

    for metric in model.values {
      let title = NSTextField(labelWithString: metric.deviceName)
      title.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
      title.textColor = .secondaryLabelColor

      let image = NSImage(systemSymbolName: metric.imageName, accessibilityDescription: nil)
      let imageView = NSImageView(image: image ?? .init())
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true

      let slider = NSSlider(
        value: Double(metric.currentValue),
        minValue: .zero,
        maxValue: 1,
        target: self,
        action: #selector(changeSliderValue)
      )
      if #available(macOS 26.0, *) {
        slider.controlSize = .extraLarge
      } else {
        slider.controlSize = .large
      }

      let controls = NSStackView(views: [imageView, slider])
      controls.orientation = .horizontal
      controls.spacing = 12
      controls.alignment = .centerY

      let row = NSStackView(views: [title, controls])
      row.orientation = .vertical
      row.spacing = 8
      row.edgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)

      slidersByKind[metric.id] = slider
      sliderKindsByIdentifier[ObjectIdentifier(slider)] = metric.id
      stack.addArrangedSubview(row)
    }
  }
}
