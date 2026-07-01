import AppKit
import ApplicationServices
import Observation
import Synchronization

@Observable
final class ScrollReverser {
  private static let storageKey = "isReversing"

  var isReversing: Bool {
    didSet {
      UserDefaults.standard.set(isReversing, forKey: Self.storageKey)
      if isReversing && accessibilityGranted == false {
        requestAccessibility()
      }
      if isReversing && accessibilityGranted {
        tap.reinstall()
      }
      applyState()
    }
  }

  private(set) var accessibilityGranted: Bool

  let loginItem = LoginItemManager()

  private let tap = EventTapController()
  private var permissionPoll: Task<Void, Never>?

  init() {
    isReversing = UserDefaults.standard.bool(forKey: Self.storageKey)
    accessibilityGranted = AXIsProcessTrusted()
    if accessibilityGranted {
      tap.install()
    }
    applyState()
  }

  func requestAccessibility() {
    let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
    accessibilityGranted = AXIsProcessTrustedWithOptions(options)
    applyState()
    if !accessibilityGranted {
      startPermissionPolling()
    }
  }

  func openAccessibilitySettings() {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    else { return }
    NSWorkspace.shared.open(url)
  }

  private func applyState() {
    if accessibilityGranted { tap.install() }
    tap.isEnabled.store(isReversing && accessibilityGranted, ordering: .relaxed)
  }

  private func startPermissionPolling() {
    guard permissionPoll == nil else { return }
    permissionPoll = Task { [weak self] in
    guard let self else { return }
      while Task.isCancelled == false {
        if AXIsProcessTrusted() {
          self.accessibilityGranted = true
          self.applyState()
          break
        }
        try? await Task.sleep(for: .seconds(1))
      }
      self.permissionPoll = nil
    }
  }
}
