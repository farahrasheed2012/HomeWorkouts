//
//  RandomWorkoutGeneratorView.swift
//  HomeStrength
//
//  Random workout generator: inputs (equipment, duration, intensity, focus) → unique routine with option to save.
//

import SwiftUI

struct RandomWorkoutGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var store: WorkoutStore
    
    let profileType: UserProfileType
    
    @State private var selectedEquipment: Set<Equipment> = []
    @State private var duration: GeneratorDuration = .min30
    @State private var intensity: GeneratorIntensity = .medium
    @State private var focus: MuscleFocus? = .fullBody
    @State private var kidDuration: KidDuration = .medium
    @State private var kidEnergy: KidEnergyLevel = .medium
    
    @State private var generatedWorkout: Workout?
    @State private var showSaveConfirmation = false
    
    private var isYoungKid: Bool { profileType.isYoungKid }
    
    var body: some View {
        NavigationStack {
            Group {
                if let workout = generatedWorkout {
                    generatedResultView(workout)
                } else {
                    inputForm
                }
            }
            .navigationTitle(isYoungKid ? "Generate fun activities" : "Generate workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                if generatedWorkout != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("New") {
                            generatedWorkout = nil
                        }
                    }
                }
            }
        }
    }
    
    private var inputForm: some View {
        Form {
            if isYoungKid {
                Section("How long?") {
                    Picker("Duration", selection: $kidDuration) {
                        ForEach(KidDuration.allCases) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                }
                Section("Energy level") {
                    Picker("Today we feel...", selection: $kidEnergy) {
                        ForEach(KidEnergyLevel.allCases) { e in
                            Text(e.rawValue).tag(e)
                        }
                    }
                }
                Section {
                    Button {
                        generateKid()
                    } label: {
                        Label("Generate fun routine!", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
            } else {
                Section("Equipment") {
                    Text("Choose what you have. Leave all unselected for any.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(Equipment.allCases, id: \.self) { eq in
                            let isOn = selectedEquipment.contains(eq)
                            Button {
                                if isOn { selectedEquipment.remove(eq) }
                                else { selectedEquipment.insert(eq) }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: eq.icon)
                                        .font(.caption)
                                    Text(eq.rawValue)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(isOn ? Color.orange.opacity(0.3) : Color.gray.opacity(0.15))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Section("Duration") {
                    Picker("Length", selection: $duration) {
                        ForEach(GeneratorDuration.allCases) { d in
                            Text(d.label).tag(d)
                        }
                    }
                }
                Section("Intensity") {
                    Picker("Level", selection: $intensity) {
                        ForEach(GeneratorIntensity.allCases) { i in
                            Text(i.rawValue).tag(i)
                        }
                    }
                }
                Section("Focus (optional)") {
                    Picker("Muscle groups", selection: $focus) {
                        Text("Full body").tag(MuscleFocus?.none)
                        ForEach(MuscleFocus.allCases.filter { $0 != .fullBody }) { f in
                            Text(f.rawValue).tag(MuscleFocus?.some(f))
                        }
                    }
                }
                Section {
                    Button {
                        generateAdult()
                    } label: {
                        Label("Generate workout", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
        }
    }
    
    private func generatedResultView(_ workout: Workout) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(workout.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(workout.exercises.count) exercises · ~\(workout.estimatedMinutes) min")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("Exercises")
                    .font(.headline)
                ForEach(workout.exercises) { ex in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: ex.equipment.icon)
                                .foregroundStyle(isYoungKid ? .purple : .orange)
                                .frame(width: 24)
                            Text(ex.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        if let inst = ex.instructions, !inst.isEmpty {
                            Text(inst)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !isYoungKid {
                            Text("\(ex.sets) sets × \(ex.reps) · \(ex.restSeconds)s rest")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                HStack(spacing: 12) {
                    Button {
                        store.addWorkout(workout)
                        showSaveConfirmation = true
                    } label: {
                        Label("Save for later", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isYoungKid ? .purple : .orange)
                    
                    NavigationLink(value: workout) {
                        Label("Start workout", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationDestination(for: Workout.self) { w in
            WorkoutDetailView(workout: w)
        }
        .alert("Saved!", isPresented: $showSaveConfirmation) {
            Button("OK") {
                showSaveConfirmation = false
                dismiss()
            }
        } message: {
            Text("This routine was added to your workouts. Find it in your list.")
        }
    }
    
    private func generateAdult() {
        generatedWorkout = WorkoutGenerator.generate(
            equipment: selectedEquipment,
            duration: duration,
            intensity: intensity,
            focus: focus,
            profileType: profileType
        )
    }
    
    private func generateKid() {
        generatedWorkout = WorkoutGenerator.generateKidRoutine(
            duration: kidDuration,
            energyLevel: kidEnergy,
            profileType: profileType
        )
    }
}
