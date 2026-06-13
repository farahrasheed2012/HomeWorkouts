//
//  AppSettingsStore.swift
//  HomeStrength
//

import SwiftUI

@MainActor
final class AppSettingsStore: ObservableObject {
    private static let largeTextKey = "HomeStrength.largeText"
    private static let highContrastKey = "HomeStrength.highContrast"

    @Published var largeText: Bool {
        didSet { UserDefaults.standard.set(largeText, forKey: Self.largeTextKey) }
    }

    @Published var highContrast: Bool {
        didSet { UserDefaults.standard.set(highContrast, forKey: Self.highContrastKey) }
    }

    init() {
        largeText = UserDefaults.standard.bool(forKey: Self.largeTextKey)
        highContrast = UserDefaults.standard.bool(forKey: Self.highContrastKey)
    }
}
