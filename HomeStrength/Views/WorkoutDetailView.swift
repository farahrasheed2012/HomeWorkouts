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
    
    // Guided workout: time tracking and auto-advance
    @State private var isGuidedMode = false
    @State private var guidedExerciseIndex = 0
    @State private var guidedSetIndex = 0
    @State private var restCountdown = 0
    @State private var workoutStartDate: Date?
    @State private var tick = 0
    @State private var showGuidedComplete = false
    @State private var afterRestGoToNextExercise = false
    
    private var currentWorkout: Workout {
        store.workouts.first(where: { $0.id == workout.id }) ?? workout
    }
    private var isYoungKid: Bool {
        userStore.currentUser?.profileType.isYoungKid == true
    }
    private var isCardio: Bool { currentWorkout.name == "Cardio" }
    /// Today's exercise set: random subset when workout has 10+ exercises so each day is unique.
    private var exercises: [Exercise] { currentWorkout.exercisesForToday() }
    
    private var elapsedSeconds: Int {
        guard let start = workoutStartDate else { return 0 }
        return max(0, Int(Date().timeIntervalSince(start)))
    }
    
    private var currentExercise: Exercise? {
        guard guidedExerciseIndex < exercises.count else { return nil }
        return exercises[guidedExerciseIndex]
    }
    
    private var isLastSetOfExercise: Bool {
        guard let ex = currentExercise else { return true }
        return guidedSetIndex >= ex.sets - 1
    }
    
    private var hasMoreExercises: Bool {
        guidedExerciseIndex < exercises.count - 1
    }
    
    private var isWorkoutComplete: Bool {
        guard currentExercise != nil else { return true }
        return guidedExerciseIndex >= exercises.count - 1 && isLastSetOfExercise && restCountdown == 0
    }
    
    var body: some View {
        Group {
            if isGuidedMode {
                guidedWorkoutBody
            } else {
                listBody
            }
        }
        .navigationTitle(currentWorkout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isGuidedMode {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") {
                        endGuidedMode()
                    }
                }
            } else {
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
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isGuidedMode else { return }
            tick = tick + 1
            if restCountdown > 0 {
                restCountdown -= 1
                if restCountdown == 0 {
                    advanceToNext()
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
    
    private var listBody: some View {
        List {
            Section {
                Text(currentWorkout.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Estimated time: \(currentWorkout.estimatedMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Button {
                    startGuidedMode()
                } label: {
                    Label(isYoungKid ? "Start activities (timed & auto-advance)" : "Start workout (timed & auto-advance)", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(HSTheme.accent)
            }
            
            Section(header: Text(isYoungKid ? "What we'll do" : "Exercises"), footer: currentWorkout.exercises.count > exercises.count && !isYoungKid ? Text("Today's \(exercises.count) of \(currentWorkout.exercises.count) — different day, different mix.") : Text("")) {
                ForEach(currentWorkout.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 0) {
                        ExerciseRowView(
                            exercise: exercise,
                            isCardio: isCardio,
                            isSimpleMode: isYoungKid,
                            completedSetIds: $completedSets,
                            onStartRest: {
                                restTimerSeconds = exercise.restSeconds
                                showRestTimer = true
                            }
                        )
                        if let detail = ExerciseDetailStore.detail(forExerciseName: exercise.name), !isYoungKid {
                            ExerciseStepsCard(detail: detail)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var guidedWorkoutBody: some View {
        Group {
            if showGuidedComplete {
                guidedCompleteView
            } else if let exercise = currentExercise {
                ScrollView {
                    VStack(spacing: 24) {
                        elapsedTimerBlock
                        progressBlock(exercise: exercise)
                        exerciseBlock(exercise: exercise)
                        if restCountdown > 0 {
                            VStack(spacing: 16) {
                                restBlock
                                Button {
                                    restCountdown = 0
                                    advanceToNext()
                                } label: {
                                    Label("Skip rest", systemImage: "forward.fill")
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            VStack(spacing: 12) {
                                completeSetButton(exercise: exercise)
                                Button {
                                    skipCurrent()
                                } label: {
                                    Label("Skip \(isYoungKid ? "activity" : "exercise")", systemImage: "forward.fill")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                guidedCompleteView
            }
        }
    }
    
    private var elapsedTimerBlock: some View {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return HStack {
            Image(systemName: "timer")
                .foregroundStyle(HSTheme.accent)
            Text(String(format: "%d:%02d", m, s))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text("elapsed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(HSTheme.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func progressBlock(exercise: Exercise) -> some View {
        let exNum = guidedExerciseIndex + 1
        let totalEx = exercises.count
        let setNum = min(guidedSetIndex + 1, exercise.sets)
        let totalSets = exercise.sets
        return HStack(spacing: 16) {
            Text("Exercise \(exNum) of \(totalEx)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Set \(setNum) of \(totalSets)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func exerciseBlock(exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: exercise.equipment.icon)
                    .font(.title2)
                    .foregroundStyle(HSTheme.accent)
                Text(exercise.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            if let instructions = exercise.instructions, !instructions.isEmpty {
                Text(instructions)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if isCardio || exercise.sets == 1 {
                Text(exercise.reps)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(exercise.sets) sets × \(exercise.reps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Rest \(exercise.restSeconds)s between sets")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            if let detail = ExerciseDetailStore.detail(forExerciseName: exercise.name) {
                ExerciseStepsCard(detail: detail, compact: false)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var restBlock: some View {
        VStack(spacing: 8) {
            Text("Rest")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(restCountdown)s")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(restCountdown <= 10 ? HSTheme.accent : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(HSTheme.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func completeSetButton(exercise: Exercise) -> some View {
        let isSingleSet = isCardio || exercise.sets <= 1 || isYoungKid
        let label = isSingleSet ? "Done with this \(isYoungKid ? "activity" : "exercise")" : "Complete set \(guidedSetIndex + 1)"
        return Button {
            completeCurrentSet(exercise: exercise)
        } label: {
            Label(label, systemImage: "checkmark.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(HSTheme.accent)
    }
    
    private var guidedCompleteView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(HSTheme.accent)
            Text("Workout complete!")
                .font(.title)
                .fontWeight(.bold)
            let m = elapsedSeconds / 60
            let s = elapsedSeconds % 60
            Text("Time: \(m):\(String(format: "%02d", s))")
                .font(.title2)
                .foregroundStyle(.secondary)
            Button {
                showGuidedComplete = false
                showLogSheet = true
            } label: {
                Label("Log workout", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(HSTheme.accent)
            Button {
                endGuidedMode()
            } label: {
                Text("Done")
            }
            .buttonStyle(.bordered)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func startGuidedMode() {
        isGuidedMode = true
        guidedExerciseIndex = 0
        guidedSetIndex = 0
        restCountdown = 0
        workoutStartDate = Date()
        showGuidedComplete = false
    }
    
    private func endGuidedMode() {
        isGuidedMode = false
        workoutStartDate = nil
        showGuidedComplete = false
    }
    
    private func completeCurrentSet(exercise: Exercise) {
        if isLastSetOfExercise && !hasMoreExercises {
            showGuidedComplete = true
            return
        }
        let restSeconds = exercise.restSeconds
        if restSeconds > 0 && (!isLastSetOfExercise || hasMoreExercises) {
            afterRestGoToNextExercise = isLastSetOfExercise
            restCountdown = restSeconds
        } else {
            advanceToNext()
        }
    }
    
    private func advanceToNext() {
        if afterRestGoToNextExercise {
            guidedExerciseIndex += 1
            guidedSetIndex = 0
            afterRestGoToNextExercise = false
        } else if let ex = currentExercise, guidedSetIndex < ex.sets - 1 {
            guidedSetIndex += 1
        }
    }
    
    /// Skip the current exercise (or current set) and go to the next. Does not mark as complete.
    private func skipCurrent() {
        if hasMoreExercises {
            guidedExerciseIndex += 1
            guidedSetIndex = 0
        } else {
            showGuidedComplete = true
        }
    }
}

/// Steps, tips, safety, and variations for an exercise (like Group Fitness routine detail).
struct ExerciseStepsCard: View {
    let detail: ExerciseDetail
    var compact: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !compact && !detail.summary.isEmpty {
                Text(detail.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if !detail.steps.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("How to do it")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    ForEach(Array(detail.steps.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .top, spacing: 6) {
                            Text("\(i + 1).")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(step)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            if !detail.tips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tips")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    ForEach(detail.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(HSTheme.accent)
                            Text(tip)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            if !detail.muscles.isEmpty && !detail.isKidFriendly {
                Text("Muscles: \(detail.muscles.joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if let safety = detail.safetyNote, !safety.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Safety")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(safety)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if detail.easyVariation != nil || detail.mediumVariation != nil || detail.difficultVariation != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Variations by level")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if let e = detail.easyVariation, !e.isEmpty {
                        Text("Easy: \(e)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let m = detail.mediumVariation, !m.isEmpty {
                        Text("Medium: \(m)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let d = detail.difficultVariation, !d.isEmpty {
                        Text("Difficult: \(d)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    .foregroundStyle(HSTheme.accent)
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
                                .background(completedSetIds.contains(id) ? HSTheme.accentFill : HSTheme.tertiaryFill)
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
