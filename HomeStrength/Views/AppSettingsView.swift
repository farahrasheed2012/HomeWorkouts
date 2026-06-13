//
//  AppSettingsView.swift
//  HomeStrength
//

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var appSettings: AppSettingsStore

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Large text", isOn: $appSettings.largeText)
                    Toggle("High contrast", isOn: $appSettings.highContrast)
                } footer: {
                    Text("Large text increases font sizes during workouts. High contrast makes secondary text easier to read on dark backgrounds.")
                }

                Section("Workout display") {
                    Label("Focused workout view with collapsible instructions", systemImage: "checkmark.circle.fill")
                    Label("Improved timer and control button sizes", systemImage: "checkmark.circle.fill")
                    Label("Respects system Dynamic Type", systemImage: "checkmark.circle.fill")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Display")
            .largeNavigationBarTitle()
        }
        .appReadabilitySettings(appSettings)
    }
}

#Preview {
    AppSettingsView()
        .environmentObject(AppSettingsStore())
}
