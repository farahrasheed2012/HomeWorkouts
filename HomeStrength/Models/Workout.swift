//
//  Workout.swift
//  HomeStrength
//

import Foundation

/// Date-seeded RNG so the same calendar day produces the same "today's" exercise subset.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

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
    /// When set, each day a random subset of this many exercises is shown (from exercises pool). Nil = use all exercises.
    var targetExerciseCount: Int?
    
    init(id: UUID = UUID(), name: String, summary: String, exercises: [Exercise], estimatedMinutes: Int, profileType: UserProfileType = .mom, primaryFocus: MuscleGroup? = nil, targetExerciseCount: Int? = 6) {
        self.id = id
        self.name = name
        self.summary = summary
        self.exercises = exercises
        self.estimatedMinutes = estimatedMinutes
        self.profileType = profileType
        self.primaryFocus = primaryFocus
        self.targetExerciseCount = targetExerciseCount
    }
    
    /// Exercises to show for "today": if pool has more than targetExerciseCount, returns a date-seeded random subset; otherwise returns all.
    func exercisesForToday() -> [Exercise] {
        let pool = exercises
        let count = targetExerciseCount ?? pool.count
        if pool.count <= count { return pool }
        let day = Calendar.current.startOfDay(for: Date())
        var rng = SeededRandomNumberGenerator(seed: UInt64(bitPattern: Int64(day.timeIntervalSince1970)))
        let indices = Array(0..<pool.count).shuffled(using: &rng)
        return (0..<count).map { pool[indices[$0]] }
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Workout, rhs: Workout) -> Bool { lhs.id == rhs.id }
}
