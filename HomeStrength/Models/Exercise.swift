//
//  Exercise.swift
//  HomeStrength
//
//  A single exercise in a workout. Beginner-friendly, at-home equipment.
//

import Foundation

enum Equipment: String, Codable, CaseIterable, Hashable {
    case dumbbells = "Dumbbells"
    case resistanceBands = "Resistance Bands"
    case homeGym = "Home Gym"
    case treadmill = "Treadmill"
    case exerciseBike = "Exercise Bike"
    case bodyweight = "Bodyweight"
    case yogaMat = "Yoga Mat"
    
    var icon: String {
        switch self {
        case .dumbbells: return "dumbbell.fill"
        case .resistanceBands: return "bandage.fill"
        case .homeGym: return "figure.strengthtraining.traditional"
        case .treadmill: return "figure.run"
        case .exerciseBike: return "bicycle"
        case .bodyweight: return "figure.arms.open"
        case .yogaMat: return "figure.yoga"
        }
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var equipment: Equipment
    var instructions: String?
    var sets: Int
    /// e.g. "10" or "8–12" or "30 sec"
    var reps: String
    var restSeconds: Int
    
    init(id: UUID = UUID(), name: String, equipment: Equipment, instructions: String? = nil, sets: Int, reps: String, restSeconds: Int = 60) {
        self.id = id
        self.name = name
        self.equipment = equipment
        self.instructions = instructions
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
    }
}
