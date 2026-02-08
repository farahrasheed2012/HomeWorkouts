//
//  ExerciseDetail.swift
//  HomeStrength
//
//  Extended exercise info for library: description, steps, tips, muscles, targets, safety, difficulty levels (Easy/Medium/Difficult), placeholder image.
//

import Foundation

/// Difficulty level for exercise variations (prompt: "at least one variation per difficulty level").
enum DifficultyLevel: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case difficult = "Difficult"
    var id: String { rawValue }
}

struct ExerciseDetail: Identifiable {
    let id: UUID
    let exerciseName: String
    let equipment: Equipment
    let summary: String
    let steps: [String]
    let tips: [String]
    let muscles: [String]
    /// What the activity targets: e.g. "Coordination", "Balance", "Strength", "Flexibility".
    let targets: [String]
    /// Safety considerations (e.g. "Avoid rounding lower back").
    let safetyNote: String?
    /// Base difficulty of this exercise; variations listed below.
    let difficultyLevel: DifficultyLevel
    /// Easy variation (e.g. modification for beginners).
    let easyVariation: String?
    /// Medium variation description.
    let mediumVariation: String?
    /// Difficult/advanced variation description.
    let difficultVariation: String?
    /// Legacy: same as easyVariation when set.
    var modificationForBeginners: String? { easyVariation }
    /// Placeholder image name in Assets, or nil for SF Symbol.
    let imagePlaceholderName: String?
    /// If true, use fun kid-friendly wording in UI.
    let isKidFriendly: Bool
    
    init(id: UUID = UUID(), exerciseName: String, equipment: Equipment, summary: String, steps: [String], tips: [String], muscles: [String], targets: [String] = [], safetyNote: String? = nil, difficultyLevel: DifficultyLevel = .medium, easyVariation: String? = nil, mediumVariation: String? = nil, difficultVariation: String? = nil, imagePlaceholderName: String? = nil, isKidFriendly: Bool = false) {
        self.id = id
        self.exerciseName = exerciseName
        self.equipment = equipment
        self.summary = summary
        self.steps = steps
        self.tips = tips
        self.muscles = muscles
        self.targets = targets
        self.safetyNote = safetyNote
        self.difficultyLevel = difficultyLevel
        self.easyVariation = easyVariation
        self.mediumVariation = mediumVariation
        self.difficultVariation = difficultVariation
        self.imagePlaceholderName = imagePlaceholderName
        self.isKidFriendly = isKidFriendly
    }
}
