import ExpoModulesCore
import UIKit

public class RnProgresiveAlertModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ProgressiveAlert")

    Events("cancelled", "completed")

    AsyncFunction("showAsync") { (config: ProgressiveAlertConfigInput) async throws -> ProgressiveAlertShowResult in
      let presented = try await ProgressiveAlertManager.shared.show(config: config) { event in
        switch event {
        case .cancelled:
          self.sendEvent("cancelled")
        case .completed:
          self.sendEvent("completed")
        }
      }
      var result = ProgressiveAlertShowResult()
      result.presented = presented
      return result
    }

    AsyncFunction("updateAsync") { (progress: Double) in
      await ProgressiveAlertManager.shared.update(progress: progress)
    }

    AsyncFunction("dismissAsync") { () async -> ProgressiveAlertDismissResult in
      let dismissed = await ProgressiveAlertManager.shared.dismiss()
      var result = ProgressiveAlertDismissResult()
      result.dismissed = dismissed
      return result
    }
  }
}

// MARK: - ExpoModulesCore Records (bridge types)

internal struct ProgressiveAlertConfigInput: Record {
  @Field var title: String = ""
  @Field var message: String = ""
  @Field var tint: String? = nil
  @Field var initialProgress: Double = 0.0
  @Field var replaceIfPresented: Bool = true
  @Field var cancelTitle: String? = "Cancel"
  @Field var completeAutoDismiss: Bool = true
  @Field var forceFallback: Bool = false
  @Field var fallbackOffset: CGFloat = 50
}

internal struct ProgressiveAlertShowResult: Record {
  @Field var presented: Bool = false
}

internal struct ProgressiveAlertDismissResult: Record {
  @Field var dismissed: Bool = false
}
