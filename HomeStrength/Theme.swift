//
//  Theme.swift
//  HomeStrength
//
//  Design tokens: Apple Fitness / Reminders style — grouped backgrounds, soft cards, spacing.
//

import SwiftUI

enum HSTheme {
    // MARK: - Surfaces
    static let pageBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let tertiaryFill = Color(.tertiarySystemFill)

    // MARK: - Accent (single accent color — Apple Fitness / Reminders style)
    static let accent = Color(.systemBlue)
    /// Soft fill for selected states and emphasis (e.g. chips, streak banner)
    static let accentFill = Color(.systemBlue).opacity(0.15)

    // MARK: - Spacing (8pt grid, reduced density)
    static let spaceXS: CGFloat = 8
    static let spaceSM: CGFloat = 12
    static let spaceMD: CGFloat = 16
    static let spaceLG: CGFloat = 24
    static let spaceXL: CGFloat = 32
    static let spaceSection: CGFloat = 28
    static let contentPaddingH: CGFloat = 20
    static let contentPaddingV: CGFloat = 24

    // MARK: - Corner radius (soft cards)
    static let radiusSM: CGFloat = 10
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
}
