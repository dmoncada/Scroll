import SwiftUI

struct ScrollMenu: View {
  @Bindable var reverser: ScrollReverser

  var body: some View {
    if reverser.accessibilityGranted == false {
      Button("Grant Accessibility Access…", systemImage: "lock.shield") {
        reverser.requestAccessibility()
        reverser.openAccessibilitySettings()
      }
      Divider()
    }

    Toggle("Reverse Mouse Scrolling", isOn: $reverser.isReversing)
      .disabled(!reverser.accessibilityGranted)

    Divider()

    Toggle(
      "Launch at Login",
      isOn: Binding(
        get: { reverser.loginItem.isEnabled },
        set: { reverser.loginItem.setEnabled($0) }
      ))

    Divider()

    Button("Quit Scroll") {
      NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q")
  }
}
