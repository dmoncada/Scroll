import SwiftUI

@main
struct ScrollApp: App {
  @State private var reverser = ScrollReverser()

  var body: some Scene {
    MenuBarExtra {
      ScrollMenu(reverser: reverser)
    } label: {
      Image(
        systemName: reverser.isReversing
          ? "computermouse.fill"
          : "computermouse")
    }
    .menuBarExtraStyle(.menu)
  }
}
