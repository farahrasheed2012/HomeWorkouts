//
//  HomeStrengthApp.swift
//  HomeStrength
//
//  Two profiles: Mom (at-home strength) and Daughter (volleyball). Track workouts and progress.
//

import SwiftUI

@main
struct HomeStrengthApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var workoutStore = WorkoutStore()
    @StateObject private var progressStore = ProgressStore()
    @StateObject private var groupFitnessStore = GroupFitnessStore()
    @StateObject private var appSettings = AppSettingsStore()
    
    var body: some Scene {
        WindowGroup {
            if let _ = userStore.currentUser {
                MainTabView()
                    .environmentObject(userStore)
                    .environmentObject(workoutStore)
                    .environmentObject(progressStore)
                    .environmentObject(groupFitnessStore)
                    .environmentObject(appSettings)
                    .appReadabilitySettings(appSettings)
            } else {
                UserSelectionView()
                    .environmentObject(userStore)
            }
        }
    }
}
