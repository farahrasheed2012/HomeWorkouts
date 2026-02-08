//
//  LogWorkoutSheet.swift
//  HomeStrength
//
//  Log completed workout. Detailed (weight, reps) for Mom/Teen; simple "mark complete" for young kids.
//

import SwiftUI

struct LogWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    let workout: Workout
    let userId: UUID
    let profileType: UserProfileType?
    let onLog: (CompletedWorkout) -> Void
    
    @State private var weightPerExercise: [UUID: Double] = [:]
    @State private var verticalJump: String = ""
    @State private var notes: String = ""
    @State private var durationMinutes: String = ""
    
    private var isSimpleMode: Bool { profileType?.isYoungKid == true }
    private var isDaughterMS: Bool { profileType == .daughterMiddleSchool }
    
    var body: some View {
        NavigationStack {
            Form {
                if isSimpleMode {
                    Section {
                        Text("You did it! Tap Save to mark this activity as complete.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Section("Session") {
                        TextField("How long? (minutes, optional)", text: $durationMinutes)
                            .keyboardType(.numberPad)
                    }
                } else {
                    Section("Exercises") {
                        ForEach(workout.exercises) { ex in
                            HStack {
                                Text(ex.name)
                                    .font(.subheadline)
                                Spacer()
                                TextField("Weight (lb)", value: Binding(
                                    get: { weightPerExercise[ex.id] ?? 0 },
                                    set: { weightPerExercise[ex.id] = $0 }
                                ), format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                Text("lb")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Section("Session") {
                        TextField("Duration (minutes)", text: $durationMinutes)
                            .keyboardType(.numberPad)
                    }
                    if isDaughterMS {
                        Section("Volleyball metrics") {
                            TextField("Vertical jump (inches)", text: $verticalJump)
                                .keyboardType(.decimalPad)
                            TextField("Notes (e.g. serving practice)", text: $notes)
                        }
                    }
                }
            }
            .navigationTitle(isSimpleMode ? "Complete activity" : "Log workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                }
            }
        }
    }
    
    private func saveAndDismiss() {
        let loggedExercises: [LoggedExercise]
        if isSimpleMode {
            loggedExercises = workout.exercises.map { ex in
                LoggedExercise(
                    exerciseId: ex.id,
                    exerciseName: ex.name,
                    sets: [LoggedSet(reps: "done", weightLbs: nil)]
                )
            }
        } else {
            loggedExercises = workout.exercises.map { ex in
                let weight = weightPerExercise[ex.id] ?? 0
                let sets: [LoggedSet] = (0..<ex.sets).map { _ in
                    LoggedSet(reps: ex.reps, weightLbs: weight > 0 ? weight : nil)
                }
                return LoggedExercise(exerciseId: ex.id, exerciseName: ex.name, sets: sets)
            }
        }
        let duration = Int(durationMinutes.trimmingCharacters(in: .whitespaces))
        let jump = isDaughterMS ? Double(verticalJump.trimmingCharacters(in: .whitespaces)) : nil
        let completed = CompletedWorkout(
            userId: userId,
            workoutId: workout.id,
            workoutName: workout.name,
            completedAt: Date(),
            durationMinutes: duration,
            loggedExercises: loggedExercises,
            verticalJumpInches: jump,
            notes: notes.isEmpty ? nil : notes
        )
        onLog(completed)
        dismiss()
    }
}
