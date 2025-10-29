import Foundation
import UIKit

@MainActor
final class ProgressiveAlertManager {
    static let shared: ProgressiveAlertManager = ProgressiveAlertManager()
    
    enum Event {
        case cancelled
        case completed
    }
    
    private weak var alertController: UIAlertController?
    private weak var progressBar: UIProgressView?
    private weak var hostView: UIView?
    private var eventHandler: ((Event) -> Void)?
    private var shouldAutoDismissOnComplete: Bool = true
    
    private init() {}
    
    // MARK: - Public Methods
    
    func show(config: ProgressiveAlertConfigInput, onEvent: ((Event) -> Void)?) async throws -> Bool {
        self.eventHandler = onEvent
        self.shouldAutoDismissOnComplete = config.completeAutoDismiss
        
        // Update existing alert if present
        if let existing = alertController, existing.presentingViewController != nil {
            if config.replaceIfPresented {
                _ = await dismiss()
            } else {
                existing.title = config.title
                existing.message = config.message
                // Re-attach progress bar with updated config
                attachProgressBar(to: existing, config: config)
                return true
            }
        }
        
        guard let presenter = currentViewController() else { return false }
        
       let alert = UIAlertController(
    title: config.title,
    message: "\(config.message)\(config.forceFallback ? "" : "\n")",
    preferredStyle: .alert
)

        if let cancelTitle = config.cancelTitle, !cancelTitle.isEmpty {
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { [weak self] _ in
                self?.eventHandler?(.cancelled)
                self?.cleanup()
            }
            alert.addAction(cancel)
        }
        
        presenter.present(alert, animated: true)
        self.alertController = alert
        
        // Attach progress bar after presentation with the same delay as SwiftUI version
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [weak self] in
            self?.attachProgressBar(to: alert, config: config)
        }
        
        return true
    }
    
    func update(progress: Double) async {
        let clamped = progress.clamped01
        progressBar?.setProgress(Float(clamped), animated: true)
        
        // Ensure layout is up to date so the visual fill reflects correctly
        hostView?.setNeedsLayout()
        hostView?.layoutIfNeeded()
        
        // Apply again on next runloop to catch any late layout from alert animations
        DispatchQueue.main.async { [weak self] in
            self?.progressBar?.setProgress(Float(clamped), animated: true)
        }
        
        if clamped >= 1.0 {
            eventHandler?(.completed)
            if shouldAutoDismissOnComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    Task { @MainActor in
                        _ = await self?.dismiss()
                    }
                }
            }
        }
    }
    
    func dismiss() async -> Bool {
        guard let alert = alertController else { return false }
        alert.dismiss(animated: true)
        cleanup()
        return true
    }
    
    // MARK: - Private Methods
    
    private func cleanup() {
        alertController = nil
        progressBar = nil
        hostView = nil
        eventHandler = nil
        shouldAutoDismissOnComplete = true
    }
    
    private func attachProgressBar(to controller: UIAlertController, config: ProgressiveAlertConfigInput) {
        // Avoid adding twice
        if progressBar != nil { return }
        
        // Try to find a better content container inside the alert view hierarchy
        let containerView: UIView
        if let contentContainer = controller.view.subviews
            .flatMap({ $0.subviews })
            .first(where: { 
                String(describing: type(of: $0)).contains("ContentView") || 
                String(describing: type(of: $0)).contains("ScrollView") 
            }) {
            containerView = contentContainer
        } else {
            // Fallback to the controller.view if we cannot find a content container
            containerView = controller.view
        }
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.tintColor = colorFromString(config.tint)
        progressView.trackTintColor = .systemGray5
        progressView.progress = Float(config.initialProgress.clamped01)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(progressView)
        
        // EXACT COPY from SwiftUI version - Determine offset
        var offset = config.fallbackOffset  // fallbackOffset
        
        // Try to find the GroupHeaderScrollView for precise positioning (like SwiftUI version)

        if !config.forceFallback {
            if let contentView = controller.view.allSubViews().first(where: {
                String(describing: type(of: $0)).contains("GroupHeaderScrollView")
            }) {
                offset = contentView.frame.height - (isIos26 ? 8 : 20)
            }
        }

        progressView.topAnchor.constraint(equalTo: controller.view.topAnchor, constant : offset).isActive = true


        // EXACT COPY from SwiftUI version - Constraints
        let padding: CGFloat = isIos26 ? 30 : 15
        NSLayoutConstraint.activate([
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            progressView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: offset)
        ])
        
        // EXACT COPY from SwiftUI version - Force layout
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        
        self.progressBar = progressView
        self.hostView = containerView
        
        // EXACT COPY from SwiftUI version - Apply again on next runloop
        DispatchQueue.main.async {
            progressView.setProgress(Float(config.initialProgress.clamped01), animated: false)
        }
    }
    
    // MARK: - iOS Version Detection
    
    private var isIos26: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }
    
    // MARK: - Helper Methods
    
    private func currentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.keyWindow?.rootViewController else {
            return nil
        }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
    
    private func colorFromString(_ colorString: String?) -> UIColor {
        guard let colorString = colorString else { return .systemBlue }
        
        switch colorString.lowercased() {
        case "blue": return .systemBlue
        case "red": return .systemRed
        case "green": return .systemGreen
        case "orange": return .systemOrange
        case "purple": return .systemPurple
        case "yellow": return .systemYellow
        case "teal": return .systemTeal
        case "indigo": return .systemIndigo
        case "pink": return .systemPink
        case "gray", "grey": return .systemGray
        default: 
            // Try to parse hex color
            if let hexColor = UIColor.fromHexString(colorString) {
                return hexColor
            }
            return .systemBlue
        }
    }
}

// MARK: - UIView Extensions (EXACT COPY from SwiftUI version)

private extension UIView {
    func allSubViews() -> [UIView] {
        subviews + subviews.flatMap { $0.allSubViews() }
    }
}

private extension Double {
    var clamped01: Double { max(0, min(1, self)) }
}

// MARK: - UIWindowScene keyWindow helper (EXACT COPY from SwiftUI version)

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        // Prefer the active foreground window
        windows.first(where: { $0.isKeyWindow }) ?? windows.first
    }
}

// MARK: - UIColor Hex Extension

private extension UIColor {
    static func fromHexString(_ hexString: String) -> UIColor? {
        var str = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6 || str.count == 8 else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: str).scanHexInt64(&value) else { return nil }

        let r, g, b, a: CGFloat
        if str.count == 6 {
            r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            g = CGFloat((value & 0x00FF00) >> 8) / 255.0
            b = CGFloat(value & 0x0000FF) / 255.0
            a = 1.0
        } else {
            r = CGFloat((value & 0xFF000000) >> 24) / 255.0
            g = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((value & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(value & 0x000000FF) / 255.0
        }
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
