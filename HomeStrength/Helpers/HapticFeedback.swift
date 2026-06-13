#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum HapticFeedback {
    static func impact(_ style: ImpactStyle = .medium) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: style.uiKitStyle).impactOccurred()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }

    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
        #endif
    }
}

#if os(iOS)
enum ImpactStyle {
    case light, medium, heavy

    var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        }
    }
}
#else
enum ImpactStyle {
    case light, medium, heavy
}
#endif
