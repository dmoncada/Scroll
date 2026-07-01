import ServiceManagement

@Observable
final class LoginItemManager {
  private(set) var isEnabled: Bool

  init() {
    isEnabled = SMAppService.mainApp.status == .enabled
  }

  func setEnabled(_ enabled: Bool) {
    do {
      if enabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
    } catch {
      // Leave `isEnabled` reflecting the real status below.
    }
    isEnabled = SMAppService.mainApp.status == .enabled
  }
}
