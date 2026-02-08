//
//  WorkoutDetailView.swift
//  HomeStrength
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var store: WorkoutStore
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var userStore: UserStore
    let workout: Workout
    @State private var completedSets: Set<String> = []
    @State private var showEditSheet = false
    @State private var showLogSheet = false
    @State private var showRestTimer = false
    @State private var restTimerSeconds = 60
    @State private var showCelebration = false
    
    private var currentWorkout: Workout {
        store.workouts.first(where: { $0.id == workout.id }) ?? workout
    }
    private var isYoungKid: Bool {
        userStore.currentUser?.profileType.isYoungKid == true
    }
    
    var body: some View {
        List {
            Section {
                Text(currentWorkout.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Estimated time: \(currentWorkout.estimatedMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Section(isYoungKid ? "What we'll do" : "Exercises") {
                ForEach(currentWorkout.exercises) { exercise in
                    ExerciseRowView(
                        exercise: exercise,
                        isCardio: currentWorkout.name == "Cardio",
                        isSimpleMode: isYoungKid,
                        completedSetIds: $completedSets,
                        onStartRest: {
                            restTimerSeconds = exercise.restSeconds
                            showRestTimer = true
                        }
                    )
                }
            }
        }
        .navigationTitle(currentWorkout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isYoungKid {
                    Button {
                        showLogSheet = true
                    } label: {
                        Label("I did it!", systemImage: "checkmark.circle.fill")
                    }
                } else {
                    Menu {
                        Button {
                            showRestTimer = true
                        } label: {
                            Label("Rest timer", systemImage: "timer")
                        }
                        Button {
                            showLogSheet = true
                        } label: {
                            Label("Complete workout", systemImage: "checkmark.circle")
                        }
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            DesignWorkoutView(existingWorkout: currentWorkout)
                .environmentObject(store)
        }
        .sheet(isPresented: $showLogSheet) {
            if let uid = userStore.currentUser?.id {
                LogWorkoutSheet(
                    workout: currentWorkout,
                    userId: uid,
                    profileType: userStore.currentUser?.profileType,
                    onLog: { completed in
                        progressStore.logWorkout(completed)
                        showLogSheet = false
                        if isYoungKid { showCelebration = true }
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            CelebrationView(onDismiss: { showCelebration = false })
        }
        .sheet(isPresented: $showRestTimer) {
            RestTimerView(initialSeconds: restTimerSeconds) {
                showRestTimer = false
            }
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    let isCardio: Bool
    var isSimpleMode: Bool = false
    @Binding var completedSetIds: Set<String>
    var onStartRest: (() -> Void)? = nil
    
    private func setId(_ exerciseId: UUID, setIndex: Int) -> String {
        "\(exerciseId.uuidString)-\(setIndex)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: exercise.equipment.icon)
                    .foregroundStyle(isSimpleMode ? .purple : .orange)
                    .frame(width: 28, alignment: .center)
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                    if !isSimpleMode {
                        Text(exercise.equipment.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if let instructions = exercise.instructions, !instructions.isEmpty {
                Text(instructions)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if isSimpleMode {
                Text(exercise.reps)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if isCardio {
                Text("\(exercise.reps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 12) {
                    Text("\(exercise.sets) sets × \(exercise.reps)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Rest \(exercise.restSeconds)s")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                HStack(spacing: 8) {
                    ForEach(0..<exercise.sets, id: \.self) { index in
                        let id = setId(exercise.id, setIndex: index)
                        Button {
                            if completedSetIds.contains(id) {
                                completedSetIds.remove(id)
                            } else {
                                completedSetIds.insert(id)
                                onStartRest?()
                            }
                        } label: {
                            Text("Set \(index + 1)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(completedSetIds.contains(id) ? Color.green.opacity(0.3) : Color.orange.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let u = UserStore()
    u.selectUser(UserStore.availableProfiles[0])
    return NavigationStack {
        WorkoutDetailView(workout: WorkoutStore.buildDefaultWorkouts()[0])
            .environmentObject(WorkoutStore())
            .environmentObject(ProgressStore())
            .environmentObject(u)
    }
}
