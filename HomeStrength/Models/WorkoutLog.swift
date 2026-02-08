//
//  WorkoutLog.swift
//  HomeStrength
//
//  Logged completed workouts and exercise results for tracking and metrics.
//

import Foundation

/// One completed set: reps done and optional weight used.
struct LoggedSet: Codable, Hashable {
    var reps: String  // e.g. "10" or "30 sec"
    var weightLbs: Double?
}

/// Result for one exercise in a completed workout.
struct LoggedExercise: Codable, Hashable {
    var exerciseId: UUID
    var exerciseName: String
    var sets: [LoggedSet]
}

/// A completed workout session for one user.
struct CompletedWorkout: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var workoutId: UUID
    var workoutName: String
    var completedAt: Date
    var durationMinutes: Int?
    var loggedExercises: [LoggedExercise]
    /// Optional: vertical jump (inches) - for daughter profile.
    var verticalJumpInches: Double?
    /// Optional: notes (e.g. serving practice).
    var notes: String?
    
    init(id: UUID = UUID(), userId: UUID, workoutId: UUID, workoutName: String, completedAt: Date = Date(), durationMinutes: Int? = nil, loggedExercises: [LoggedExercise], verticalJumpInches: Double? = nil, notes: String? = nil) {
        self.id = id
        self.userId = userId
        self.workoutId = workoutId
        self.workoutName = workoutName
        self.completedAt = completedAt
        self.durationMinutes = durationMinutes
        self.loggedExercises = loggedExercises
        self.verticalJumpInches = verticalJumpInches
        self.notes = notes
    }
}
