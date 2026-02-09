//
//  ContentView.swift
//  HomeStrength
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var store: WorkoutStore
    @EnvironmentObject var progressStore: ProgressStore
    @State private var selectedEquipment: Set<Equipment> = []
    @State private var selectedFocus: MuscleGroup?
    @State private var selectedDifficulty: DifficultyLevel?
    @State private var showDesignWorkout = false
    @State private var showGenerator = false
    @State private var showProfilePicker = false
    
    private var currentProfileType: UserProfileType? {
        userStore.currentUser?.profileType
    }
    
    private var filteredWorkouts: [Workout] {
        guard let profile = currentProfileType else { return [] }
        return store.workouts(for: profile, using: selectedEquipment, focus: selectedFocus)
    }
    
    private var filteredExercises: [Exercise] {
        let byEquipment = WorkoutStore.exercises(using: selectedEquipment)
        guard let level = selectedDifficulty else { return byEquipment }
        return byEquipment.filter { exercise in
            guard let detail = ExerciseDetailStore.detail(forExerciseName: exercise.name) else { return true }
            return detail.difficultyLevel == level
        }
    }
    
    private var isYoungKid: Bool { currentProfileType?.isYoungKid == true }
    private var showGeneratorEntry: Bool {
        guard let p = currentProfileType else { return false }
        return !p.isGroupFitness
    }
    
    // MARK: - List sections (split for type-checker)
    
    private var generatorSection: some View {
        Section {
            Button {
                showGenerator = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(isYoungKid ? .purple : .orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isYoungKid ? "Generate fun activities" : "Generate a workout")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(isYoungKid ? "Pick duration and energy—we’ll make a playful routine." : "Pick equipment, time, and focus—get a unique routine.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var equipmentSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Equipment to use")
                    .font(.subheadline)
                    .fontWeight(Font.Weight.medium)
                    .foregroundStyle(.secondary)
                Text("Select the equipment you have. Only workouts that use just these will appear. Leave all unselected to see all.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Equipment.allCases, id: \.self) { eq in
                            EquipmentChip(
                                equipment: eq,
                                isSelected: selectedEquipment.contains(eq),
                                action: {
                                    if selectedEquipment.contains(eq) {
                                        selectedEquipment.remove(eq)
                                    } else {
                                        selectedEquipment.insert(eq)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }
    
    private var muscleGroupSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Muscle group")
                    .font(.subheadline)
                    .fontWeight(Font.Weight.medium)
                    .foregroundStyle(.secondary)
                Text("Tap a focus to see workouts for that area. Tap again to clear.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MuscleGroup.allCases, id: \.self) { focus in
                            FocusChip(
                                focus: focus,
                                isSelected: selectedFocus == focus,
                                action: { selectedFocus = selectedFocus == focus ? nil : focus }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }
    
    private var difficultySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Difficulty")
                    .font(.subheadline)
                    .fontWeight(Font.Weight.medium)
                    .foregroundStyle(.secondary)
                Text("Filter exercises by level. Applies to the list below.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        DifficultyChip(label: "All", isSelected: selectedDifficulty == nil) {
                            selectedDifficulty = nil
                        }
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            DifficultyChip(
                                label: difficultyLabel(level),
                                isSelected: selectedDifficulty == level
                            ) {
                                selectedDifficulty = selectedDifficulty == level ? nil : level
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }
    
    private func difficultyLabel(_ level: DifficultyLevel) -> String {
        switch level {
        case .easy: return "Beginner"
        case .medium: return "Medium"
        case .difficult: return "Expert"
        }
    }
    
    private var workoutsSection: some View {
        Section(isYoungKid ? "Activities" : "Workouts") {
            ForEach(filteredWorkouts) { workout in
                NavigationLink(value: workout) {
                    WorkoutRow(workout: workout)
                }
            }
        }
    }
    
    @ViewBuilder
    private var allExercisesSection: some View {
        if !isYoungKid && !selectedEquipment.isEmpty {
            Section {
                ForEach(filteredExercises) { exercise in
                    ExerciseListRow(exercise: exercise)
                }
            } header: {
                Text("All exercises (\(filteredExercises.count))")
            } footer: {
                Text("Tap an exercise for steps and tips. Use Design workout to add these to a custom routine.")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if showGeneratorEntry { generatorSection }
                if !isYoungKid {
                    equipmentSection
                    muscleGroupSection
                    if !selectedEquipment.isEmpty { difficultySection }
                }
                workoutsSection
                allExercisesSection
            }
            .navigationTitle(userStore.currentUser?.displayName ?? "Workouts")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showProfilePicker) {
                UserSelectionView(onProfileSelected: { showProfilePicker = false })
                    .environmentObject(userStore)
            }
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
            .navigationDestination(for: ExerciseDetail.self) { detail in
                ExerciseDetailView(detail: detail)
            }
            .sheet(isPresented: $showDesignWorkout) {
                DesignWorkoutView(existingWorkout: nil, profileType: currentProfileType ?? .mom)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showGenerator) {
                if let profile = currentProfileType {
                    RandomWorkoutGeneratorView(profileType: profile)
                        .environmentObject(userStore)
                        .environmentObject(store)
                        .environmentObject(progressStore)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    showProfilePicker = true
                } label: {
                    Label("Switch profile", systemImage: "person.2")
                }
                Button(role: .destructive) {
                    userStore.signOut()
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } label: {
                Label(userStore.currentUser?.displayName ?? "Profile", systemImage: "person.circle")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            if !isYoungKid {
                Button {
                    showDesignWorkout = true
                } label: {
                    Label("Design workout", systemImage: "plus.square.on.square")
                }
            }
        }
    }
}

// MARK: - Helper views (reduce type-check complexity in ContentView)

private struct EquipmentChip: View {
    let equipment: Equipment
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: equipment.icon)
                    .font(.caption)
                Text(equipment.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange.opacity(0.35) : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FocusChip: View {
    let focus: MuscleGroup
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: focus.icon)
                    .font(.caption)
                Text(focus.displayName)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange.opacity(0.35) : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct DifficultyChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange.opacity(0.35) : Color.gray.opacity(0.2))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ExerciseListRow: View {
    let exercise: Exercise
    
    var body: some View {
        Group {
            if let detail = ExerciseDetailStore.detail(forExerciseName: exercise.name) {
                NavigationLink(value: detail) {
                    rowContent
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: exercise.equipment.icon)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 36)
                    Text(exercise.name)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var rowContent: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.equipment.icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(Font.Weight.medium)
                Text(exercise.equipment.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.orange)
                    .frame(width: 32, alignment: .center)
                Text(workout.name)
                    .font(.headline)
            }
            Text(workout.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(workout.exercises.count) exercises · ~\(workout.estimatedMinutes) min")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    let userStore = UserStore()
    userStore.selectUser(UserStore.availableProfiles[0])
    return ContentView()
        .environmentObject(userStore)
        .environmentObject(WorkoutStore())
        .environmentObject(ProgressStore())
}
