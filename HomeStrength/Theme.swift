//
//  Theme.swift
//  HomeStrength
//
//  Design tokens: Apple Fitness / Reminders style — grouped backgrounds, soft cards, spacing.
//

import SwiftUI

enum HSTheme {
    // MARK: - Surfaces
    static let pageBackground = PlatformColor.groupedBackground
    static let cardBackground = PlatformColor.secondaryGroupedBackground
    static let tertiaryFill = PlatformColor.tertiaryFill

    // MARK: - Layout
    static let workoutContentMaxWidth: CGFloat = 720

    // MARK: - Accent (single accent color — Apple Fitness / Reminders style)
    static let accent = PlatformColor.systemBlue
    /// Soft fill for selected states and emphasis (e.g. chips, streak banner)
    static let accentFill = PlatformColor.systemBlue.opacity(0.15)

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

    // MARK: - Typography roles
    enum FontRole {
        case workoutTitle
        case workoutSubtitle
        case workoutBody
        case workoutMeta
        case sectionHeader
        case timer
        case timerLabel
        case controlButton
    }

    static func font(_ role: FontRole, largeText: Bool) -> Font {
        switch role {
        case .workoutTitle:
            return largeText ? .title.bold() : .title2.weight(.semibold)
        case .workoutSubtitle:
            return largeText ? .title3.weight(.medium) : .headline
        case .workoutBody:
            return largeText ? .body : .callout
        case .workoutMeta:
            return largeText ? .callout.weight(.medium) : .subheadline
        case .sectionHeader:
            return largeText ? .headline : .subheadline.weight(.semibold)
        case .timer:
            return .system(size: largeText ? 36 : 28, weight: .bold, design: .rounded)
        case .timerLabel:
            return largeText ? .subheadline : .caption
        case .controlButton:
            return largeText ? .body.weight(.semibold) : .subheadline.weight(.semibold)
        }
    }

    static func secondaryText(highContrast: Bool) -> Color {
        highContrast ? Color.primary.opacity(0.82) : Color.secondary
    }

    static func metaText(highContrast: Bool) -> Color {
        highContrast ? Color.secondary : Color.secondary
    }
}
