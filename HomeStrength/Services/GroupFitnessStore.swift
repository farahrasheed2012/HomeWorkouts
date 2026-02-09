//
//  GroupFitnessStore.swift
//  HomeStrength
//
//  Library of group fitness routines and logs for classes led.
//

import Foundation
import SwiftUI

@MainActor
class GroupFitnessStore: ObservableObject {
    private static let classLogsKey = "HomeStrength.groupClassLogs"
    private static let customRoutinesKey = "HomeStrength.groupCustomRoutines"
    
    @Published private(set) var classLogs: [GroupClassLog] = []
    @Published var customRoutines: [GroupFitnessRoutine] = []
    
    /// Pre-designed routines (read-only library).
    static let libraryRoutines: [GroupFitnessRoutine] = buildLibraryRoutines()
    
    var allRoutines: [GroupFitnessRoutine] {
        GroupFitnessStore.libraryRoutines + customRoutines
    }
    
    init() {
        load()
    }
    
    func routines(for format: GroupClassFormat?) -> [GroupFitnessRoutine] {
        guard let format = format else { return allRoutines }
        return allRoutines.filter { $0.format == format }
    }
    
    func logClass(_ log: GroupClassLog) {
        classLogs.append(log)
        classLogs.sort { $0.date > $1.date }
        save()
    }
    
    func logs(forUserId userId: UUID) -> [GroupClassLog] {
        classLogs.filter { $0.userId == userId }.sorted { $0.date > $1.date }
    }
    
    func addCustomRoutine(_ routine: GroupFitnessRoutine) {
        customRoutines.append(routine)
        save()
    }
    
    func updateCustomRoutine(_ routine: GroupFitnessRoutine) {
        guard let i = customRoutines.firstIndex(where: { $0.id == routine.id }) else { return }
        customRoutines[i] = routine
        save()
    }
    
    func deleteCustomRoutine(id: UUID) {
        customRoutines.removeAll { $0.id == id }
        save()
    }
    
    func duplicateRoutine(_ routine: GroupFitnessRoutine) -> GroupFitnessRoutine {
        func sectionWithNewIds(_ s: GroupFitnessSection) -> GroupFitnessSection {
            GroupFitnessSection(
                id: UUID(),
                name: s.name,
                durationMinutes: s.durationMinutes,
                exercises: s.exercises.map { ex in
                    GroupFitnessExercise(
                        id: UUID(),
                        name: ex.name,
                        lowKeyOption: ex.lowKeyOption,
                        intermediateOption: ex.intermediateOption,
                        proOption: ex.proOption,
                        durationSeconds: ex.durationSeconds,
                        restSeconds: ex.restSeconds,
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
        let copy = GroupFitnessRoutine(
            id: UUID(),
            name: routine.name + " (Copy)",
            format: routine.format,
            estimatedMinutes: routine.estimatedMinutes,
            warmUp: sectionWithNewIds(routine.warmUp),
            mainSections: routine.mainSections.map(sectionWithNewIds),
            coolDown: sectionWithNewIds(routine.coolDown),
            spaceRequirements: routine.spaceRequirements,
            generalNotes: routine.generalNotes,
            scalingNotes: routine.scalingNotes
        )
        addCustomRoutine(copy)
        return copy
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: Self.classLogsKey),
           let decoded = try? JSONDecoder().decode([GroupClassLog].self, from: data) {
            classLogs = decoded
        }
        if let data = UserDefaults.standard.data(forKey: Self.customRoutinesKey),
           let decoded = try? JSONDecoder().decode([GroupFitnessRoutine].self, from: data) {
            customRoutines = decoded
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(classLogs) {
            UserDefaults.standard.set(data, forKey: Self.classLogsKey)
        }
        if let data = try? JSONEncoder().encode(customRoutines) {
            UserDefaults.standard.set(data, forKey: Self.customRoutinesKey)
        }
    }
    
    // MARK: - Sample library routines (30–45 min, bodyweight only)
    
    static func buildLibraryRoutines() -> [GroupFitnessRoutine] {
        [
            fullBodyRoutine(),
            fullBodyRoutine2(), fullBodyRoutine3(), fullBodyRoutine4(), fullBodyRoutine5(), fullBodyRoutine6(), fullBodyRoutine7(), fullBodyRoutine8(), fullBodyRoutine9(), fullBodyRoutine10(),
            fullBodyRoutine11(), fullBodyRoutine12(), fullBodyRoutine13(), fullBodyRoutine14(), fullBodyRoutine15(), fullBodyRoutine16(), fullBodyRoutine17(), fullBodyRoutine18(), fullBodyRoutine19(), fullBodyRoutine20(),
            upperBodyFocusRoutine(),
            upperBodyRoutine2(), upperBodyRoutine3(), upperBodyRoutine4(), upperBodyRoutine5(), upperBodyRoutine6(), upperBodyRoutine7(), upperBodyRoutine8(), upperBodyRoutine9(), upperBodyRoutine10(),
            upperBodyRoutine11(), upperBodyRoutine12(), upperBodyRoutine13(), upperBodyRoutine14(), upperBodyRoutine15(), upperBodyRoutine16(), upperBodyRoutine17(), upperBodyRoutine18(), upperBodyRoutine19(), upperBodyRoutine20(),
            lowerBodyPelvicFloorSafeRoutine(),
            lowerBodyRoutine2(), lowerBodyRoutine3(), lowerBodyRoutine4(), lowerBodyRoutine5(), lowerBodyRoutine6(), lowerBodyRoutine7(), lowerBodyRoutine8(), lowerBodyRoutine9(), lowerBodyRoutine10(),
            lowerBodyRoutine11(), lowerBodyRoutine12(), lowerBodyRoutine13(), lowerBodyRoutine14(), lowerBodyRoutine15(), lowerBodyRoutine16(), lowerBodyRoutine17(), lowerBodyRoutine18(), lowerBodyRoutine19(), lowerBodyRoutine20(),
            coreRebuildingRoutine(),
            coreRebuildingRoutine2(), coreRebuildingRoutine3(), coreRebuildingRoutine4(), coreRebuildingRoutine5(), coreRebuildingRoutine6(), coreRebuildingRoutine7(), coreRebuildingRoutine8(), coreRebuildingRoutine9(), coreRebuildingRoutine10(),
            coreRebuildingRoutine11(), coreRebuildingRoutine12(), coreRebuildingRoutine13(), coreRebuildingRoutine14(), coreRebuildingRoutine15(), coreRebuildingRoutine16(), coreRebuildingRoutine17(), coreRebuildingRoutine18(), coreRebuildingRoutine19(), coreRebuildingRoutine20(),
            lowImpactGentleRoutine(),
            lowImpactRoutine2(), lowImpactRoutine3(), lowImpactRoutine4(), lowImpactRoutine5(), lowImpactRoutine6(), lowImpactRoutine7(), lowImpactRoutine8(), lowImpactRoutine9(), lowImpactRoutine10(),
            lowImpactRoutine11(), lowImpactRoutine12(), lowImpactRoutine13(), lowImpactRoutine14(), lowImpactRoutine15(), lowImpactRoutine16(), lowImpactRoutine17(), lowImpactRoutine18(), lowImpactRoutine19(), lowImpactRoutine20(),
            cardioHIITRoutine(),
            cardioHIITRoutine2(), cardioHIITRoutine3(), cardioHIITRoutine4(), cardioHIITRoutine5(), cardioHIITRoutine6(), cardioHIITRoutine7(), cardioHIITRoutine8(), cardioHIITRoutine9(), cardioHIITRoutine10(),
            cardioHIITRoutine11(), cardioHIITRoutine12(), cardioHIITRoutine13(), cardioHIITRoutine14(), cardioHIITRoutine15(), cardioHIITRoutine16(), cardioHIITRoutine17(), cardioHIITRoutine18(), cardioHIITRoutine19(), cardioHIITRoutine20(),
        ]
    }
    
    private static func fullBodyRoutine() -> GroupFitnessRoutine {
        GroupFitnessRoutine(
            name: "Full-Body Mix (35 min)",
            format: .fullBody,
            estimatedMinutes: 35,
            warmUp: GroupFitnessSection(
                name: "Warm-up",
                durationMinutes: 5,
                exercises: [],
                bpmSuggested: 100,
                instructorCues: ["2 minutes: light march in place, arm circles.", "2 minutes: dynamic stretches—leg swings, torso twists.", "1 minute: deep breaths and shoulder rolls."]
            ),
            mainSections: [
                GroupFitnessSection(
                    name: "Lower body",
                    durationMinutes: 10,
                    exercises: [
                        GroupFitnessExercise(name: "Squats", lowKeyOption: "Chair squat or small range; hold chair back if needed.", intermediateOption: "Bodyweight squat, full range.", proOption: "Jump squat or pulse at bottom.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, formNotes: "Knees over toes, chest up.", motivationalCues: ["Breathe out as you stand.", "Modify to chair squat anytime."]),
                        GroupFitnessExercise(name: "Glute bridge", lowKeyOption: "Feet flat, small range; focus on pelvic floor engagement.", intermediateOption: "Hold at top 2 sec, lower slowly.", proOption: "Single-leg bridge or hold at top with pulse.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, formNotes: "Squeeze glutes at top; don’t over-arch lower back.", motivationalCues: ["Great for rebuilding core and pelvic floor."]),
                        GroupFitnessExercise(name: "Lunges", lowKeyOption: "Hold wall or chair; small range.", intermediateOption: "Alternating lunges, bodyweight.", proOption: "Walking lunge or add pulse.", durationSeconds: 40, restSeconds: 15, postpartumSafe: true, formNotes: "Front knee over ankle.", motivationalCues: ["Take your time.", "Option: reverse lunge."]),
                        GroupFitnessExercise(name: "Calf raises", lowKeyOption: "Hold wall; small range.", intermediateOption: "Full range, controlled.", proOption: "Single-leg or pulse at top.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Control the way down."]),
                        GroupFitnessExercise(name: "Leg lift (side)", lowKeyOption: "Seated or small range; hold chair.", intermediateOption: "Standing side leg lift, controlled.", proOption: "Add pulse or circle at top.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Keep hips square."]),
                    ],
                    bpmSuggested: 120,
                    instructorCues: ["30 seconds per exercise, 15 seconds rest.", "Offer chair for anyone who needs support."]
                ),
                GroupFitnessSection(
                    name: "Upper body & core",
                    durationMinutes: 10,
                    exercises: [
                        GroupFitnessExercise(name: "Push-ups", lowKeyOption: "Wall push-up or hands on chair; knees down if needed.", intermediateOption: "Knee or full push-up, controlled.", proOption: "Full push-up, narrow hands or decline.", durationSeconds: 30, restSeconds: 15, postpartumSafe: false, formNotes: "Core tight, don’t let hips sag.", motivationalCues: ["Scale down anytime—wall or chair is perfect."]),
                        GroupFitnessExercise(name: "Plank", lowKeyOption: "From knees; or 10 sec on / 10 sec rest.", intermediateOption: "Forearm or high plank 30 sec.", proOption: "Full plank 45 sec or alternating shoulder tap.", durationSeconds: 30, restSeconds: 15, postpartumSafe: false, formNotes: "Neutral spine; stop if you feel coning.", motivationalCues: ["Postpartum: skip or do from knees if core feels weak."]),
                        GroupFitnessExercise(name: "Dead bug", lowKeyOption: "One limb at a time; small range.", intermediateOption: "Alternating arm/leg, controlled.", proOption: "Full range, slow.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, formNotes: "Low back pressed to floor.", motivationalCues: ["If you see coning, make the move smaller."]),
                        GroupFitnessExercise(name: "Bird dog", lowKeyOption: "From tabletop; one limb at a time, short hold.", intermediateOption: "Alternate, 3 sec hold.", proOption: "Add pulse or longer hold.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, formNotes: "Keep spine neutral.", motivationalCues: ["Modify to tabletop only if needed."]),
                        GroupFitnessExercise(name: "Superman", lowKeyOption: "Arms only or legs only; short hold.", intermediateOption: "Arms and legs lift, 2 sec hold.", proOption: "Longer hold or add pulse.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Great for lower back."]),
                    ],
                    bpmSuggested: 110,
                    instructorCues: ["15 seconds rest between exercises.", "Remind: pelvic floor safe = no coning, modify planks."]
                ),
            ],
            coolDown: GroupFitnessSection(
                name: "Cool-down & stretch",
                durationMinutes: 5,
                exercises: [],
                bpmSuggested: nil,
                instructorCues: ["2 minutes: slow walk or march.", "3 minutes: static stretches—quads, hamstrings, chest, shoulders."]
            ),
            spaceRequirements: "Open floor space; enough room for everyone to extend arms and lie down. Minimal obstacles.",
            generalNotes: "Mixed levels; cue all three options so everyone can choose. Pelvic floor safe options cued for postpartum.",
            scalingNotes: "If energy is low, reduce reps or hold times. If group is strong, add pulses or longer holds."
        )
    }
    
    private static let _warmUp5 = GroupFitnessSection(name: "Warm-up", durationMinutes: 5, exercises: [], bpmSuggested: 100, instructorCues: ["Light march, arm circles, dynamic stretch."])
    private static let _coolDown5 = GroupFitnessSection(name: "Cool-down", durationMinutes: 5, exercises: [], instructorCues: ["Walk it out, then stretch quads, hamstrings, chest, shoulders."])
    private static let _warmUp4 = GroupFitnessSection(name: "Warm-up", durationMinutes: 4, exercises: [], bpmSuggested: 95, instructorCues: ["March, arm circles, shoulder rolls."])
    private static let _coolDown4 = GroupFitnessSection(name: "Cool-down", durationMinutes: 4, exercises: [], instructorCues: ["Stretch and breathe."])
    
    private static func _ex(_ name: String, _ low: String, _ mid: String, _ pro: String, _ dur: Int = 40, _ rest: Int = 15, _ pp: Bool = true) -> GroupFitnessExercise {
        GroupFitnessExercise(name: name, lowKeyOption: low, intermediateOption: mid, proOption: pro, durationSeconds: dur, restSeconds: rest, postpartumSafe: pp, motivationalCues: [])
    }
    
    private static func fullBodyRoutine2() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Strength Mix (32 min)", format: .fullBody, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Lower & upper", durationMinutes: 18, exercises: [
                _ex("Squats", "Chair squat or small range.", "Bodyweight squat, full range.", "Jump squat or pulse.", 45, 15),
                _ex("Glute bridge", "Small range; pelvic floor focus.", "Hold at top 2 sec.", "Single-leg bridge.", 45, 15),
                _ex("Push-ups", "Wall or chair; knees down ok.", "Knee or full push-up.", "Decline or narrow.", 30, 15, false),
                _ex("Lunges", "Hold wall; small range.", "Alternating lunges.", "Walking lunge.", 40, 15),
                _ex("Plank", "From knees; 15 sec.", "Forearm plank 30 sec.", "Full plank 45 sec.", 30, 15, false),
                _ex("Calf raises", "Hold wall.", "Full range.", "Single-leg.", 30, 15),
            ], bpmSuggested: 115, instructorCues: ["Cue all three options.", "Offer chair for squats."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor; chairs optional.", generalNotes: "Mixed levels.", scalingNotes: "Reduce hold times or add rest as needed.")
    }
    
    private static func fullBodyRoutine3() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Express (28 min)", format: .fullBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Circuit", durationMinutes: 16, exercises: [
                _ex("Squats", "Chair squat.", "Bodyweight squat.", "Pulse at bottom.", 40, 15),
                _ex("Push-ups", "Wall push-up.", "Knee push-up.", "Full push-up.", 30, 15, false),
                _ex("Glute bridge", "Small range.", "Hold 2 sec at top.", "Single-leg.", 40, 15),
                _ex("Plank", "Knees down.", "High plank 25 sec.", "Shoulder tap.", 25, 15, false),
                _ex("Lunges", "Hold chair.", "Alternating.", "Walking lunge.", 35, 15),
                _ex("Dead bug", "One limb at a time.", "Alternating.", "Full range.", 35, 20),
            ], bpmSuggested: 110, instructorCues: ["30–40 sec work, 15 sec rest."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: "Shorter format.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine4() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Balance & Strength (35 min)", format: .fullBody, estimatedMinutes: 35, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 10, exercises: [
                _ex("Squats", "Chair squat.", "Full squat.", "Jump squat.", 45, 15),
                _ex("Single-leg balance", "Hold wall; 10 sec.", "15 sec each leg.", "Eyes closed option.", 30, 15),
                _ex("Glute bridge", "Small range.", "Hold at top.", "Single-leg.", 45, 15),
                _ex("Calf raises", "Wall.", "Full range.", "Single-leg.", 30, 15),
            ], bpmSuggested: 110, instructorCues: []),
            GroupFitnessSection(name: "Upper & core", durationMinutes: 12, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Bird dog", "One limb.", "Alternate 3 sec.", "Pulse.", 40, 20),
                _ex("Plank", "Knees.", "Plank 30 sec.", "Tap.", 30, 15, false),
                _ex("Superman", "Arms only.", "Arms and legs.", "Hold longer.", 30, 15),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor; wall.", generalNotes: "Balance focus.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine5() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Power (30 min)", format: .fullBody, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 18, exercises: [
                _ex("Squats", "Chair.", "Bodyweight.", "Jump squat.", 40, 20),
                _ex("Push-ups", "Wall.", "Knee.", "Clap (optional).", 25, 20, false),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 15),
                _ex("Lunges", "Static.", "Alternating.", "Jump lunge.", 35, 20),
                _ex("Plank", "Knees.", "High plank.", "Mountain climbers.", 30, 20, false),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 120, instructorCues: ["Power options for pros."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Higher intensity options.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine6() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Flow (33 min)", format: .fullBody, estimatedMinutes: 33, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Flow", durationMinutes: 20, exercises: [
                _ex("Squats", "Chair.", "Squat.", "Pulse.", 45, 15),
                _ex("Glute bridge", "Small.", "Hold.", "March at top.", 45, 15),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Lunges", "Hold.", "Alternating.", "Walking.", 40, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 40, 20),
                _ex("Plank", "Knees.", "Plank.", "Tap.", 25, 15, false),
            ], bpmSuggested: 110, instructorCues: ["Smooth transitions."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Continuous flow.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine7() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body 35 (35 min)", format: .fullBody, estimatedMinutes: 35, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 12, exercises: [
                _ex("Squats", "Chair.", "Full.", "Jump.", 45, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Lunges", "Wall.", "Alternating.", "Walking.", 40, 15),
                _ex("Leg lift (side)", "Seated.", "Standing.", "Pulse.", 30, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 115, instructorCues: []),
            GroupFitnessSection(name: "Upper & core", durationMinutes: 10, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 30, 15, false),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 30, 15),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Classic 35-min mix.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine8() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Beginner-Friendly (30 min)", format: .fullBody, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 18, exercises: [
                _ex("Squats", "Sit to stand from chair.", "Bodyweight squat.", "Deeper squat.", 45, 20),
                _ex("Glute bridge", "Small range.", "Hold 2 sec.", "Single-leg.", 45, 20),
                _ex("Wall push-up", "Hands high.", "Hands lower.", "Incline.", 30, 15, true),
                _ex("March in place", "Slow.", "Steady.", "High knees.", 45, 15, true),
                _ex("Arm raises", "Small range.", "Full YTW.", "Hold.", 35, 15, true),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 40, 20, true),
            ], bpmSuggested: 100, instructorCues: ["Offer chair throughout.", "No pressure to go to floor."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor; chairs; wall.", generalNotes: "Beginner and postpartum friendly.", scalingNotes: "Reduce time or add rest anytime.")
    }
    
    private static func fullBodyRoutine9() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body HIIT Lite (28 min)", format: .fullBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 16, exercises: [
                _ex("Squats", "Chair.", "Squat.", "Jump squat.", 35, 20),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 25, 20, false),
                _ex("High knees", "March.", "High knees.", "Fast.", 30, 25, false),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 35, 20),
                _ex("Plank", "Knees.", "Plank.", "Tap.", 25, 20, false),
                _ex("Rest", "Walk.", "Walk.", "Light jog.", 45, 0, true),
            ], bpmSuggested: 130, instructorCues: ["40 sec work, 20 sec rest; 2 rounds."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: "Interval style.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine10() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Stretch & Strengthen (32 min)", format: .fullBody, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Strength", durationMinutes: 14, exercises: [
                _ex("Squats", "Chair.", "Full.", "Pulse.", 45, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Lunges", "Hold.", "Alternating.", "Walking.", 40, 15),
                _ex("Plank", "Knees.", "Plank.", "Hold.", 30, 15, false),
            ], bpmSuggested: 110, instructorCues: []),
            GroupFitnessSection(name: "Mobility", durationMinutes: 8, exercises: [
                _ex("Reach & twist", "Seated.", "Standing.", "Deeper twist.", 40, 15, true),
                _ex("Hip circles", "Small.", "Full.", "Hold.", 30, 15, true),
                _ex("Calf stretch", "Wall.", "Hold 20 sec.", "Deeper.", 30, 10, true),
            ], bpmSuggested: nil, instructorCues: ["Focus on breath."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor; wall.", generalNotes: "Strength then mobility.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine11() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Mix A (34 min)", format: .fullBody, estimatedMinutes: 34, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Block 1", durationMinutes: 14, exercises: [
                _ex("Squats", "Chair.", "Full.", "Jump.", 45, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Lunges", "Wall.", "Alternating.", "Walking.", 40, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 115, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Mix A.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine12() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Mix B (34 min)", format: .fullBody, estimatedMinutes: 34, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Block 1", durationMinutes: 14, exercises: [
                _ex("Lunges", "Hold.", "Alternating.", "Walking.", 40, 15),
                _ex("Plank", "Knees.", "Plank.", "Tap.", 30, 15, false),
                _ex("Glute bridge", "Small.", "Hold.", "March at top.", 45, 15),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Squats", "Chair.", "Full.", "Pulse.", 45, 15),
            ], bpmSuggested: 110, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Mix B.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine13() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Mix C (33 min)", format: .fullBody, estimatedMinutes: 33, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 18, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Squats", "Chair.", "Full.", "Jump.", 45, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 40, 20),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Leg lift (side)", "Seated.", "Standing.", "Circle.", 30, 15),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 30, 15),
            ], bpmSuggested: 110, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Mix C.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine14() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body 40 (40 min)", format: .fullBody, estimatedMinutes: 40, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 12, exercises: [
                _ex("Squats", "Chair.", "Full.", "Jump.", 45, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Lunges", "Wall.", "Alternating.", "Walking.", 45, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 35, 15),
                _ex("Leg lift (side)", "Seated.", "Standing.", "Pulse.", 35, 15),
            ], bpmSuggested: 115, instructorCues: []),
            GroupFitnessSection(name: "Upper & core", durationMinutes: 15, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 35, 15, false),
                _ex("Plank", "Knees.", "Plank 35 sec.", "Tap.", 35, 15, false),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 45, 20),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 35, 15),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Longer format.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine15() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body 25 Express (25 min)", format: .fullBody, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Quick circuit", durationMinutes: 14, exercises: [
                _ex("Squats", "Chair.", "Full.", "Pulse.", 40, 15),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 25, 15, false),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 15),
                _ex("Plank", "Knees.", "25 sec.", "Tap.", 25, 15, false),
                _ex("Lunges", "Hold.", "Alternating.", "Walking.", 35, 15),
            ], bpmSuggested: 115, instructorCues: ["Quick transitions."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: "Short class.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine16() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Strength & Stability (35 min)", format: .fullBody, estimatedMinutes: 35, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 20, exercises: [
                _ex("Squats", "Chair.", "Full.", "Single-leg sit to stand.", 45, 15),
                _ex("Single-leg stance", "Hold wall 10 sec.", "15 sec.", "Eyes closed.", 30, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 15, false),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold 5 sec.", 45, 20),
                _ex("Plank", "Knees.", "Plank.", "Single-leg hold.", 30, 15, false),
                _ex("Lunges", "Hold.", "Alternating.", "Walking.", 40, 15),
            ], bpmSuggested: 108, instructorCues: ["Stability over speed."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor; wall.", generalNotes: "Stability focus.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine17() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Cardio-Strength (30 min)", format: .fullBody, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Mixed", durationMinutes: 18, exercises: [
                _ex("March in place", "Slow.", "Steady.", "High knees.", 45, 15, true),
                _ex("Squats", "Chair.", "Full.", "Jump squat.", 40, 20),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 25, 20, false),
                _ex("Step touch", "Small.", "Add arms.", "Larger range.", 45, 15, true),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 15),
                _ex("Plank", "Knees.", "Plank.", "Tap.", 25, 20, false),
            ], bpmSuggested: 120, instructorCues: ["Blend cardio and strength."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Cardio + strength.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine18() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Rebuild (32 min)", format: .fullBody, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Rebuild", durationMinutes: 18, exercises: [
                _ex("Squats", "Sit to stand.", "Full.", "Hold at bottom.", 45, 20),
                _ex("Glute bridge", "Exhale up.", "Hold.", "Single-leg.", 45, 20),
                _ex("Wall push-up", "Hands high.", "Lower.", "Incline.", 30, 15, true),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 40, 20),
                _ex("March in place", "Slow.", "Steady.", "Arms drive.", 45, 15, true),
            ], bpmSuggested: 100, instructorCues: ["Exhale on exertion.", "Pelvic floor friendly."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor; wall; chairs.", generalNotes: "Postpartum / rebuild friendly.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine19() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Blitz (27 min)", format: .fullBody, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Blitz", durationMinutes: 16, exercises: [
                _ex("Squats", "Chair.", "Full.", "Jump.", 35, 18),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 25, 18, false),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 35, 18),
                _ex("Lunges", "Static.", "Alternating.", "Jump.", 35, 18),
                _ex("Plank", "Knees.", "Plank.", "Tap.", 25, 18, false),
                _ex("High knees", "March.", "High knees.", "Fast.", 30, 20, false),
            ], bpmSuggested: 125, instructorCues: ["30 sec work, 15–20 sec rest."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: "Higher energy.", scalingNotes: nil)
    }
    
    private static func fullBodyRoutine20() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Full-Body Classic (36 min)", format: .fullBody, estimatedMinutes: 36, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 11, exercises: [
                _ex("Squats", "Chair.", "Full.", "Jump.", 45, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 15),
                _ex("Lunges", "Wall.", "Alternating.", "Walking.", 45, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 115, instructorCues: []),
            GroupFitnessSection(name: "Upper & core", durationMinutes: 12, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 35, 15, false),
                _ex("Plank", "Knees.", "35 sec.", "Tap.", 35, 15, false),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 45, 20),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 30, 15),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: "Classic two-block format.", scalingNotes: nil)
    }
    
    private static func upperBodyFocusRoutine() -> GroupFitnessRoutine {
        GroupFitnessRoutine(
            name: "Upper Body Focus (30 min)",
            format: .upperBody,
            estimatedMinutes: 30,
            warmUp: GroupFitnessSection(
                name: "Warm-up",
                durationMinutes: 4,
                exercises: [],
                bpmSuggested: 100,
                instructorCues: ["Arm circles, shoulder rolls, chest stretch, light march."]
            ),
            mainSections: [
                GroupFitnessSection(
                    name: "Upper body",
                    durationMinutes: 18,
                    exercises: [
                        GroupFitnessExercise(
                            name: "Push-ups",
                            lowKeyOption: "Wall or incline (hands on chair); knees down if needed.",
                            intermediateOption: "Knee or full push-up.",
                            proOption: "Full push-up, narrow or decline.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: false,
                            formNotes: "Core tight, don't sag.",
                            motivationalCues: ["Scale to wall anytime."]
                        ),
                        GroupFitnessExercise(
                            name: "Tricep dip (chair)",
                            lowKeyOption: "Feet flat, small range; or standing band press.",
                            intermediateOption: "Feet flat or knees bent, full range.",
                            proOption: "Legs extended or feet elevated.",
                            durationSeconds: 30,
                            restSeconds: 15,
                            postpartumSafe: true,
                            motivationalCues: ["Shoulders down."]
                        ),
                        GroupFitnessExercise(name: "Arm raises & YTW", lowKeyOption: "No weight; small range. Y and T only.", intermediateOption: "Full Y, T, W; hold 2 sec.", proOption: "Add pulse or longer hold.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Squeeze shoulder blades."]),
                        GroupFitnessExercise(name: "Plank", lowKeyOption: "From knees; short hold.", intermediateOption: "Forearm or high plank 25 sec.", proOption: "Full plank 40 sec.", durationSeconds: 30, restSeconds: 15, postpartumSafe: false, motivationalCues: ["Scale to knees anytime."]),
                        GroupFitnessExercise(name: "Band pull-apart", lowKeyOption: "Light band; short range.", intermediateOption: "Full range, squeeze at end.", proOption: "Heavy band or pause.", durationSeconds: 40, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Shoulders down and back."]),
                        GroupFitnessExercise(name: "Tricep extension (bodyweight)", lowKeyOption: "Hands on wall, small push.", intermediateOption: "Chair dip, controlled.", proOption: "Full dip or narrow push-up.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Elbows back."]),
                        GroupFitnessExercise(name: "Superman", lowKeyOption: "Arms only or legs only.", intermediateOption: "Arms and legs, 2 sec hold.", proOption: "Longer hold.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Great for upper back."]),
                        GroupFitnessExercise(name: "Bird dog", lowKeyOption: "Tabletop; one limb at a time.", intermediateOption: "Alternate, 3 sec hold.", proOption: "Add pulse.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Neutral spine."]),
                        GroupFitnessExercise(name: "Calf raises", lowKeyOption: "Hold wall.", intermediateOption: "Full range.", proOption: "Single-leg.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Control the lower."]),
                    ],
                    bpmSuggested: 110,
                    instructorCues: ["30–45 sec work, 15–20 sec rest. Chair option for dips."]
                ),
            ],
            coolDown: GroupFitnessSection(
                name: "Cool-down",
                durationMinutes: 5,
                exercises: [],
                instructorCues: ["Chest, shoulder, and tricep stretches."]
            ),
            spaceRequirements: "Open floor; chairs or wall for push-up and dip options.",
            generalNotes: "Bodyweight only. Good for mixed levels with clear modifications.",
            scalingNotes: "If wrists hurt, offer fist or wall push-up. Reduce dip range as needed."
        )
    }
    
    private static func upperBodyRoutine2() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Push & Pull (28 min)", format: .upperBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Upper", durationMinutes: 16, exercises: [
                _ex("Push-ups", "Wall or chair.", "Knee or full.", "Decline.", 40, 20, false),
                _ex("Tricep dip (chair)", "Feet flat, small range.", "Full range.", "Legs extended.", 30, 15, true),
                _ex("Arm raises & YTW", "Y and T only.", "Full YTW.", "Pulse.", 45, 15, true),
                _ex("Plank", "Knees.", "Plank 25 sec.", "40 sec.", 30, 15, false),
                _ex("Superman", "Arms only.", "Arms and legs.", "Hold.", 30, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs; wall.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine3() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body & Core (30 min)", format: .upperBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 18, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 35, 20, false),
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 35, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 30, 15, true),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 40, 20, true),
                _ex("Arm raises & YTW", "Small range.", "Full YTW.", "Hold.", 40, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 30, 15, true),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine4() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Express (25 min)", format: .upperBody, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Upper", durationMinutes: 14, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 35, 18, false),
                _ex("Plank", "Knees.", "25 sec.", "35 sec.", 28, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 28, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "YTW.", "Pulse.", 35, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 28, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine5() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Strength (32 min)", format: .upperBody, estimatedMinutes: 32, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Block 1", durationMinutes: 14, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Narrow or decline.", 40, 20, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 35, 15, true),
                _ex("Plank", "Knees.", "30 sec.", "45 sec.", 35, 15, false),
            ], bpmSuggested: 105, instructorCues: []),
            GroupFitnessSection(name: "Block 2", durationMinutes: 10, exercises: [
                _ex("Arm raises & YTW", "Y, T.", "Full YTW.", "Pulse.", 45, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 35, 15, true),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 40, 20, true),
            ], bpmSuggested: 100, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine6() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Mix A (28 min)", format: .upperBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Upper", durationMinutes: 16, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 38, 18, false),
                _ex("Plank", "Knees.", "28 sec.", "38 sec.", 30, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 30, 15, true),
                _ex("Arm raises & YTW", "Small.", "Full.", "Hold.", 42, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 30, 15, true),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine7() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Mix B (30 min)", format: .upperBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Upper", durationMinutes: 18, exercises: [
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 35, 15, false),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 40, 20, false),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20, true),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 32, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "YTW.", "Pulse.", 45, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 32, 15, true),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine8() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Mix C (27 min)", format: .upperBody, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 15, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 35, 18, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 30, 15, true),
                _ex("Arm raises & YTW", "Small.", "Full YTW.", "Hold.", 40, 15, true),
                _ex("Plank", "Knees.", "28 sec.", "35 sec.", 28, 15, false),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 28, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine9() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Endurance (33 min)", format: .upperBody, estimatedMinutes: 33, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Upper", durationMinutes: 20, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 45, 20, false),
                _ex("Plank", "Knees.", "35 sec.", "45 sec.", 40, 18, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 35, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "Full YTW.", "Pulse.", 50, 15, true),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 45, 20, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 35, 15, true),
            ], bpmSuggested: 105, instructorCues: ["Longer holds for endurance."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine10() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body Quick (22 min)", format: .upperBody, estimatedMinutes: 22, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Upper", durationMinutes: 12, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 30, 18, false),
                _ex("Plank", "Knees.", "25 sec.", "30 sec.", 25, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 25, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "YTW.", "Hold.", 35, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine11() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body A (29 min)", format: .upperBody, estimatedMinutes: 29, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 17, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 40, 20, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 32, 15, true),
                _ex("Plank", "Knees.", "30 sec.", "40 sec.", 32, 15, false),
                _ex("Arm raises & YTW", "Small.", "Full.", "Pulse.", 42, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 32, 15, true),
            ], bpmSuggested: 106, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine12() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body B (29 min)", format: .upperBody, estimatedMinutes: 29, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 17, exercises: [
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 35, 15, false),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 38, 18, false),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20, true),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 30, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "YTW.", "Hold.", 40, 15, true),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine13() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body C (28 min)", format: .upperBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 16, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 36, 18, false),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 32, 15, true),
                _ex("Plank", "Knees.", "28 sec.", "36 sec.", 30, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 30, 15, true),
                _ex("Arm raises & YTW", "Small.", "Full YTW.", "Pulse.", 40, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine14() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body D (30 min)", format: .upperBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 18, exercises: [
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 35, 15, true),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 40, 20, false),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 45, 20, true),
                _ex("Plank", "Knees.", "32 sec.", "42 sec.", 35, 15, false),
                _ex("Arm raises & YTW", "Y, T.", "Full YTW.", "Hold.", 45, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 32, 15, true),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine15() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body E (26 min)", format: .upperBody, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 14, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 35, 18, false),
                _ex("Plank", "Knees.", "28 sec.", "35 sec.", 28, 15, false),
                _ex("Arm raises & YTW", "Small.", "YTW.", "Pulse.", 38, 15, true),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 28, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 28, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine16() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body F (31 min)", format: .upperBody, estimatedMinutes: 31, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 19, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 42, 20, false),
                _ex("Plank", "Knees.", "32 sec.", "42 sec.", 35, 15, false),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 45, 20, true),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 32, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "Full YTW.", "Hold.", 48, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 32, 15, true),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine17() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body G (27 min)", format: .upperBody, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 15, exercises: [
                _ex("Plank", "Knees.", "28 sec.", "35 sec.", 30, 15, false),
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 36, 18, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 30, 15, true),
                _ex("Arm raises & YTW", "Small.", "Full.", "Pulse.", 40, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 30, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine18() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body H (30 min)", format: .upperBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 18, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 40, 20, false),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 44, 20, true),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 32, 15, true),
                _ex("Plank", "Knees.", "30 sec.", "40 sec.", 32, 15, false),
                _ex("Arm raises & YTW", "Y, T.", "YTW.", "Hold.", 44, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 32, 15, true),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine19() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body I (24 min)", format: .upperBody, estimatedMinutes: 24, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Main", durationMinutes: 12, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 32, 18, false),
                _ex("Plank", "Knees.", "25 sec.", "32 sec.", 26, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Extended.", 26, 15, true),
                _ex("Arm raises & YTW", "Y, T.", "YTW.", "Hold.", 35, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func upperBodyRoutine20() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Upper Body J (32 min)", format: .upperBody, estimatedMinutes: 32, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Block 1", durationMinutes: 10, exercises: [
                _ex("Push-ups", "Wall.", "Knee.", "Full.", 40, 20, false),
                _ex("Plank", "Knees.", "30 sec.", "40 sec.", 35, 15, false),
                _ex("Tricep dip (chair)", "Feet flat.", "Full.", "Elevated.", 32, 15, true),
            ], bpmSuggested: 108, instructorCues: []),
            GroupFitnessSection(name: "Block 2", durationMinutes: 10, exercises: [
                _ex("Arm raises & YTW", "Small.", "Full YTW.", "Pulse.", 48, 15, true),
                _ex("Superman", "Arms only.", "Full.", "Hold.", 35, 15, true),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20, true),
            ], bpmSuggested: 102, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyPelvicFloorSafeRoutine() -> GroupFitnessRoutine {
        GroupFitnessRoutine(
            name: "Lower Body & Pelvic Floor Safe (30 min)",
            format: .lowerBody,
            estimatedMinutes: 30,
            warmUp: GroupFitnessSection(
                name: "Warm-up",
                durationMinutes: 4,
                exercises: [],
                bpmSuggested: 95,
                instructorCues: ["2 min: march, step touch.", "2 min: hip circles, leg swings (small range)."]
            ),
            mainSections: [
                GroupFitnessSection(
                    name: "Lower body (pelvic floor friendly)",
                    durationMinutes: 18,
                    exercises: [
                        GroupFitnessExercise(
                            name: "Squat (modified)",
                            lowKeyOption: "Sit to stand from chair; focus on exhale on effort.",
                            intermediateOption: "Bodyweight squat, exhale as you stand.",
                            proOption: "Deeper squat, 3-second hold at bottom.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: true,
                            formNotes: "Exhale on exertion; avoid bearing down.",
                            motivationalCues: ["Exhale as you stand—protects pelvic floor."]
                        ),
                        GroupFitnessExercise(
                            name: "Glute bridge",
                            lowKeyOption: "Small range; exhale as you lift hips.",
                            intermediateOption: "Hold 3 sec at top, lower slowly.",
                            proOption: "Single-leg or band above knees.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: true,
                            formNotes: "Core and pelvic floor friendly.",
                            motivationalCues: ["Perfect for core and pelvic floor rebuilding."]
                        ),
                        GroupFitnessExercise(name: "Standing leg lift (side)", lowKeyOption: "Small range; hold wall if needed.", intermediateOption: "Slow and controlled.", proOption: "Add pulse at top or small circle.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Balance is optional—hold a wall."]),
                        GroupFitnessExercise(name: "Calf raises", lowKeyOption: "Hold wall; exhale on rise.", intermediateOption: "Full range, controlled.", proOption: "Single-leg.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Exhale as you rise."]),
                        GroupFitnessExercise(name: "Dead bug", lowKeyOption: "One limb at a time; small range.", intermediateOption: "Alternating, controlled.", proOption: "Full range, slow.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Low back to floor."]),
                        GroupFitnessExercise(name: "Bird dog", lowKeyOption: "Tabletop; one limb at a time.", intermediateOption: "Alternate, 3 sec hold.", proOption: "Add pulse.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Exhale on extend."]),
                        GroupFitnessExercise(name: "Glute bridge (hold)", lowKeyOption: "Small range; exhale up.", intermediateOption: "Hold 3 sec at top.", proOption: "Single-leg or march.", durationSeconds: 45, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Pelvic floor friendly."]),
                        GroupFitnessExercise(name: "March in place", lowKeyOption: "Slow march; hold wall if needed.", intermediateOption: "Steady march, arms drive.", proOption: "High knees, controlled.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Exhale on step."]),
                        GroupFitnessExercise(name: "Step touch", lowKeyOption: "Small steps; hold chair.", intermediateOption: "Side step, add arms.", proOption: "Larger range.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Your pace."]),
                        GroupFitnessExercise(name: "Seated leg lift", lowKeyOption: "One knee at a time.", intermediateOption: "Alternating, controlled.", proOption: "Both legs, hold.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Chair option."]),
                    ],
                    bpmSuggested: 110,
                    instructorCues: ["30–40 sec work, 15–20 sec rest.", "Cue exhale on exertion for every move."]
                ),
            ],
            coolDown: GroupFitnessSection(
                name: "Cool-down",
                durationMinutes: 5,
                exercises: [],
                instructorCues: ["Seated or standing stretches; focus on hips and legs."]
            ),
            spaceRequirements: "Open floor; chairs available for sit-to-stand and balance.",
            generalNotes: "Designed for postpartum and anyone preferring pelvic floor safe options. No jumping.",
            scalingNotes: "Reduce range or add rest if anyone needs to step back."
        )
    }
    
    private static func lowerBodyRoutine2() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe A (28 min)", format: .lowerBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 16, exercises: [
                _ex("Squat (modified)", "Sit to stand; exhale up.", "Bodyweight squat; exhale.", "Hold at bottom.", 40, 20),
                _ex("Glute bridge", "Small range; exhale up.", "Hold 3 sec.", "Single-leg.", 40, 20),
                _ex("Standing leg lift (side)", "Small range; wall.", "Controlled.", "Pulse.", 30, 15),
                _ex("Calf raises", "Wall; exhale rise.", "Full range.", "Single-leg.", 30, 15),
                _ex("March in place", "Slow; exhale step.", "Steady.", "Arms drive.", 45, 15),
            ], bpmSuggested: 108, instructorCues: ["Exhale on exertion."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs; wall.", generalNotes: "Pelvic floor safe.", scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine3() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe B (30 min)", format: .lowerBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 18, exercises: [
                _ex("Glute bridge", "Small; exhale up.", "Hold 3 sec.", "Single-leg.", 45, 20),
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Deeper hold.", 40, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Bird dog", "Tabletop.", "Alternate 3 sec.", "Pulse.", 40, 20),
                _ex("Step touch", "Small; chair.", "Add arms.", "Larger.", 45, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 108, instructorCues: ["Exhale on exertion."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine4() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe C (26 min)", format: .lowerBody, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 14, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 38, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 38, 18),
                _ex("Standing leg lift (side)", "Wall.", "Controlled.", "Pulse.", 28, 15),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 42, 15),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 30, 18),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine5() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe D (32 min)", format: .lowerBody, estimatedMinutes: 32, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 20, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Hold.", 45, 20),
                _ex("Glute bridge", "Small; exhale.", "Hold 3 sec.", "Single-leg.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 45, 20),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 32, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 48, 15),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("March in place", "Slow.", "Steady.", "Drive.", 45, 15),
            ], bpmSuggested: 105, instructorCues: ["Exhale on exertion."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine6() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe E (27 min)", format: .lowerBody, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 15, exercises: [
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 40, 18),
                _ex("Standing leg lift (side)", "Small.", "Controlled.", "Pulse.", 30, 15),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 42, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; wall.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine7() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe F (29 min)", format: .lowerBody, estimatedMinutes: 29, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 17, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Hold.", 42, 20),
                _ex("Glute bridge (hold)", "Small; exhale.", "Hold 3 sec.", "March at top.", 45, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 38, 20),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 45, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 40, 20),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 32, 18),
            ], bpmSuggested: 106, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine8() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe G (25 min)", format: .lowerBody, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 13, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 35, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 38, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 40, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine9() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe H (31 min)", format: .lowerBody, estimatedMinutes: 31, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 19, exercises: [
                _ex("Glute bridge", "Small; exhale.", "Hold 3 sec.", "Single-leg.", 48, 20),
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 45, 20),
                _ex("Standing leg lift (side)", "Wall.", "Controlled.", "Pulse.", 32, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 48, 15),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine10() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe I (28 min)", format: .lowerBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 16, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Hold.", 42, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("March in place", "Slow.", "Steady.", "Drive.", 45, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 32, 18),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine11() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Pelvic Safe J (30 min)", format: .lowerBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 18, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 44, 20),
                _ex("Glute bridge", "Small; exhale.", "Hold 3 sec.", "Single-leg.", 44, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 48, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 42, 20),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 106, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine12() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Express (24 min)", format: .lowerBody, estimatedMinutes: 24, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 12, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 38, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 38, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 42, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine13() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body K (29 min)", format: .lowerBody, estimatedMinutes: 29, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 17, exercises: [
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 44, 20),
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 42, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20),
                _ex("Standing leg lift (side)", "Wall.", "Controlled.", "Pulse.", 30, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 45, 15),
            ], bpmSuggested: 106, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine14() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body L (27 min)", format: .lowerBody, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 15, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Hold.", 40, 18),
                _ex("Glute bridge (hold)", "Small; exhale.", "Hold 3 sec.", "Single-leg.", 42, 18),
                _ex("March in place", "Slow.", "Steady.", "Drive.", 45, 15),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 38, 20),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine15() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body M (31 min)", format: .lowerBody, estimatedMinutes: 31, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 19, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 45, 20),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 45, 20),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 50, 15),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 35, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
            ], bpmSuggested: 105, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine16() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body N (26 min)", format: .lowerBody, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 14, exercises: [
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 18),
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 40, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 44, 15),
                _ex("Standing leg lift (side)", "Wall.", "Controlled.", "Pulse.", 28, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine17() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body O (28 min)", format: .lowerBody, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 16, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Hold.", 42, 18),
                _ex("Glute bridge", "Small; exhale.", "Hold 3 sec.", "Single-leg.", 42, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 45, 15),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 38, 20),
            ], bpmSuggested: 106, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine18() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body P (30 min)", format: .lowerBody, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 18, exercises: [
                _ex("Glute bridge (hold)", "Small; exhale.", "Hold 3 sec.", "March at top.", 48, 20),
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 44, 20),
                _ex("March in place", "Slow.", "Steady.", "Drive.", 48, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 32, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 44, 20),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 34, 18),
            ], bpmSuggested: 106, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine19() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body Q (25 min)", format: .lowerBody, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 13, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat.", "Hold.", 38, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 18),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 42, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 108, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowerBodyRoutine20() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Lower Body R (32 min)", format: .lowerBody, estimatedMinutes: 32, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Lower", durationMinutes: 20, exercises: [
                _ex("Squat (modified)", "Sit to stand.", "Squat; exhale.", "Hold.", 46, 20),
                _ex("Glute bridge", "Small; exhale.", "Hold 3 sec.", "Single-leg.", 46, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 44, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 44, 20),
                _ex("Standing leg lift (side)", "Wall.", "Controlled.", "Pulse.", 32, 15),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 48, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 45, 15),
            ], bpmSuggested: 105, instructorCues: ["Exhale on exertion."]),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine() -> GroupFitnessRoutine {
        GroupFitnessRoutine(
            name: "Core Rebuilding (Postpartum-Friendly) (25 min)",
            format: .coreRebuilding,
            estimatedMinutes: 25,
            warmUp: GroupFitnessSection(
                name: "Warm-up",
                durationMinutes: 4,
                exercises: [],
                instructorCues: ["Breathing focus, gentle march, cat-cow, pelvic tilts."]
            ),
            mainSections: [
                GroupFitnessSection(
                    name: "Core (no coning)",
                    durationMinutes: 14,
                    exercises: [
                        GroupFitnessExercise(
                            name: "Dead bug",
                            lowKeyOption: "Small range; one limb at a time.",
                            intermediateOption: "Alternating arm/leg, controlled.",
                            proOption: "Full range, slow.",
                            durationSeconds: 45,
                            restSeconds: 20,
                            postpartumSafe: true,
                            formNotes: "Low back pressed to floor; if belly domes, reduce range.",
                            motivationalCues: ["If you see coning, make the move smaller."]
                        ),
                        GroupFitnessExercise(
                            name: "Glute bridge with breath",
                            lowKeyOption: "Lift on exhale, lower on inhale.",
                            intermediateOption: "Hold at top, kegel-friendly cue.",
                            proOption: "Single-leg or march at top.",
                            durationSeconds: 45,
                            restSeconds: 20,
                            postpartumSafe: true,
                            motivationalCues: ["Exhale as you lift—supports pelvic floor."]
                        ),
                        GroupFitnessExercise(name: "Bird dog", lowKeyOption: "From tabletop; extend one limb at a time, short hold.", intermediateOption: "Alternate, 3 sec hold.", proOption: "Add pulse or longer hold.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, formNotes: "Keep spine neutral; no sagging.", motivationalCues: ["Modify to tabletop only if needed."]),
                        GroupFitnessExercise(name: "Cat-cow", lowKeyOption: "Small range; focus on breath.", intermediateOption: "Full range, slow.", proOption: "Hold at end range.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Inhale cow, exhale cat."]),
                        GroupFitnessExercise(name: "Pelvic tilts", lowKeyOption: "Supine; small range.", intermediateOption: "Controlled tilts.", proOption: "Add hold at end.", durationSeconds: 40, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Low back to floor."]),
                        GroupFitnessExercise(name: "Supine march", lowKeyOption: "Feet on floor; small lift.", intermediateOption: "Alternating knee lift.", proOption: "Add hold.", durationSeconds: 45, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Exhale as you lift."]),
                        GroupFitnessExercise(name: "Heel slide", lowKeyOption: "One leg at a time; short slide.", intermediateOption: "Alternating, controlled.", proOption: "Both legs.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Low back stays down."]),
                        GroupFitnessExercise(name: "Tabletop hold", lowKeyOption: "10 sec; rest as needed.", intermediateOption: "20–30 sec hold.", proOption: "Add leg lift.", durationSeconds: 30, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Neutral spine."]),
                        GroupFitnessExercise(name: "Superman (modified)", lowKeyOption: "Arms only or legs only.", intermediateOption: "Arms and legs, short hold.", proOption: "Full superman, 2 sec.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Lower back focus."]),
                        GroupFitnessExercise(name: "Breathing", lowKeyOption: "Diaphragmatic breath, 4 counts.", intermediateOption: "Add pelvic floor cue.", proOption: "Extended exhale.", durationSeconds: 60, restSeconds: 0, postpartumSafe: true, motivationalCues: ["Breathe into your ribs."]),
                    ],
                    instructorCues: ["Focus on breathing and control over intensity."]
                ),
            ],
            coolDown: GroupFitnessSection(
                name: "Stretch",
                durationMinutes: 5,
                exercises: [],
                instructorCues: ["Child’s pose, hip flexor stretch, breathing."]
            ),
            spaceRequirements: "Enough floor space for everyone to lie on back and all fours.",
            generalNotes: "Pelvic floor and core rebuilding focus. Avoid sit-ups and heavy planks; cue modifications.",
            scalingNotes: "If anyone reports pressure or coning, offer tabletop or supine only options."
        )
    }
    
    private static func coreRebuildingRoutine2() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding A (24 min)", format: .coreRebuilding, estimatedMinutes: 24, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 12, exercises: [
                _ex("Dead bug", "One limb; small range.", "Alternate.", "Full.", 40, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold at top.", "Single-leg.", 42, 20),
                _ex("Bird dog", "Tabletop; one limb.", "Alternate 3 sec.", "Pulse.", 40, 20),
                _ex("Cat-cow", "Small range.", "Full range.", "Hold.", 40, 15),
                _ex("Pelvic tilts", "Supine; small.", "Controlled.", "Hold.", 35, 15),
            ], instructorCues: ["Exhale on exertion."]),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: "No coning.", scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine3() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding B (26 min)", format: .coreRebuilding, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 14, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 45, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "March at top.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 42, 20),
                _ex("Supine march", "Feet on floor; small.", "Alternating.", "Hold.", 42, 20),
                _ex("Heel slide", "One leg.", "Alternating.", "Both.", 38, 20),
                _ex("Breathing", "Diaphragmatic 4 counts.", "Add PF cue.", "Extended exhale.", 50, 0),
            ], instructorCues: ["Low back to floor."]),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine4() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding C (22 min)", format: .coreRebuilding, estimatedMinutes: 22, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 10, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 38, 18),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 40, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 38, 18),
                _ex("Cat-cow", "Small.", "Full.", "Hold.", 35, 15),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine5() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding D (25 min)", format: .coreRebuilding, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 13, exercises: [
                _ex("Glute bridge with breath", "Exhale up.", "Hold 3 sec.", "Single-leg.", 45, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Pelvic tilts", "Supine.", "Controlled.", "Hold.", 38, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 42, 20),
                _ex("Tabletop hold", "10 sec.", "20–30 sec.", "Leg lift.", 28, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine6() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding E (23 min)", format: .coreRebuilding, estimatedMinutes: 23, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 11, exercises: [
                _ex("Dead bug", "One limb; small.", "Alternate.", "Full.", 40, 18),
                _ex("Bird dog", "Tabletop.", "Alternate 3 sec.", "Pulse.", 40, 18),
                _ex("Cat-cow", "Small.", "Full.", "Hold.", 38, 15),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 40, 18),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine7() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding F (27 min)", format: .coreRebuilding, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 15, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 48, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "March at top.", 48, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 45, 20),
                _ex("Supine march", "Small lift.", "Alternating.", "Hold.", 45, 20),
                _ex("Heel slide", "One leg.", "Alternating.", "Both.", 40, 20),
                _ex("Superman (modified)", "Arms only.", "Arms and legs.", "Full.", 30, 15),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine8() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding G (24 min)", format: .coreRebuilding, estimatedMinutes: 24, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 12, exercises: [
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 44, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Pelvic tilts", "Supine.", "Controlled.", "Hold.", 38, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 42, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine9() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding H (25 min)", format: .coreRebuilding, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 13, exercises: [
                _ex("Bird dog", "Tabletop.", "Alternate 3 sec.", "Pulse.", 44, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 44, 20),
                _ex("Cat-cow", "Small.", "Full.", "Hold.", 40, 15),
                _ex("Glute bridge with breath", "Exhale up.", "Hold 3 sec.", "Single-leg.", 44, 20),
                _ex("Breathing", "4 counts.", "PF cue.", "Extended exhale.", 45, 0),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine10() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding I (22 min)", format: .coreRebuilding, estimatedMinutes: 22, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 10, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 38, 18),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 40, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 38, 18),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine11() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding J (26 min)", format: .coreRebuilding, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 14, exercises: [
                _ex("Dead bug", "One limb; small.", "Alternate.", "Full.", 46, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "March at top.", 46, 20),
                _ex("Heel slide", "One leg.", "Alternating.", "Both.", 42, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 44, 20),
                _ex("Tabletop hold", "10 sec.", "25 sec.", "Leg lift.", 30, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine12() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding K (24 min)", format: .coreRebuilding, estimatedMinutes: 24, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 12, exercises: [
                _ex("Glute bridge with breath", "Exhale up.", "Hold 3 sec.", "Single-leg.", 44, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Pelvic tilts", "Supine.", "Controlled.", "Hold.", 38, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 42, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine13() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding L (23 min)", format: .coreRebuilding, estimatedMinutes: 23, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 11, exercises: [
                _ex("Bird dog", "Tabletop.", "Alternate 3 sec.", "Pulse.", 42, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Cat-cow", "Small.", "Full.", "Hold.", 38, 15),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 40, 18),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine14() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding M (25 min)", format: .coreRebuilding, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 13, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 45, 20),
                _ex("Supine march", "Small lift.", "Alternating.", "Hold.", 44, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 45, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 44, 20),
                _ex("Breathing", "4 counts.", "PF cue.", "Extended exhale.", 48, 0),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine15() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding N (26 min)", format: .coreRebuilding, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 14, exercises: [
                _ex("Glute bridge with breath", "Exhale up.", "Hold 3 sec.", "March at top.", 48, 20),
                _ex("Dead bug", "One limb; small.", "Alternate.", "Full.", 46, 20),
                _ex("Heel slide", "One leg.", "Alternating.", "Both.", 42, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 46, 20),
                _ex("Superman (modified)", "Arms only.", "Arms and legs.", "Full.", 32, 15),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine16() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding O (24 min)", format: .coreRebuilding, estimatedMinutes: 24, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 12, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 44, 20),
                _ex("Pelvic tilts", "Supine.", "Controlled.", "Hold.", 38, 15),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine17() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding P (25 min)", format: .coreRebuilding, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 13, exercises: [
                _ex("Bird dog", "Tabletop.", "Alternate 3 sec.", "Pulse.", 46, 20),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 44, 20),
                _ex("Cat-cow", "Small.", "Full.", "Hold.", 42, 15),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 44, 20),
                _ex("Tabletop hold", "10 sec.", "25 sec.", "Leg lift.", 28, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine18() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding Q (23 min)", format: .coreRebuilding, estimatedMinutes: 23, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 11, exercises: [
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 42, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 40, 18),
                _ex("Breathing", "4 counts.", "PF cue.", "Extended exhale.", 42, 0),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine19() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding R (26 min)", format: .coreRebuilding, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 14, exercises: [
                _ex("Dead bug", "One limb; small.", "Alternate.", "Full.", 46, 20),
                _ex("Supine march", "Small lift.", "Alternating.", "Hold.", 46, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold 3 sec.", "March at top.", 46, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 44, 20),
                _ex("Heel slide", "One leg.", "Alternating.", "Both.", 40, 20),
            ], instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func coreRebuildingRoutine20() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Core Rebuilding S (27 min)", format: .coreRebuilding, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Core", durationMinutes: 15, exercises: [
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 48, 20),
                _ex("Glute bridge with breath", "Exhale up.", "Hold.", "Single-leg.", 48, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 46, 20),
                _ex("Pelvic tilts", "Supine.", "Controlled.", "Hold.", 40, 15),
                _ex("Tabletop hold", "10 sec.", "30 sec.", "Leg lift.", 30, 20),
                _ex("Breathing", "4 counts.", "PF cue.", "Extended exhale.", 50, 0),
            ], instructorCues: ["Focus on breath and control."]),
        ], coolDown: _coolDown4, spaceRequirements: "Floor space.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactGentleRoutine() -> GroupFitnessRoutine {
        GroupFitnessRoutine(
            name: "Low-Impact Gentle (30 min)",
            format: .lowImpact,
            estimatedMinutes: 30,
            warmUp: GroupFitnessSection(
                name: "Warm-up",
                durationMinutes: 5,
                exercises: [],
                bpmSuggested: 90,
                instructorCues: ["2 min: march in place.", "3 min: arm circles, shoulder rolls, gentle torso twists."]
            ),
            mainSections: [
                GroupFitnessSection(
                    name: "Gentle movement",
                    durationMinutes: 18,
                    exercises: [
                        GroupFitnessExercise(
                            name: "Step touch / side step",
                            lowKeyOption: "Small steps; hold wall for balance.",
                            intermediateOption: "Add arm movements.",
                            proOption: "Larger range, optional light arm weights (or no equipment).",
                            durationSeconds: 60,
                            restSeconds: 20,
                            postpartumSafe: true,
                            motivationalCues: ["Move at your own pace."]
                        ),
                        GroupFitnessExercise(
                            name: "Seated or standing leg lift",
                            lowKeyOption: "Seated; lift one knee at a time.",
                            intermediateOption: "Standing; slow leg lifts.",
                            proOption: "Standing with hold or pulse.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: true,
                            motivationalCues: ["Chair option always available."]
                        ),
                        GroupFitnessExercise(name: "Wall push-up or arm raises", lowKeyOption: "Wall push-up or arm raises only.", intermediateOption: "Wall push-up, slow.", proOption: "Incline push-up from chair seat.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["No pressure to go to the floor."]),
                        GroupFitnessExercise(name: "March in place", lowKeyOption: "Slow march; hold wall if needed.", intermediateOption: "Steady march.", proOption: "High knees, gentle.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Your pace."]),
                        GroupFitnessExercise(name: "Calf raises", lowKeyOption: "Hold wall.", intermediateOption: "Full range.", proOption: "Single-leg.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Control the lower."]),
                        GroupFitnessExercise(name: "Seated leg lift", lowKeyOption: "One knee at a time.", intermediateOption: "Standing; slow leg lifts.", proOption: "Hold or pulse.", durationSeconds: 35, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Chair option."]),
                        GroupFitnessExercise(name: "Glute bridge", lowKeyOption: "Small range; feet flat.", intermediateOption: "Hold at top 2 sec.", proOption: "Single-leg.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Exhale as you lift."]),
                        GroupFitnessExercise(name: "Dead bug", lowKeyOption: "One limb at a time.", intermediateOption: "Alternating, controlled.", proOption: "Full range, slow.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Low back down."]),
                        GroupFitnessExercise(name: "Bird dog", lowKeyOption: "Tabletop; one limb at a time.", intermediateOption: "Alternate, 3 sec hold.", proOption: "Add pulse.", durationSeconds: 40, restSeconds: 20, postpartumSafe: true, motivationalCues: ["Neutral spine."]),
                        GroupFitnessExercise(name: "Reach for the sky", lowKeyOption: "Seated or standing; small reach.", intermediateOption: "Standing, stretch side to side.", proOption: "Add side bend.", durationSeconds: 30, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Breathe."]),
                        GroupFitnessExercise(name: "Step touch", lowKeyOption: "Small steps; hold chair.", intermediateOption: "Add arm movements.", proOption: "Larger range.", durationSeconds: 45, restSeconds: 15, postpartumSafe: true, motivationalCues: ["Move at your pace."]),
                    ],
                    bpmSuggested: 100,
                    instructorCues: ["30–60 sec per exercise; 15–20 sec rest. Offer chairs throughout."]
                ),
            ],
            coolDown: GroupFitnessSection(
                name: "Cool-down",
                durationMinutes: 5,
                exercises: [],
                instructorCues: ["Stretching and deep breathing."]
            ),
            spaceRequirements: "Open space; chairs available. Wall space for wall push-ups.",
            generalNotes: "For postpartum and anyone preferring no jumping or high impact.",
            scalingNotes: "If energy drops, add more rest or reduce time per exercise."
        )
    }
    
    private static func lowImpactRoutine2() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle A (28 min)", format: .lowImpact, estimatedMinutes: 28, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 16, exercises: [
                _ex("Step touch", "Small; hold wall.", "Add arms.", "Larger.", 50, 18),
                _ex("March in place", "Slow.", "Steady.", "High knees gentle.", 45, 15),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 38, 18),
                _ex("Wall push-up or arm raises", "Arm raises.", "Wall push-up.", "Incline.", 30, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 98, instructorCues: ["Offer chairs."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs; wall.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine3() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle B (30 min)", format: .lowImpact, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 18, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Arms drive.", 48, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 52, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 30, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine4() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle C (26 min)", format: .lowImpact, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 14, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 48, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 45, 15),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 35, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 38, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine5() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle D (32 min)", format: .lowImpact, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 20, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Drive.", 50, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 55, 18),
                _ex("Wall push-up or arm raises", "Raises.", "Wall push-up.", "Incline.", 32, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 44, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 44, 20),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 32, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; wall; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine6() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle E (27 min)", format: .lowImpact, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 15, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 50, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 46, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 18),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 36, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine7() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle F (29 min)", format: .lowImpact, estimatedMinutes: 29, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 17, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Drive.", 48, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 52, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 42, 20),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 30, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine8() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle G (25 min)", format: .lowImpact, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 13, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 48, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 44, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 38, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine9() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle H (31 min)", format: .lowImpact, estimatedMinutes: 31, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 19, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Drive.", 50, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 54, 18),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 40, 18),
                _ex("Wall push-up or arm raises", "Raises.", "Wall push-up.", "Incline.", 32, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 44, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs; wall.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine10() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle I (28 min)", format: .lowImpact, estimatedMinutes: 28, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 16, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 52, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 48, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 42, 20),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine11() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle J (30 min)", format: .lowImpact, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 18, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Drive.", 50, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 54, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 44, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 38, 18),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 32, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine12() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle K (26 min)", format: .lowImpact, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 14, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 50, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 46, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine13() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle L (27 min)", format: .lowImpact, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 15, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Arms.", 48, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 52, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 40, 20),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 36, 18),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine14() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle M (29 min)", format: .lowImpact, estimatedMinutes: 29, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 17, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 54, 18),
                _ex("March in place", "Slow.", "Steady.", "Drive.", 50, 15),
                _ex("Wall push-up or arm raises", "Raises.", "Wall push-up.", "Incline.", 32, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 44, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 42, 20),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 30, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; wall; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine15() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle N (31 min)", format: .lowImpact, estimatedMinutes: 31, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 19, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Drive.", 52, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 56, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 46, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 46, 20),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 40, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 32, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine16() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle O (25 min)", format: .lowImpact, estimatedMinutes: 25, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 13, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 48, 18),
                _ex("March in place", "Slow.", "Steady.", "Arms.", 44, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 38, 18),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 28, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine17() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle P (28 min)", format: .lowImpact, estimatedMinutes: 28, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 16, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Arms.", 50, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 52, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 42, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 40, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 40, 20),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine18() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle Q (30 min)", format: .lowImpact, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 18, exercises: [
                _ex("Step touch", "Small.", "Arms.", "Larger.", 55, 18),
                _ex("March in place", "Slow.", "Steady.", "Drive.", 52, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 44, 18),
                _ex("Seated leg lift", "One knee.", "Alternating.", "Hold.", 40, 18),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 32, 15),
                _ex("Calf raises", "Wall.", "Full.", "Single-leg.", 30, 15),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine19() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle R (26 min)", format: .lowImpact, estimatedMinutes: 26, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 14, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Arms.", 46, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 50, 18),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 40, 18),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Hold.", 40, 20),
            ], bpmSuggested: 98, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open space; chairs.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func lowImpactRoutine20() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Low-Impact Gentle S (32 min)", format: .lowImpact, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Gentle", durationMinutes: 20, exercises: [
                _ex("March in place", "Slow.", "Steady.", "Drive.", 54, 15),
                _ex("Step touch", "Small.", "Arms.", "Larger.", 58, 18),
                _ex("Wall push-up or arm raises", "Raises.", "Wall push-up.", "Incline.", 34, 15),
                _ex("Glute bridge", "Small.", "Hold.", "Single-leg.", 46, 18),
                _ex("Dead bug", "One limb.", "Alternate.", "Full.", 44, 20),
                _ex("Bird dog", "Tabletop.", "Alternate.", "Pulse.", 46, 20),
                _ex("Reach for the sky", "Seated.", "Standing.", "Side bend.", 34, 15),
            ], bpmSuggested: 98, instructorCues: ["Offer chairs throughout."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open space; chairs; wall.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine() -> GroupFitnessRoutine {
        GroupFitnessRoutine(
            name: "Cardio / HIIT (35 min)",
            format: .cardioHIIT,
            estimatedMinutes: 35,
            warmUp: GroupFitnessSection(
                name: "Warm-up",
                durationMinutes: 5,
                exercises: [],
                bpmSuggested: 120,
                instructorCues: ["2 min: jog in place, high knees (low impact option: march).", "3 min: dynamic stretch."]
            ),
            mainSections: [
                GroupFitnessSection(
                    name: "Intervals",
                    durationMinutes: 22,
                    exercises: [
                        GroupFitnessExercise(
                            name: "High knees / march",
                            lowKeyOption: "March in place, arms drive.",
                            intermediateOption: "High knees, moderate pace.",
                            proOption: "High knees, fast; or burpee modification.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: false,
                            motivationalCues: ["Scale to march if needed.", "20 seconds left!", "Great job!"]
                        ),
                        GroupFitnessExercise(
                            name: "Jump squat / squat",
                            lowKeyOption: "Bodyweight squat only.",
                            intermediateOption: "Small jump or pulse at top.",
                            proOption: "Jump squat.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: false,
                            motivationalCues: ["Land soft.", "Modify to squat anytime."]
                        ),
                        GroupFitnessExercise(name: "Mountain climbers / knee drive", lowKeyOption: "Standing knee drive (run in place).", intermediateOption: "Mountain climbers from knees or slow.", proOption: "Mountain climbers, full speed.", durationSeconds: 30, restSeconds: 20, postpartumSafe: false, motivationalCues: ["Option: step back instead of jump."]),
                        GroupFitnessExercise(name: "Lateral shuffles", lowKeyOption: "March in place or slow shuffle.", intermediateOption: "Quick shuffle, low stance.", proOption: "Touch floor at each side.", durationSeconds: 40, restSeconds: 20, postpartumSafe: false, motivationalCues: ["Stay low."]),
                        GroupFitnessExercise(name: "Skater jumps", lowKeyOption: "Step side to side.", intermediateOption: "Small hop side to side.", proOption: "Full skater jump.", durationSeconds: 40, restSeconds: 20, postpartumSafe: false, motivationalCues: ["Land soft."]),
                        GroupFitnessExercise(name: "Plank", lowKeyOption: "From knees; 15 sec.", intermediateOption: "High plank 30 sec.", proOption: "Plank with shoulder tap.", durationSeconds: 30, restSeconds: 20, postpartumSafe: false, motivationalCues: ["Core tight."]),
                        GroupFitnessExercise(name: "Burpee (modified)", lowKeyOption: "Step back and up; no jump.", intermediateOption: "Step back, jump up.", proOption: "Full burpee.", durationSeconds: 30, restSeconds: 25, postpartumSafe: false, motivationalCues: ["Scale anytime."]),
                        GroupFitnessExercise(name: "Jumping jacks", lowKeyOption: "Step jacks or small jacks.", intermediateOption: "Full jacks.", proOption: "Power jacks.", durationSeconds: 40, restSeconds: 20, postpartumSafe: false, motivationalCues: ["Land soft."]),
                        GroupFitnessExercise(name: "Speed squats", lowKeyOption: "Regular squats, controlled.", intermediateOption: "Faster bodyweight squat.", proOption: "Jump squat.", durationSeconds: 40, restSeconds: 20, postpartumSafe: false, motivationalCues: ["Drive up."]),
                        GroupFitnessExercise(name: "Fast feet", lowKeyOption: "March fast in place.", intermediateOption: "Run in place, quick feet.", proOption: "Sprint in place.", durationSeconds: 30, restSeconds: 25, postpartumSafe: false, motivationalCues: ["Quick feet!"]),
                        GroupFitnessExercise(name: "Rest / walk", lowKeyOption: "Walk in place or slow jog.", intermediateOption: "Walk, arms swing.", proOption: "Light jog.", durationSeconds: 60, restSeconds: 0, postpartumSafe: true, motivationalCues: ["Recover for the next round."]),
                    ],
                    bpmSuggested: 140,
                    instructorCues: ["40 sec work, 20 sec rest. Repeat 2–3 rounds. Offer low-impact option every interval."]
                ),
            ],
            coolDown: GroupFitnessSection(
                name: "Cool-down",
                durationMinutes: 5,
                exercises: [],
                instructorCues: ["Walk it out, then stretch."]
            ),
            spaceRequirements: "Open floor; enough room for high knees and mountain climbers.",
            generalNotes: "For intermediate/pro. Low-impact options cued for mixed levels.",
            scalingNotes: "If group is tired, shorten work or add rest. If strong, add a round or extend work 10 sec."
        )
    }
    
    private static func cardioHIITRoutine2() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT A (32 min)", format: .cardioHIIT, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 20, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast or burpee mod.", 38, 20, false),
                _ex("Jump squat / squat", "Squat only.", "Pulse.", "Jump squat.", 38, 20, false),
                _ex("Plank", "Knees 15 sec.", "Plank 28 sec.", "Tap.", 28, 20, false),
                _ex("Jumping jacks", "Step jacks.", "Full jacks.", "Power.", 38, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Light jog.", 55, 0, true),
            ], bpmSuggested: 138, instructorCues: ["40 sec work, 20 sec rest."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine3() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT B (30 min)", format: .cardioHIIT, estimatedMinutes: 30, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 18, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 35, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 35, 20, false),
                _ex("Mountain climbers / knee drive", "Knee drive.", "MC from knees.", "Full MC.", 28, 20, false),
                _ex("Burpee (modified)", "Step back/up.", "Step back, jump.", "Full.", 28, 25, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 50, 0, true),
            ], bpmSuggested: 135, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine4() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT C (35 min)", format: .cardioHIIT, estimatedMinutes: 35, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 22, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 40, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump squat.", 40, 20, false),
                _ex("Lateral shuffles", "March or slow shuffle.", "Quick shuffle.", "Touch floor.", 40, 20, false),
                _ex("Skater jumps", "Step side.", "Small hop.", "Full skater.", 40, 20, false),
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 30, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 60, 0, true),
            ], bpmSuggested: 140, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine5() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT D (28 min)", format: .cardioHIIT, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 16, exercises: [
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 35, 20, false),
                _ex("Speed squats", "Controlled.", "Faster.", "Jump.", 35, 20, false),
                _ex("High knees / march", "March.", "High knees.", "Fast.", 35, 20, false),
                _ex("Plank", "Knees.", "25 sec.", "Tap.", 25, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 45, 0, true),
            ], bpmSuggested: 135, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine6() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT E (33 min)", format: .cardioHIIT, estimatedMinutes: 33, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 20, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 38, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 38, 20, false),
                _ex("Fast feet", "March fast.", "Run in place.", "Sprint.", 28, 25, false),
                _ex("Mountain climbers / knee drive", "Knee drive.", "MC slow.", "Full MC.", 28, 20, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 38, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 55, 0, true),
            ], bpmSuggested: 138, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine7() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT F (30 min)", format: .cardioHIIT, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 18, exercises: [
                _ex("Skater jumps", "Step.", "Small hop.", "Full.", 38, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 38, 20, false),
                _ex("Plank", "Knees.", "28 sec.", "Tap.", 28, 20, false),
                _ex("High knees / march", "March.", "High knees.", "Fast.", 38, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 50, 0, true),
            ], bpmSuggested: 136, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine8() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT G (34 min)", format: .cardioHIIT, estimatedMinutes: 34, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 21, exercises: [
                _ex("Burpee (modified)", "Step back/up.", "Step, jump.", "Full.", 28, 25, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 38, 20, false),
                _ex("Speed squats", "Controlled.", "Faster.", "Jump.", 38, 20, false),
                _ex("Lateral shuffles", "March.", "Shuffle.", "Touch floor.", 38, 20, false),
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 30, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 58, 0, true),
            ], bpmSuggested: 139, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine9() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT H (27 min)", format: .cardioHIIT, estimatedMinutes: 27, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 15, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 32, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 32, 20, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 32, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 42, 0, true),
            ], bpmSuggested: 135, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine10() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT I (36 min)", format: .cardioHIIT, estimatedMinutes: 36, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 23, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 42, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 42, 20, false),
                _ex("Mountain climbers / knee drive", "Knee drive.", "MC.", "Full MC.", 30, 20, false),
                _ex("Skater jumps", "Step.", "Hop.", "Full.", 42, 20, false),
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 32, 20, false),
                _ex("Fast feet", "March fast.", "Run.", "Sprint.", 30, 25, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 62, 0, true),
            ], bpmSuggested: 140, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine11() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT J (31 min)", format: .cardioHIIT, estimatedMinutes: 31, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 19, exercises: [
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 38, 20, false),
                _ex("Speed squats", "Controlled.", "Faster.", "Jump.", 38, 20, false),
                _ex("High knees / march", "March.", "High knees.", "Fast.", 38, 20, false),
                _ex("Lateral shuffles", "March.", "Shuffle.", "Touch.", 38, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 52, 0, true),
            ], bpmSuggested: 137, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine12() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT K (29 min)", format: .cardioHIIT, estimatedMinutes: 29, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 17, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 36, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 36, 20, false),
                _ex("Plank", "Knees.", "26 sec.", "Tap.", 26, 20, false),
                _ex("Burpee (modified)", "Step.", "Step jump.", "Full.", 26, 25, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 48, 0, true),
            ], bpmSuggested: 136, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine13() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT L (33 min)", format: .cardioHIIT, estimatedMinutes: 33, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 20, exercises: [
                _ex("Skater jumps", "Step.", "Hop.", "Full.", 38, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 38, 20, false),
                _ex("Fast feet", "March fast.", "Run.", "Sprint.", 28, 25, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 38, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 56, 0, true),
            ], bpmSuggested: 138, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine14() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT M (30 min)", format: .cardioHIIT, estimatedMinutes: 30, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 18, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 38, 20, false),
                _ex("Mountain climbers / knee drive", "Knee drive.", "MC.", "Full MC.", 28, 20, false),
                _ex("Speed squats", "Controlled.", "Faster.", "Jump.", 38, 20, false),
                _ex("Plank", "Knees.", "28 sec.", "Tap.", 28, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 52, 0, true),
            ], bpmSuggested: 136, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine15() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT N (35 min)", format: .cardioHIIT, estimatedMinutes: 35, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 22, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 40, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 40, 20, false),
                _ex("Lateral shuffles", "March.", "Shuffle.", "Touch.", 40, 20, false),
                _ex("Skater jumps", "Step.", "Hop.", "Full.", 40, 20, false),
                _ex("Plank", "Knees.", "30 sec.", "Tap.", 30, 20, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 40, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 60, 0, true),
            ], bpmSuggested: 140, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine16() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT O (28 min)", format: .cardioHIIT, estimatedMinutes: 28, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 16, exercises: [
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 35, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 35, 20, false),
                _ex("High knees / march", "March.", "High knees.", "Fast.", 35, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 46, 0, true),
            ], bpmSuggested: 135, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine17() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT P (32 min)", format: .cardioHIIT, estimatedMinutes: 32, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 20, exercises: [
                _ex("Burpee (modified)", "Step.", "Step jump.", "Full.", 28, 25, false),
                _ex("High knees / march", "March.", "High knees.", "Fast.", 38, 20, false),
                _ex("Speed squats", "Controlled.", "Faster.", "Jump.", 38, 20, false),
                _ex("Plank", "Knees.", "28 sec.", "Tap.", 28, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 54, 0, true),
            ], bpmSuggested: 138, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine18() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT Q (31 min)", format: .cardioHIIT, estimatedMinutes: 31, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 19, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 38, 20, false),
                _ex("Lateral shuffles", "March.", "Shuffle.", "Touch.", 38, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 38, 20, false),
                _ex("Fast feet", "March fast.", "Run.", "Sprint.", 28, 25, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 52, 0, true),
            ], bpmSuggested: 137, instructorCues: []),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine19() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT R (29 min)", format: .cardioHIIT, estimatedMinutes: 29, warmUp: _warmUp4, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 17, exercises: [
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 36, 20, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 36, 20, false),
                _ex("Plank", "Knees.", "26 sec.", "Tap.", 26, 20, false),
                _ex("High knees / march", "March.", "High knees.", "Fast.", 36, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 50, 0, true),
            ], bpmSuggested: 136, instructorCues: []),
        ], coolDown: _coolDown4, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
    
    private static func cardioHIITRoutine20() -> GroupFitnessRoutine {
        GroupFitnessRoutine(name: "Cardio / HIIT S (34 min)", format: .cardioHIIT, estimatedMinutes: 34, warmUp: _warmUp5, mainSections: [
            GroupFitnessSection(name: "Intervals", durationMinutes: 21, exercises: [
                _ex("High knees / march", "March.", "High knees.", "Fast.", 40, 20, false),
                _ex("Jump squat / squat", "Squat.", "Pulse.", "Jump.", 40, 20, false),
                _ex("Mountain climbers / knee drive", "Knee drive.", "MC.", "Full MC.", 30, 20, false),
                _ex("Skater jumps", "Step.", "Hop.", "Full.", 40, 20, false),
                _ex("Jumping jacks", "Step jacks.", "Full.", "Power.", 40, 20, false),
                _ex("Rest / walk", "Walk.", "Walk.", "Jog.", 58, 0, true),
            ], bpmSuggested: 139, instructorCues: ["Low-impact option every interval."]),
        ], coolDown: _coolDown5, spaceRequirements: "Open floor.", generalNotes: nil, scalingNotes: nil)
    }
}

// Make GroupFitnessExercise mutable for editing (struct already is).
extension GroupFitnessSection {
    mutating func replaceExercises(_ exercises: [GroupFitnessExercise]) {
        self.exercises = exercises
    }
}
