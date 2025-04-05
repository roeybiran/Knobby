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
      slider.controlSize = .large

      let innerStack = NSStackView(views: [imageView, slider])
      innerStack.edgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)

      sliders.append(slider)
      stack.addArrangedSubview(innerStack)
    }

    if let last = stack.arrangedSubviews.last {
      stack.setCustomSpacing(20, after: last)
    } else {
      assertionFailure()
    }

    let separator = NSBox()
    separator.boxType = .separator

    let image = NSImage(named: NSImage.actionTemplateName)
    let button = NSPopUpButton(
      image: image ?? .init(),
      pullDownMenu: .general()
    )
    button.refusesFirstResponder = true
    button.bezelStyle = .toolbar
    button.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)

    stack.addArrangedSubview(separator)
    stack.addArrangedSubview(button)
    stack.spacing = 10
    stack.edgeInsets = .init(top: 0, left: 0, bottom: 10, right: 0)

    let box = NSBox()
    box.boxType = .custom
    box.borderWidth = 1
    box.borderColor = .separatorColor
    box.cornerRadius = 8
    box.fillColor = .windowBackgroundColor
    box.contentViewMargins = .zero
    box.translatesAutoresizingMaskIntoConstraints = false

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

    view.addSubview(box)

    NSLayoutConstraint.activate(
      [
        stack.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
        stack.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
        stack.topAnchor.constraint(equalTo: visualEffectView.layoutMarginsGuide.topAnchor, constant: model.notchHeight()),
        stack.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
        button.trailingAnchor.constraint(equalTo: stack.layoutMarginsGuide.trailingAnchor),
        box.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        box.topAnchor.constraint(equalTo: view.topAnchor),
        box.widthAnchor.constraint(equalToConstant: .knobbyWidth),
      ]
    )

    withObservationTracking(of: self.model.values) { metrics in
      Task { @MainActor in
        for metric in metrics {
          self.sliders[metric.rawValue].animator().floatValue = metric.currentValue
        }
      }
    }

    withObservationTracking(of: self.model.isVisible) { visible in
      Task { @MainActor [weak self] in
        guard let self else { return }
        let targetView = box
        guard let targetLayer = targetView.layer else { return }
        targetLayer.anchorPoint = .init(x: 0.5, y: 1)
        targetLayer.position = .init(x: targetView.frame.midX, y: targetView.frame.maxY)
        let springAnimation = CASpringAnimation(perceptualDuration: 0.3, bounce: 0.3)
        springAnimation.keyPath = "transform.scale"
        if visible {
          springAnimation.fromValue = CATransform3DMakeScale(0, 0, 0)
          sliders.forEach { $0.isEnabled = true }
          view.window?.makeFirstResponder(sliders.first)
        } else {
          springAnimation.toValue = CATransform3DMakeScale(0, 0, 0)
          sliders.forEach { $0.isEnabled = false }
        }
        targetLayer.add(springAnimation, forKey: "transformAnim")
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

