import SwiftUI

// https://github.com/twostraws/VisualEffects/blob/main/Sources/VisualEffects/VisualEffectBlur-Mac.swift

struct VisualEffectView: NSViewRepresentable {
  var material: NSVisualEffectView.Material = .fullScreenUI
  var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
  var state: NSVisualEffectView.State = .active
  var isEmphasized: Bool = true

  func makeNSView(context: Context) -> NSVisualEffectView {
    context.coordinator.visualEffectView
  }
  
  func updateNSView(_ view: NSVisualEffectView, context: Context) {
    context.coordinator.update(
      material: material,
      blendingMode: blendingMode,
      state: state,
      isEmphasized: isEmphasized
    )
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator {
    let visualEffectView = NSVisualEffectView()

    func update(
      material: NSVisualEffectView.Material,
      blendingMode: NSVisualEffectView.BlendingMode,
      state: NSVisualEffectView.State,
      isEmphasized: Bool
    ) {
      visualEffectView.material = material
      visualEffectView.blendingMode = blendingMode
      visualEffectView.state = state
      visualEffectView.isEmphasized = isEmphasized
    }
  }
}
