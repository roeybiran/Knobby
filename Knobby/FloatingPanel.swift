import AppKit
import SwiftUI

private struct FloatingPanelKey: EnvironmentKey {
  static let defaultValue: NSPanel? = nil
}

extension EnvironmentValues {
  var floatingPanel: NSPanel? {
    get { self[FloatingPanelKey.self] }
    set { self[FloatingPanelKey.self] = newValue }
  }
}

final class FloatingPanel<PanelContent: View>: NSPanel {
  @Binding private var isPresented: Bool
  private let contentRect: CGRect
  private let hostingView: NSHostingView<AnyView>
  private let containerView: NSView

  init(
    contentRect: CGRect,
    isPresented: Binding<Bool>,
    @ViewBuilder content: () -> PanelContent
  ) {
    self._isPresented = isPresented
    self.contentRect = contentRect
    self.hostingView = NSHostingView(rootView: AnyView(EmptyView()))
    self.containerView = NSView(frame: contentRect)
    super.init(
      contentRect: contentRect,
      styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )

    isFloatingPanel = true
    level = .screenSaver
    collectionBehavior = [.fullScreenAuxiliary, .moveToActiveSpace]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    isMovableByWindowBackground = true
    hidesOnDeactivate = true
    backgroundColor = .clear
    hasShadow = false
    isOpaque = false
    animationBehavior = .utilityWindow
    standardWindowButton(.closeButton)?.isHidden = true
    standardWindowButton(.miniaturizeButton)?.isHidden = true
    standardWindowButton(.zoomButton)?.isHidden = true
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(hostingView)
    NSLayoutConstraint.activate([
      hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])
    contentView = containerView

    updateContent(content)
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  override func resignMain() {
    super.resignMain()
    if isVisible {
      close()
    }
  }

  override func resignKey() {
    super.resignKey()
    if isVisible {
      close()
    }
  }

  override func close() {
    let wasVisible = isVisible
    super.close()
    if wasVisible {
      isPresented = false
    }
  }

  func updateContent(_ content: () -> PanelContent) {
    hostingView.rootView = AnyView(
      content()
        .ignoresSafeArea()
        .environment(\.floatingPanel, self)
    )
  }

  func present() {
    let fittedSize = hostingView.fittingSize
    let size = CGSize(
      width: max(contentRect.width, fittedSize.width),
      height: max(contentRect.height, fittedSize.height)
    )
    let screenFrame = screen?.frame ?? NSScreen.main?.frame ?? .zero

    setContentSize(size)
    setFrame(
      CGRect(
        x: round(screenFrame.midX - size.width / 2),
        y: round(screenFrame.maxY - size.height),
        width: size.width,
        height: size.height
      ),
      display: true
    )
    orderFrontRegardless()
    makeKey()
  }
}

private struct FloatingPanelModifier<PanelContent: View>: ViewModifier {
  @Binding var isPresented: Bool
  let contentRect: CGRect
  let panelContent: () -> PanelContent
  @State private var panel: FloatingPanel<PanelContent>?

  func body(content: Content) -> some View {
    content
      .onAppear {
        if panel == nil {
          panel = FloatingPanel(
            contentRect: contentRect,
            isPresented: $isPresented,
            content: panelContent
          )
        }
        if isPresented {
          panel?.present()
        }
      }
      .onDisappear {
        panel?.close()
        panel = nil
      }
      .onChange(of: isPresented) {
        panel?.updateContent(panelContent)
        if isPresented {
          panel?.present()
        } else if panel?.isVisible == true {
          panel?.close()
        }
      }
  }
}

extension View {
  func floatingPanel<PanelContent: View>(
    isPresented: Binding<Bool>,
    contentRect: CGRect,
    @ViewBuilder content: @escaping () -> PanelContent
  ) -> some View {
    modifier(
      FloatingPanelModifier(
        isPresented: isPresented,
        contentRect: contentRect,
        panelContent: content
      )
    )
  }
}
