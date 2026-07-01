import CoreGraphics
import Synchronization
import os

nonisolated let scrollLog = Logger(subsystem: "Scroll", category: "EventTap")

nonisolated final class EventTapController {
  let isEnabled = Atomic<Bool>(false)

  private var tap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?

  var isInstalled: Bool { tap != nil }

  func reEnable() {
    if let tap {
      CGEvent.tapEnable(tap: tap, enable: true)
    }
  }

  @discardableResult
  func reinstall() -> Bool {
    uninstall()
    return install()
  }

  @discardableResult
  func install() -> Bool {
    guard tap == nil else { return true }

    let mask: CGEventMask = 1 << CGEventType.scrollWheel.rawValue
    let refcon = Unmanaged.passUnretained(self).toOpaque()

    guard
      let tap = CGEvent.tapCreate(
        tap: .cghidEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: mask,
        callback: scrollEventCallback,
        userInfo: refcon
      )
    else {
      scrollLog.error("tapCreate failed — process is not trusted for Accessibility")
      return false
    }

    let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)

    self.tap = tap
    self.runLoopSource = source
    scrollLog.info("Event tap installed and enabled")
    return true
  }

  func uninstall() {
    if let runLoopSource {
      CFRunLoopRemoveSource(
        CFRunLoopGetMain(),
        runLoopSource,
        .commonModes
      )
    }
    if let tap {
      CGEvent.tapEnable(tap: tap, enable: false)
    }
    runLoopSource = nil
    tap = nil
  }
}
