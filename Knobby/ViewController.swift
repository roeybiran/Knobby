import AppKit
import Carbon
import Foundation
import Observation

final class ViewController: NSViewController {

  // MARK: Lifecycle

  init(model: Model, onDismiss: @escaping () -> Void = {}) {
    self.onDismiss = onDismiss
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

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

    allSlidersStack.addSubview(button)

    let container = NSGlassEffectView()
    container.contentView = allSlidersStack
    container.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(container)

    NSLayoutConstraint.activate(
      [
        allSlidersStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        allSlidersStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        allSlidersStack.topAnchor.constraint(equalTo: container.topAnchor),
        allSlidersStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),

        button.topAnchor.constraint(equalTo: allSlidersStack.topAnchor, constant: 14),
        button.trailingAnchor.constraint(equalTo: allSlidersStack.trailingAnchor, constant: -20),

        container.topAnchor.constraint(equalTo: view.topAnchor),
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        container.widthAnchor.constraint(equalToConstant: .knobbyWidth),
      ]
    )

    render(values: model.values)
  }

  override func viewDidLayout() {
    super.viewDidLayout()

    Task {
      let observations = Observations<[AdjustableMetric], Never> { [weak self] in
        guard let self else { return [] }
        return model.values
      }

      for await change in observations {
        render(values: change)
      }
    }
  }

  @IBAction
  func increase(_: Any?) {
    guard
      let slider = (view.window?.firstResponder as? NSSlider) ?? firstSlider,
      let kind = sliderKindsByIdentifier[ObjectIdentifier(slider)]
    else { return }
    model.increase(kind)
  }

  @IBAction
  func decrease(_: Any?) {
    guard
      let slider = (view.window?.firstResponder as? NSSlider) ?? firstSlider,
      let kind = sliderKindsByIdentifier[ObjectIdentifier(slider)]
    else { return }
    model.decrease(kind)
  }

  @IBAction
  func minimize(_: Any?) {
    guard
      let slider = (view.window?.firstResponder as? NSSlider) ?? firstSlider,
      let kind = sliderKindsByIdentifier[ObjectIdentifier(slider)]
    else { return }
    model.minimize(kind)
  }

  @IBAction
  func maximize(_: Any?) {
    guard
      let slider = (view.window?.firstResponder as? NSSlider) ?? firstSlider,
      let kind = sliderKindsByIdentifier[ObjectIdentifier(slider)]
    else { return }
    model.maximize(kind)
  }

  @objc
  func changeSliderValue(_ sender: NSSlider) {
    guard let kind = sliderKindsByIdentifier[ObjectIdentifier(sender)] else { return }
    model.setValue(kind: kind, value: sender.floatValue)
  }

  override func cancelOperation(_: Any?) {
    onDismiss()
  }

  var firstSlider: NSSlider? {
    guard let kind = visibleMetricKinds.first else { return nil }
    return slidersByKind[kind]
  }

  override func loadView() {
    view = NSView()
  }

  // MARK: Private

  private let model: Model
  private let onDismiss: () -> Void

  private let allSlidersStack: NSStackView = {
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
      pullDownMenu: .general(),
    )
    button.isBordered = false
    button.refusesFirstResponder = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private var slidersByKind = [AdjustableMetric.Kind: NSSlider]()
  private var sliderKindsByIdentifier = [ObjectIdentifier: AdjustableMetric.Kind]()
  private var visibleMetricKinds = [AdjustableMetric.Kind]()

  private func render(values: [AdjustableMetric]) {
    for value in values {
      slidersByKind[value.id]?.floatValue = value.currentValue
    }

    let metricKinds = values.map(\.id)
    guard metricKinds != visibleMetricKinds else { return }

    visibleMetricKinds = metricKinds
    sliderKindsByIdentifier.removeAll()
    slidersByKind.removeAll()

    for arrangedSubview in allSlidersStack.arrangedSubviews {
      allSlidersStack.removeArrangedSubview(arrangedSubview)
      arrangedSubview.removeFromSuperview()
    }

    for metric in values {
      let title = NSTextField(labelWithString: metric.deviceName)
      title.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
      title.textColor = .secondaryLabelColor

      let image = NSImage(systemSymbolName: metric.imageName, accessibilityDescription: nil)
      let imageView = NSImageView(image: image ?? .init())
      imageView.translatesAutoresizingMaskIntoConstraints = false

      let slider = NSSlider(
        value: Double(metric.currentValue),
        minValue: .zero,
        maxValue: 1,
        target: self,
        action: #selector(changeSliderValue),
      )
      slider.controlSize = .extraLarge

      let controls = NSStackView(views: [imageView, slider])
      controls.orientation = .horizontal
      controls.alignment = .centerY

      let row = NSStackView(views: [title, controls])
      row.alignment = .leading
      row.orientation = .vertical
      row.edgeInsets = .init(
        top: 0,
        left: 20,
        bottom: 0,
        right: 20,
      )

      slidersByKind[metric.id] = slider
      sliderKindsByIdentifier[ObjectIdentifier(slider)] = metric.id

      allSlidersStack.addArrangedSubview(row)

      NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 16),
        row.widthAnchor.constraint(equalTo: allSlidersStack.widthAnchor),
      ])
    }

    for metric in values {
      slidersByKind[metric.id]?.floatValue = metric.currentValue
    }
  }

}
