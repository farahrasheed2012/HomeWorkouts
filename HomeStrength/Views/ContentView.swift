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
    @State private var showDesignWorkout = false
    @State private var showGenerator = false
    
    private var currentProfileType: UserProfileType? {
        userStore.currentUser?.profileType
    }
    
    private var filteredWorkouts: [Workout] {
        guard let profile = currentProfileType else { return [] }
        return store.workouts(for: profile, using: selectedEquipment)
    }
    
    private var isYoungKid: Bool { currentProfileType?.isYoungKid == true }
    private var showGeneratorEntry: Bool {
        guard let p = currentProfileType else { return false }
        return !p.isGroupFitness
    }
    
    var body: some View {
        NavigationStack {
            List {
                if showGeneratorEntry {
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
                if !isYoungKid {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Equipment to use")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            Text("Tap to filter workouts by equipment. Leave all unselected to see all.")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Equipment.allCases, id: \.self) { eq in
                                        let isSelected = selectedEquipment.contains(eq)
                                        Button {
                                            if isSelected {
                                                selectedEquipment.remove(eq)
                                            } else {
                                                selectedEquipment.insert(eq)
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: eq.icon)
                                                    .font(.caption)
                                                Text(eq.rawValue)
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
                                .padding(.vertical, 4)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
                Section(isYoungKid ? "Activities" : "Workouts") {
                    ForEach(filteredWorkouts) { workout in
                        NavigationLink(value: workout) {
                            WorkoutRow(workout: workout)
                        }
                    }
                }
            }
            .navigationTitle(userStore.currentUser?.displayName ?? "Workouts")
            .toolbar {
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
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
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
