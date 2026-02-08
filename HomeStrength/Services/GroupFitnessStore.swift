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
                        motivationalCues: ex.motivationalCues
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
            upperBodyFocusRoutine(),
            lowerBodyPelvicFloorSafeRoutine(),
            coreRebuildingRoutine(),
            lowImpactGentleRoutine(),
            cardioHIITRoutine(),
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
                        GroupFitnessExercise(
                            name: "Squats",
                            lowKeyOption: "Chair squat or small range; hold chair back if needed.",
                            intermediateOption: "Bodyweight squat, full range.",
                            proOption: "Jump squat or pulse at bottom.",
                            durationSeconds: 45,
                            restSeconds: 15,
                            postpartumSafe: true,
                            formNotes: "Knees over toes, chest up.",
                            motivationalCues: ["Breathe out as you stand.", "Modify to chair squat anytime."]
                        ),
                        GroupFitnessExercise(
                            name: "Glute bridge",
                            lowKeyOption: "Feet flat, small range; focus on pelvic floor engagement.",
                            intermediateOption: "Hold at top 2 sec, lower slowly.",
                            proOption: "Single-leg bridge or hold at top with pulse.",
                            durationSeconds: 45,
                            restSeconds: 15,
                            postpartumSafe: true,
                            formNotes: "Squeeze glutes at top; don’t over-arch lower back.",
                            motivationalCues: ["Great for rebuilding core and pelvic floor."]
                        ),
                    ],
                    bpmSuggested: 120,
                    instructorCues: ["30 seconds per exercise, 15 seconds rest.", "Offer chair for anyone who needs support."]
                ),
                GroupFitnessSection(
                    name: "Upper body & core",
                    durationMinutes: 10,
                    exercises: [
                        GroupFitnessExercise(
                            name: "Push-ups",
                            lowKeyOption: "Wall push-up or hands on chair; knees down if needed.",
                            intermediateOption: "Knee or full push-up, controlled.",
                            proOption: "Full push-up, narrow hands or decline.",
                            durationSeconds: 30,
                            restSeconds: 15,
                            postpartumSafe: false,
                            formNotes: "Core tight, don’t let hips sag.",
                            motivationalCues: ["Scale down anytime—wall or chair is perfect."]
                        ),
                        GroupFitnessExercise(
                            name: "Plank",
                            lowKeyOption: "From knees; or 10 sec on / 10 sec rest.",
                            intermediateOption: "Forearm or high plank 30 sec.",
                            proOption: "Full plank 45 sec or alternating shoulder tap.",
                            durationSeconds: 30,
                            restSeconds: 15,
                            postpartumSafe: false,
                            formNotes: "Neutral spine; stop if you feel coning.",
                            motivationalCues: ["Postpartum: skip or do from knees if core feels weak."]
                        ),
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
                        GroupFitnessExercise(
                            name: "Arm raises & YTW",
                            lowKeyOption: "No weight; small range. Y and T only.",
                            intermediateOption: "Full Y, T, W; hold 2 sec.",
                            proOption: "Add pulse or longer hold.",
                            durationSeconds: 45,
                            restSeconds: 15,
                            postpartumSafe: true,
                            motivationalCues: ["Squeeze shoulder blades."]
                        ),
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
                        GroupFitnessExercise(
                            name: "Standing leg lift (side)",
                            lowKeyOption: "Small range; hold wall if needed.",
                            intermediateOption: "Slow and controlled.",
                            proOption: "Add pulse at top or small circle.",
                            durationSeconds: 30,
                            restSeconds: 15,
                            postpartumSafe: true,
                            motivationalCues: ["Balance is optional—hold a wall."]
                        ),
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
                        GroupFitnessExercise(
                            name: "Bird dog",
                            lowKeyOption: "From tabletop; extend one limb at a time, short hold.",
                            intermediateOption: "Alternate, 3 sec hold.",
                            proOption: "Add pulse or longer hold.",
                            durationSeconds: 40,
                            restSeconds: 20,
                            postpartumSafe: true,
                            formNotes: "Keep spine neutral; no sagging.",
                            motivationalCues: ["Modify to tabletop only if needed."]
                        ),
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
                        GroupFitnessExercise(
                            name: "Wall push-up or arm raises",
                            lowKeyOption: "Wall push-up or arm raises only.",
                            intermediateOption: "Wall push-up, slow.",
                            proOption: "Incline push-up from chair seat.",
                            durationSeconds: 30,
                            restSeconds: 15,
                            postpartumSafe: true,
                            motivationalCues: ["No pressure to go to the floor."]
                        ),
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
                        GroupFitnessExercise(
                            name: "Mountain climbers / knee drive",
                            lowKeyOption: "Standing knee drive (run in place).",
                            intermediateOption: "Mountain climbers from knees or slow.",
                            proOption: "Mountain climbers, full speed.",
                            durationSeconds: 30,
                            restSeconds: 20,
                            postpartumSafe: false,
                            motivationalCues: ["Option: step back instead of jump."]
                        ),
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
}

// Make GroupFitnessExercise mutable for editing (struct already is).
extension GroupFitnessSection {
    mutating func replaceExercises(_ exercises: [GroupFitnessExercise]) {
        self.exercises = exercises
    }
}
