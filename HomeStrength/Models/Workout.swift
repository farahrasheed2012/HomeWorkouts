//
//  Workout.swift
//  HomeStrength
//

import Foundation

/// Primary muscle group or focus for a workout. Used to filter and browse by target area.
enum MuscleGroup: String, Codable, CaseIterable, Hashable {
    case fullBody = "Full Body"
    case upperBody = "Upper Body"
    case legs = "Legs"
    case glutes = "Glutes"
    case back = "Back"
    case chest = "Chest"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"
    case cardio = "Cardio"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .fullBody: return "figure.arms.open"
        case .upperBody: return "figure.arms.open"
        case .legs: return "figure.walk"
        case .glutes: return "figure.strengthtraining.functional"
        case .back: return "figure.cooldown"
        case .chest: return "figure.strengthtraining.traditional"
        case .shoulders: return "figure.arms.open"
        case .arms: return "dumbbell.fill"
        case .core: return "figure.core.training"
        case .cardio: return "heart.fill"
        }
    }
}

struct Workout: Identifiable, Hashable {
    let id: UUID
    var name: String
    var summary: String
    var exercises: [Exercise]
    var estimatedMinutes: Int
    /// Which profile this workout is for (mom vs daughter).
    var profileType: UserProfileType
    /// Primary muscle group(s) this workout targets. Used for filtering.
    var primaryFocus: MuscleGroup?
    
    init(id: UUID = UUID(), name: String, summary: String, exercises: [Exercise], estimatedMinutes: Int, profileType: UserProfileType = .mom, primaryFocus: MuscleGroup? = nil) {
        self.id = id
        self.name = name
        self.summary = summary
        self.exercises = exercises
        self.estimatedMinutes = estimatedMinutes
        self.profileType = profileType
        self.primaryFocus = primaryFocus
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Workout, rhs: Workout) -> Bool { lhs.id == rhs.id }
}
