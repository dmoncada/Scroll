import CoreGraphics
import Synchronization

private nonisolated let syntheticTag: Int64 = 0x5C20_11ED

nonisolated func scrollEventCallback(
  proxy: CGEventTapProxy,
  type: CGEventType,
  event: CGEvent,
  userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
  guard let userInfo else {
    return Unmanaged.passUnretained(event)
  }

  let controller = Unmanaged<EventTapController>
    .fromOpaque(userInfo)
    .takeUnretainedValue()

  if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
    controller.reEnable()
    return Unmanaged.passUnretained(event)
  }

  guard type == .scrollWheel else {
    return Unmanaged.passUnretained(event)
  }

  if event.getIntegerValueField(.eventSourceUserData) == syntheticTag {
    return Unmanaged.passUnretained(event)
  }

  guard
    controller.isEnabled.load(ordering: .relaxed),
    event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0
  else {
    return Unmanaged.passUnretained(event)
  }

  let line = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
  let point = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
  let fixedPt = event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1)

  let source = CGEventSource(event: event)
  guard
    let reversed = CGEvent(
      scrollWheelEvent2Source: source,
      units: .line,
      wheelCount: 1,
      wheel1: Int32(clamping: -line),
      wheel2: 0,
      wheel3: 0
    )
  else {
    return Unmanaged.passUnretained(event)
  }

  reversed.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: -point)
  reversed.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1, value: -fixedPt)
  reversed.setIntegerValueField(.eventSourceUserData, value: syntheticTag)

  return Unmanaged.passRetained(reversed)
}
