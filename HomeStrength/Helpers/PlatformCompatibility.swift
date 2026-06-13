import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum PlatformColor {
    static var groupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    static var secondaryGroupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var tertiaryFill: Color {
        #if os(iOS)
        Color(uiColor: .tertiarySystemFill)
        #else
        Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
        #endif
    }

    static var tertiaryGroupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .tertiarySystemGroupedBackground)
        #else
        Color(nsColor: .textBackgroundColor)
        #endif
    }

    static var systemBlue: Color {
        #if os(iOS)
        Color(uiColor: .systemBlue)
        #else
        Color(nsColor: .systemBlue)
        #endif
    }
}

extension View {
    @ViewBuilder
    func inlineNavigationBarTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func largeNavigationBarTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }

    @ViewBuilder
    func platformListStyle() -> some View {
        #if os(macOS)
        listStyle(.inset(alternatesRowBackgrounds: true))
        #else
        listStyle(.insetGrouped)
        #endif
    }

    @ViewBuilder
    func platformNumberPadKeyboard() -> some View {
        #if os(iOS)
        keyboardType(.numberPad)
        #else
        self
        #endif
    }

    @ViewBuilder
    func platformDecimalPadKeyboard() -> some View {
        #if os(iOS)
        keyboardType(.decimalPad)
        #else
        self
        #endif
    }

    @ViewBuilder
    func platformScrollContentBackgroundHidden() -> some View {
        #if os(iOS)
        scrollContentBackground(.hidden)
        #else
        self
        #endif
    }
}

extension ToolbarItemPlacement {
    static var platformLeading: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .navigation
        #endif
    }
}

extension View {
    @ViewBuilder
    func platformFullScreenCover<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(item: item, onDismiss: onDismiss, content: content)
        #else
        sheet(item: item, onDismiss: onDismiss) { value in
            content(value)
                .frame(minWidth: 720, minHeight: 520)
        }
        #endif
    }

    @ViewBuilder
    func platformFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: content)
        #else
        sheet(isPresented: isPresented, onDismiss: onDismiss) {
            content()
                .frame(minWidth: 720, minHeight: 520)
        }
        #endif
    }
}
