//
//  GroupFitness.swift
//  HomeStrength
//
//  Models for group fitness classes: routines (30–45 min), sections, exercises with level options, and class logs.
//

import Foundation

/// Class format / focus for the routine.
enum GroupClassFormat: String, Codable, CaseIterable, Hashable {
    case fullBody = "Full-body"
    case upperBody = "Upper body focus"
    case lowerBody = "Lower body (pelvic floor safe)"
    case coreRebuilding = "Core rebuilding (postpartum-friendly)"
    case cardioHIIT = "Cardio / high-intensity"
    case lowImpact = "Low-impact / gentle (postpartum)"
    
    var icon: String {
        switch self {
        case .fullBody: return "figure.arms.open"
        case .upperBody: return "figure.arms.open"
        case .lowerBody: return "figure.walk"
        case .coreRebuilding: return "figure.core.training"
        case .cardioHIIT: return "figure.highintensity.intervaltraining"
        case .lowImpact: return "figure.mind.and.body"
        }
    }
}

/// One exercise in a group routine, with options for each level.
struct GroupFitnessExercise: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var lowKeyOption: String      // Postpartum/beginner
    var intermediateOption: String
    var proOption: String        // Advanced
    /// Duration per side or per set (e.g. 30 seconds).
    var durationSeconds: Int
    var restSeconds: Int
    var postpartumSafe: Bool
    var formNotes: String?
    /// Instructor callouts (e.g. "Keep breathing", "Modify if needed").
    var motivationalCues: [String]
    /// Detailed steps for leading the exercise (optional; can also come from GroupFitnessExerciseDetailStore).
    var steps: [String]
    /// Short summary/instructions for the exercise.
    var summary: String?
    /// Instructor tips (e.g. "Keep knees over toes", "Exhale on exertion").
    var tips: [String]
    /// Placeholder image name for the exercise (e.g. in Assets).
    var imagePlaceholderName: String?
    
    init(id: UUID = UUID(), name: String, lowKeyOption: String, intermediateOption: String, proOption: String, durationSeconds: Int = 30, restSeconds: Int = 15, postpartumSafe: Bool = false, formNotes: String? = nil, motivationalCues: [String] = [], steps: [String] = [], summary: String? = nil, tips: [String] = [], imagePlaceholderName: String? = nil) {
        self.id = id
        self.name = name
        self.lowKeyOption = lowKeyOption
        self.intermediateOption = intermediateOption
        self.proOption = proOption
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.postpartumSafe = postpartumSafe
        self.formNotes = formNotes
        self.motivationalCues = motivationalCues
        self.steps = steps
        self.summary = summary
        self.tips = tips
        self.imagePlaceholderName = imagePlaceholderName
    }
}

/// A section of the class (warm-up, main block, cool-down).
struct GroupFitnessSection: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var durationMinutes: Int
    var exercises: [GroupFitnessExercise]
    var bpmSuggested: Int?
    var instructorCues: [String]
    
    init(id: UUID = UUID(), name: String, durationMinutes: Int, exercises: [GroupFitnessExercise], bpmSuggested: Int? = nil, instructorCues: [String] = []) {
        self.id = id
        self.name = name
        self.durationMinutes = durationMinutes
        self.exercises = exercises
        self.bpmSuggested = bpmSuggested
        self.instructorCues = instructorCues
    }
}

/// Full 30–45 minute routine for leading a class.
struct GroupFitnessRoutine: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var format: GroupClassFormat
    var estimatedMinutes: Int
    var warmUp: GroupFitnessSection
    var mainSections: [GroupFitnessSection]
    var coolDown: GroupFitnessSection
    var spaceRequirements: String
    var generalNotes: String?
    /// Optional: notes on scaling based on group energy/feedback.
    var scalingNotes: String?
    
    init(id: UUID = UUID(), name: String, format: GroupClassFormat, estimatedMinutes: Int, warmUp: GroupFitnessSection, mainSections: [GroupFitnessSection], coolDown: GroupFitnessSection, spaceRequirements: String, generalNotes: String? = nil, scalingNotes: String? = nil) {
        self.id = id
        self.name = name
        self.format = format
        self.estimatedMinutes = estimatedMinutes
        self.warmUp = warmUp
        self.mainSections = mainSections
        self.coolDown = coolDown
        self.spaceRequirements = spaceRequirements
        self.generalNotes = generalNotes
        self.scalingNotes = scalingNotes
    }
}

/// Scaled view of a section for a target class duration (proportional scaling of times).
struct ScaledSectionView: Identifiable {
    let id: UUID
    let name: String
    let durationMinutes: Int
    let exercises: [ScaledExerciseView]
    let bpmSuggested: Int?
    let instructorCues: [String]
}

/// Scaled work/rest for one exercise when routine is run at a different duration.
struct ScaledExerciseView: Identifiable {
    let id: UUID
    let name: String
    let workSeconds: Int
    let restSeconds: Int
    let lowKeyOption: String
    let intermediateOption: String
    let proOption: String
    let postpartumSafe: Bool
    let formNotes: String?
    let motivationalCues: [String]
    let steps: [String]
    let summary: String?
    let tips: [String]
    let imagePlaceholderName: String?
}

extension GroupFitnessRoutine {
    /// Scale section durations and exercise work/rest to target total minutes.
    /// Uses proportional scaling; rounds section mins and exercise secs to sensible values.
    func scaled(toTargetMinutes target: Int) -> (warmUp: ScaledSectionView, mainSections: [ScaledSectionView], coolDown: ScaledSectionView, displayMinutes: Int) {
        let base = estimatedMinutes
        let scale = base > 0 ? Double(target) / Double(base) : 1.0
        
        func roundMinutes(_ d: Double) -> Int {
            max(1, Int(d.rounded()))
        }
        func roundSeconds(_ d: Double) -> Int {
            let s = Int(d.rounded())
            if s <= 0 { return 5 }
            if s <= 10 { return max(5, (s / 5) * 5) }
            return (s / 5) * 5
        }
        
        func scaleSection(_ s: GroupFitnessSection) -> ScaledSectionView {
            ScaledSectionView(
                id: s.id,
                name: s.name,
                durationMinutes: roundMinutes(Double(s.durationMinutes) * scale),
                exercises: s.exercises.map { ex in
                    ScaledExerciseView(
                        id: ex.id,
                        name: ex.name,
                        workSeconds: roundSeconds(Double(ex.durationSeconds) * scale),
                        restSeconds: roundSeconds(Double(ex.restSeconds) * scale),
                        lowKeyOption: ex.lowKeyOption,
                        intermediateOption: ex.intermediateOption,
                        proOption: ex.proOption,
                        postpartumSafe: ex.postpartumSafe,
                        formNotes: ex.formNotes,
                        motivationalCues: ex.motivationalCues,
                        steps: ex.steps,
                        summary: ex.summary,
                        tips: ex.tips,
                        imagePlaceholderName: ex.imagePlaceholderName
                    )
                },
                bpmSuggested: s.bpmSuggested,
                instructorCues: s.instructorCues
            )
        }
        
        return (
            warmUp: scaleSection(warmUp),
            mainSections: mainSections.map(scaleSection),
            coolDown: scaleSection(coolDown),
            displayMinutes: target
        )
    }
}

/// Log of a class you led (for tracking and feedback).
struct GroupClassLog: Identifiable, Codable {
    var id: UUID
    var userId: UUID
    var routineId: UUID
    var routineName: String
    var classFormat: GroupClassFormat
    var date: Date
    var participantCount: Int?
    var notes: String?
    /// Duration actually used (optional).
    var durationMinutes: Int?
    
    init(id: UUID = UUID(), userId: UUID, routineId: UUID, routineName: String, classFormat: GroupClassFormat, date: Date = Date(), participantCount: Int? = nil, notes: String? = nil, durationMinutes: Int? = nil) {
        self.id = id
        self.userId = userId
        self.routineId = routineId
        self.routineName = routineName
        self.classFormat = classFormat
        self.date = date
        self.participantCount = participantCount
        self.notes = notes
        self.durationMinutes = durationMinutes
    }
}
