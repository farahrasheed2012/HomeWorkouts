//
//  ProgressStore.swift
//  HomeStrength
//
//  Persists completed workouts and provides metrics per user.
//

import Foundation
import SwiftUI

@MainActor
class ProgressStore: ObservableObject {
    private static let completedWorkoutsKey = "HomeStrength.completedWorkouts"
    
    @Published private(set) var completedWorkouts: [CompletedWorkout] = []
    
    init() {
        load()
    }
    
    func logWorkout(_ completed: CompletedWorkout) {
        completedWorkouts.append(completed)
        save()
    }
    
    func completed(forUserId userId: UUID) -> [CompletedWorkout] {
        completedWorkouts.filter { $0.userId == userId }.sorted { $0.completedAt > $1.completedAt }
    }
    
    func totalWorkoutsCount(userId: UUID) -> Int {
        completedWorkouts.filter { $0.userId == userId }.count
    }
    
    func workoutsThisWeek(userId: UUID) -> Int {
        let start = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return completedWorkouts.filter { $0.userId == userId && $0.completedAt >= start }.count
    }
    
    func workoutsThisMonth(userId: UUID) -> Int {
        let start = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return completedWorkouts.filter { $0.userId == userId && $0.completedAt >= start }.count
    }
    
    /// Consecutive days with at least one workout (counting backward from today).
    func currentStreakDays(userId: UUID) -> Int {
        let cal = Calendar.current
        let dates = Set(completedWorkouts.filter { $0.userId == userId }.map { cal.startOfDay(for: $0.completedAt) })
        var streak = 0
        var day = cal.startOfDay(for: Date())
        while dates.contains(day) {
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }
    
    /// Weight used for a given exercise (by name) for user - latest or history.
    func weightHistory(userId: UUID, exerciseName: String) -> [(Date, Double)] {
        var result: [(Date, Double)] = []
        for cw in completedWorkouts where cw.userId == userId {
            for le in cw.loggedExercises where le.exerciseName == exerciseName {
                for s in le.sets {
                    if let w = s.weightLbs {
                        result.append((cw.completedAt, w))
                    }
                }
            }
        }
        return result.sorted { $0.0 > $1.0 }
    }
    
    /// Vertical jump history for daughter profile.
    func verticalJumpHistory(userId: UUID) -> [(Date, Double)] {
        completedWorkouts
            .filter { $0.userId == userId }
            .compactMap { cw in cw.verticalJumpInches.map { jump in (cw.completedAt, jump) } }
            .sorted { $0.0 > $1.0 }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.completedWorkoutsKey),
              let decoded = try? JSONDecoder().decode([CompletedWorkout].self, from: data) else { return }
        completedWorkouts = decoded
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(completedWorkouts) else { return }
        UserDefaults.standard.set(data, forKey: Self.completedWorkoutsKey)
    }
}
