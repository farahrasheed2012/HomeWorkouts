//
//  Workout.swift
//  HomeStrength
//

import Foundation

struct Workout: Identifiable, Hashable {
    let id: UUID
    var name: String
    var summary: String
    var exercises: [Exercise]
    var estimatedMinutes: Int
    /// Which profile this workout is for (mom vs daughter).
    var profileType: UserProfileType
    
    init(id: UUID = UUID(), name: String, summary: String, exercises: [Exercise], estimatedMinutes: Int, profileType: UserProfileType = .mom) {
        self.id = id
        self.name = name
        self.summary = summary
        self.exercises = exercises
        self.estimatedMinutes = estimatedMinutes
        self.profileType = profileType
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Workout, rhs: Workout) -> Bool { lhs.id == rhs.id }
}
