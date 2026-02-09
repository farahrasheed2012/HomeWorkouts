//
//  WorkoutGenerator.swift
//  HomeStrength
//
//  Random workout generator: creates custom routines from exercise library by equipment, duration, intensity, and focus.
//

import Foundation

enum GeneratorDuration: Int, CaseIterable, Identifiable {
    case min10 = 10
    case min15 = 15
    case min20 = 20
    case min25 = 25
    case min30 = 30
    case min40 = 40
    case min45 = 45
    case min60 = 60
    var minutes: Int { rawValue }
    var label: String { "\(rawValue) min" }
    var id: Int { rawValue }
}

enum GeneratorIntensity: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case difficult = "Difficult"
    var id: String { rawValue }
    /// For internal logic (same as before).
    var isLowKey: Bool { self == .easy }
    var isHighIntensity: Bool { self == .difficult }
}

enum MuscleFocus: String, CaseIterable, Identifiable {
    case fullBody = "Full body"
    case upperBody = "Upper body"
    case lowerBody = "Lower body"
    case core = "Core"
    case cardio = "Cardio"
    var id: String { rawValue }
}

/// For young kids: simplified inputs.
enum KidDuration: String, CaseIterable, Identifiable {
    case short = "Short (5–8 min)"
    case medium = "Medium (10–12 min)"
    case long = "Long (15 min)"
    var id: String { rawValue }
    var approximateMinutes: Int {
        switch self {
        case .short: return 6
        case .medium: return 11
        case .long: return 15
        }
    }
}

enum KidEnergyLevel: String, CaseIterable, Identifiable {
    case chill = "Chill"
    case medium = "Medium"
    case superEnergy = "Super!"
    var id: String { rawValue }
}

struct WorkoutGenerator {
    
    /// Focus for each exercise name (for filtering). Exercises not listed default to fullBody.
    private static let focusMap: [String: MuscleFocus] = [
        "Goblet Squat": .lowerBody, "Dumbbell Row": .upperBody, "Dumbbell Floor Press": .upperBody,
        "Dumbbell Shoulder Press": .upperBody, "Dumbbell Romanian Deadlift": .lowerBody,
        "Dumbbell Bicep Curl": .upperBody, "Tricep Extension": .upperBody, "Dumbbell Lunge": .lowerBody,
        "Band Pull-Apart": .upperBody, "Band Chest Stretch / Push": .upperBody, "Band Glute Bridge": .lowerBody,
        "Leg Press": .lowerBody, "Chest Press": .upperBody,
        "Chest Press (V4 Elite)": .upperBody, "Vertical Press (V4 Elite)": .upperBody, "Incline Press (V4 Elite)": .upperBody,
        "Pectoral Fly (V4 Elite)": .upperBody, "One Arm Pectoral Fly (V4 Elite)": .upperBody, "Pectoral Crossover (V4 Elite)": .upperBody, "Punch (V4 Elite)": .upperBody,
        "Shoulder Press (V4 Elite)": .upperBody, "Lateral Deltoid (V4 Elite)": .upperBody, "Seated Rear Delt (V4 Elite)": .upperBody, "High Pull (V4 Elite)": .upperBody, "Upright Row (V4 Elite)": .upperBody, "Shoulder Shrug (V4 Elite)": .upperBody, "Rotator Cuff - External (V4 Elite)": .upperBody,
        "Lat Pulldown (V4 Elite)": .upperBody, "Kneeling Lat Pulldown (V4 Elite)": .upperBody, "Standing One Arm Row (V4 Elite)": .upperBody, "One Arm Row (V4 Elite)": .upperBody, "Seated Row (V4 Elite)": .upperBody,
        "Bicep Curl (V4 Elite)": .upperBody, "Overhead Curl (V4 Elite)": .upperBody, "Tricep Pushdown (V4 Elite)": .upperBody, "One Arm Triceps Extension (V4 Elite)": .upperBody, "Tricep Bench (V4 Elite)": .upperBody, "Seated Triceps Extension (V4 Elite)": .upperBody,
        "Leg Extension (V4 Elite)": .lowerBody, "Leg Curl (V4 Elite)": .lowerBody, "Stationary Leg Press (V4 Elite)": .lowerBody, "Ride Leg Press (V4 Elite)": .lowerBody, "Standing Leg Curl (V4 Elite)": .lowerBody, "Standing Leg Extension (V4 Elite)": .lowerBody,
        "Stationary Calf Raise (V4 Elite)": .lowerBody, "Ride Calf Raise (V4 Elite)": .lowerBody, "Inner Thigh (V4 Elite)": .lowerBody, "Outer Thigh (V4 Elite)": .lowerBody, "Assisted Lunge (V4 Elite)": .lowerBody, "Glute Kick (V4 Elite)": .lowerBody, "High Step (V4 Elite)": .lowerBody,
        "Leg Press (Machine)": .lowerBody, "Calf Raises (Leg Press)": .lowerBody,
        "Ab Crunch (V4 Elite)": .core, "Side Bends (V4 Elite)": .core, "Torso Rotation (V4 Elite)": .core, "Golf Swing (V4 Elite)": .core, "Twist & Lift (V4 Elite)": .core,
        "Glute Bridge": .lowerBody,
        "Plank": .core, "Calf Raises": .lowerBody, "Treadmill Walk/Jog": .cardio, "Exercise Bike": .cardio,
        "Jump Squats": .lowerBody, "Bicep Curl": .upperBody, "Romanian Deadlift": .lowerBody,
        "Cat-Cow": .core, "Child's Pose": .core, "Downward Dog": .fullBody, "Hip Stretch": .lowerBody,
    ]
    
    /// Yoga mat / stretch-style exercises (bodyweight, mat-friendly).
    private static var yogaMatExercises: [Exercise] {
        [
            Exercise(name: "Cat-Cow", equipment: .yogaMat, instructions: "On all fours, round spine then arch. Breathe with the movement.", sets: 2, reps: "8", restSeconds: 15),
            Exercise(name: "Child's Pose", equipment: .yogaMat, instructions: "Knees under hips, fold forward, arms extended. Hold and breathe.", sets: 2, reps: "30 sec", restSeconds: 20),
            Exercise(name: "Downward Dog", equipment: .yogaMat, instructions: "Hips up, heels toward floor. Stretch hamstrings and shoulders.", sets: 2, reps: "30 sec", restSeconds: 20),
            Exercise(name: "Hip Stretch", equipment: .yogaMat, instructions: "Seated or supine hip opener. Hold 20–30 sec each side.", sets: 2, reps: "30 sec", restSeconds: 15),
        ]
    }
    
    private static var adultExercisePool: [Exercise] {
        var pool = WorkoutStore.exerciseLibrary.map { ex in
            Exercise(id: ex.id, name: ex.name, equipment: ex.equipment, instructions: ex.instructions, sets: ex.sets, reps: ex.reps, restSeconds: ex.restSeconds)
        }
        pool.append(contentsOf: yogaMatExercises)
        return pool
    }
    
    /// Kid activity pool: name, instructions, duration hint (seconds), energy (chill/medium/super).
    private static let kidActivityPool: [(name: String, instructions: String, durationSec: Int, energy: KidEnergyLevel)] = [
        ("Frog jumps", "Squat and jump like a frog! Land softly.", 30, .medium),
        ("Bear crawl", "Walk on hands and feet like a bear.", 25, .medium),
        ("Bunny hops", "Hop in place or forward like a bunny.", 20, .chill),
        ("Star jumps", "Jump and spread arms and legs like a star!", 25, .superEnergy),
        ("Dance party", "Put on music and dance any way you want!", 60, .superEnergy),
        ("Reach for the sky", "Reach your arms up high and stretch.", 20, .chill),
        ("March in place", "March like a soldier. Lift those knees!", 30, .medium),
        ("Flap like a bird", "Flap your arms like wings. Fly around!", 25, .medium),
        ("Crab walk", "Walk on hands and feet like a crab.", 25, .medium),
        ("One-foot balance", "Stand on one foot. Can you count to 10?", 20, .chill),
        ("Butterfly stretch", "Sit, feet together, flap knees like butterfly wings.", 30, .chill),
        ("Spin slowly", "Spin in a circle. Stop if you feel dizzy!", 15, .medium),
        ("Clap and jump", "Clap once, jump once. Repeat!", 25, .superEnergy),
    ]
    
    // MARK: - Generate for adult/teen (Mom, Middle School Daughter)
    
    static func generate(
        equipment: Set<Equipment>,
        duration: GeneratorDuration,
        intensity: GeneratorIntensity,
        focus: MuscleFocus?,
        profileType: UserProfileType
    ) -> Workout {
        var pool = adultExercisePool.filter { equipment.isEmpty || equipment.contains($0.equipment) }
        if let focus = focus, focus != .fullBody {
            pool = pool.filter { focusForExercise($0.name) == focus }
        }
        if pool.isEmpty {
            pool = adultExercisePool.filter { $0.equipment == .bodyweight }
        }
        guard !pool.isEmpty else {
            return fallbackWorkout(profileType: profileType, duration: duration)
        }
        
        let targetMinutes = duration.minutes
        let (setsMultiplier, restMultiplier, exerciseCount): (Double, Double, Int) = {
            switch intensity {
            case .easy: return (0.8, 1.3, max(4, targetMinutes / 6))
            case .medium: return (1.0, 1.0, max(5, targetMinutes / 5))
            case .difficult: return (1.2, 0.75, max(6, targetMinutes / 4))
            }
        }()
        
        let selected = Array(pool.shuffled().prefix(exerciseCount * 2)).shuffled().prefix(exerciseCount)
        var exercises: [Exercise] = []
        for ex in selected {
            var e = ex
            e.sets = max(2, Int(Double(e.sets) * setsMultiplier))
            e.restSeconds = max(30, min(90, Int(Double(e.restSeconds) * restMultiplier)))
            if intensity == .easy, e.reps.contains("sec") == false, let num = Int(e.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()), num > 8 {
                e.reps = "\(max(6, num - 2))"
            }
            exercises.append(Exercise(name: e.name, equipment: e.equipment, instructions: e.instructions, sets: e.sets, reps: e.reps, restSeconds: e.restSeconds))
        }
        
        let estimatedMin = exercises.reduce(0) { acc, ex in
            acc + ex.sets * (ex.restSeconds + 90) / 60
        }
        let summary = "Generated · \(intensity.rawValue) · \(focus?.rawValue ?? "Full body") · \(equipment.isEmpty ? "Any equipment" : equipment.map(\.rawValue).joined(separator: ", "))"
        return Workout(
            name: "Generated \(duration.label) Workout",
            summary: summary,
            exercises: Array(exercises),
            estimatedMinutes: max(targetMinutes, estimatedMin),
            profileType: profileType
        )
    }
    
    private static func focusForExercise(_ name: String) -> MuscleFocus {
        focusMap[name] ?? .fullBody
    }
    
    private static func fallbackWorkout(profileType: UserProfileType, duration: GeneratorDuration) -> Workout {
        let pool = WorkoutStore.exerciseLibrary.filter { $0.equipment == .bodyweight }
        let ex = pool.isEmpty ? [Exercise(name: "March in place", equipment: .bodyweight, sets: 1, reps: "\(duration.minutes) min", restSeconds: 0)] : Array(pool.shuffled().prefix(5)).map { Exercise(name: $0.name, equipment: $0.equipment, instructions: $0.instructions, sets: $0.sets, reps: $0.reps, restSeconds: $0.restSeconds) }
        return Workout(name: "Generated \(duration.label) Workout", summary: "Bodyweight backup.", exercises: ex, estimatedMinutes: duration.minutes, profileType: profileType)
    }
    
    // MARK: - Generate for young kids (7-year-old, 5-year-old)
    
    static func generateKidRoutine(
        duration: KidDuration,
        energyLevel: KidEnergyLevel,
        profileType: UserProfileType
    ) -> Workout {
        let minutes = duration.approximateMinutes
        let matching = kidActivityPool.filter { energyLevel == .chill ? $0.energy == .chill || $0.energy == .medium : ($0.energy == energyLevel || $0.energy == .medium) }
        let pool = matching.isEmpty ? kidActivityPool : matching
        var totalSec = 0
        var activities: [Exercise] = []
        for a in pool.shuffled() {
            if totalSec >= minutes * 60 { break }
            let dur = min(a.durationSec, 45)
            activities.append(Exercise(
                name: a.name,
                equipment: .bodyweight,
                instructions: a.instructions,
                sets: 1,
                reps: dur >= 30 ? "\(dur) sec" : "\(dur) sec",
                restSeconds: 10
            ))
            totalSec += dur + 10
        }
        let summary = "Generated fun routine · \(duration.rawValue) · \(energyLevel.rawValue) energy"
        return Workout(
            name: "Fun Moves \(duration.rawValue)",
            summary: summary,
            exercises: activities,
            estimatedMinutes: max(minutes, totalSec / 60),
            profileType: profileType
        )
    }
}
