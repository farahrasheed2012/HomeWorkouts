//
//  DesignWorkoutView.swift
//  HomeStrength
//
//  Create or edit a workout and choose which equipment to use.
//

import SwiftUI

struct DesignWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: WorkoutStore
    
    /// Nil = new workout; non-nil = edit existing.
    let existingWorkout: Workout?
    /// For new workouts, which profile this belongs to.
    var profileType: UserProfileType = .mom
    
    @State private var name: String = ""
    @State private var summary: String = ""
    @State private var selectedEquipment: Set<Equipment> = []
    @State private var exercises: [Exercise] = []
    @State private var showAddFromLibrary = false
    @State private var showAddCustom = false
    
    private var isEditing: Bool { existingWorkout != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout") {
                    TextField("Name", text: $name)
                    TextField("Summary", text: $summary)
                }
                
                Section("Equipment") {
                    Text("Choose the equipment this workout will use. Exercises are limited to these.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(Equipment.allCases, id: \.self) { eq in
                            let isOn = selectedEquipment.contains(eq)
                            Button {
                                if isOn {
                                    selectedEquipment.remove(eq)
                                    exercises.removeAll { $0.equipment == eq }
                                } else {
                                    selectedEquipment.insert(eq)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: eq.icon)
                                        .font(.caption)
                                    Text(eq.rawValue)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(isOn ? HSTheme.accentFill : HSTheme.tertiaryFill)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section("Exercises") {
                    ForEach(exercises) { ex in
                        HStack {
                            Image(systemName: ex.equipment.icon)
                                .foregroundStyle(HSTheme.accent)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ex.name)
                                    .font(.subheadline)
                                Text("\(ex.sets) × \(ex.reps)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                exercises.removeAll { $0.id == ex.id }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    .onMove(perform: moveExercises)
                    
                    Button {
                        showAddFromLibrary = true
                    } label: {
                        Label("Add from library", systemImage: "plus.circle")
                    }
                    .disabled(selectedEquipment.isEmpty)
                    
                    Button {
                        showAddCustom = true
                    } label: {
                        Label("Add custom exercise", systemImage: "pencil.and.list.clipboard")
                    }
                    .disabled(selectedEquipment.isEmpty)
                }
            }
            .navigationTitle(isEditing ? "Edit Workout" : "Design Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadExisting)
            .sheet(isPresented: $showAddFromLibrary) {
                ExerciseLibrarySheet(
                    equipment: selectedEquipment,
                    onPick: { ex in
                        exercises.append(ex)
                        showAddFromLibrary = false
                    },
                    onDismiss: { showAddFromLibrary = false }
                )
            }
            .sheet(isPresented: $showAddCustom) {
                AddCustomExerciseSheet(
                    allowedEquipment: selectedEquipment,
                    onAdd: { ex in
                        exercises.append(ex)
                        showAddCustom = false
                    },
                    onDismiss: { showAddCustom = false }
                )
            }
        }
    }
    
    private func loadExisting() {
        guard let w = existingWorkout else { return }
        name = w.name
        summary = w.summary
        selectedEquipment = Set(w.exercises.map(\.equipment))
        exercises = w.exercises.map { ex in
            Exercise(id: ex.id, name: ex.name, equipment: ex.equipment, instructions: ex.instructions, sets: ex.sets, reps: ex.reps, restSeconds: ex.restSeconds)
        }
    }
    
    private func moveExercises(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedSummary = summary.trimmingCharacters(in: .whitespaces)
        let estimatedMinutes = max(5, exercises.count * 4)
        
        if let existing = existingWorkout {
            let updated = Workout(
                id: existing.id,
                name: trimmedName,
                summary: trimmedSummary.isEmpty ? "Custom workout." : trimmedSummary,
                exercises: exercises,
                estimatedMinutes: estimatedMinutes,
                profileType: existing.profileType
            )
            store.updateWorkout(updated)
        } else {
            let newWorkout = Workout(
                name: trimmedName,
                summary: trimmedSummary.isEmpty ? "Custom workout." : trimmedSummary,
                exercises: exercises,
                estimatedMinutes: estimatedMinutes,
                profileType: profileType
            )
            store.addWorkout(newWorkout)
        }
        dismiss()
    }
}

// MARK: - Exercise library picker sheet
struct ExerciseLibrarySheet: View {
    let equipment: Set<Equipment>
    let onPick: (Exercise) -> Void
    let onDismiss: () -> Void
    
    private var options: [Exercise] {
        WorkoutStore.exercises(using: equipment)
    }
    
    var body: some View {
        NavigationStack {
            List(options) { ex in
                Button {
                    onPick(Exercise(name: ex.name, equipment: ex.equipment, instructions: ex.instructions, sets: ex.sets, reps: ex.reps, restSeconds: ex.restSeconds))
                } label: {
                    HStack {
                        Image(systemName: ex.equipment.icon)
                            .foregroundStyle(HSTheme.accent)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ex.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("\(ex.sets) × \(ex.reps)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
        }
    }
}

// MARK: - Custom exercise sheet
struct AddCustomExerciseSheet: View {
    let allowedEquipment: Set<Equipment>
    let onAdd: (Exercise) -> Void
    let onDismiss: () -> Void
    
    @State private var name = ""
    @State private var equipment: Equipment = .dumbbells
    @State private var sets = 3
    @State private var reps = "10"
    @State private var instructions = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Exercise name", text: $name)
                Picker("Equipment", selection: $equipment) {
                    ForEach(Array(allowedEquipment), id: \.self) { eq in
                        Label(eq.rawValue, systemImage: eq.icon)
                            .tag(eq)
                    }
                }
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                TextField("Reps (e.g. 10 or 8–12 or 30 sec)", text: $reps)
                TextField("Instructions (optional)", text: $instructions, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Custom exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let ex = Exercise(
                            name: name.trimmingCharacters(in: .whitespaces),
                            equipment: equipment,
                            instructions: instructions.isEmpty ? nil : instructions,
                            sets: sets,
                            reps: reps
                        )
                        onAdd(ex)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || reps.isEmpty)
                }
            }
            .onAppear {
                if let first = allowedEquipment.first {
                    equipment = first
                }
            }
        }
    }
}

#Preview {
    DesignWorkoutView(existingWorkout: nil)
        .environmentObject(WorkoutStore())
}
