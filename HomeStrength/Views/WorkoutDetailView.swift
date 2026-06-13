//
//  WorkoutDetailView.swift
//  HomeStrength
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var store: WorkoutStore
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var appSettings: AppSettingsStore
    let workout: Workout
    var startGuidedOnAppear = false
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
    @State private var elapsedSeconds = 0
    @State private var sessionState: WorkoutSessionState = .ready
    @State private var showGuidedComplete = false
    @State private var showStopConfirmation = false
    @State private var afterRestGoToNextExercise = false
    @State private var showExerciseInstructions = false

    private enum WorkoutSessionState {
        case ready, running, paused
    }
    
    private var currentWorkout: Workout {
        store.workouts.first(where: { $0.id == workout.id }) ?? workout
    }
    private var isYoungKid: Bool {
        userStore.currentUser?.profileType.isYoungKid == true
    }
    private var isCardio: Bool { currentWorkout.name == "Cardio" }
    /// Today's exercise set: random subset when workout has 10+ exercises so each day is unique.
    private var exercises: [Exercise] { currentWorkout.exercisesForToday() }
    
    private var formattedElapsed: String {
        String(format: "%d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
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
        listBody
        .navigationTitle(currentWorkout.name)
        .inlineNavigationBarTitle()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    startGuidedMode()
                } label: {
                    Label(
                        isYoungKid ? "Start activities" : "Start workout",
                        systemImage: "play.circle.fill"
                    )
                }
                .disabled(exercises.isEmpty)
            }
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
        .onAppear {
            if startGuidedOnAppear && !isGuidedMode {
                startGuidedMode()
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
        .platformFullScreenCover(isPresented: $showCelebration) {
            CelebrationView(onDismiss: { showCelebration = false })
        }
        .sheet(isPresented: $showRestTimer) {
            RestTimerView(initialSeconds: restTimerSeconds) {
                showRestTimer = false
            }
        }
        .platformFullScreenCover(isPresented: $isGuidedMode, onDismiss: endGuidedMode) {
            NavigationStack {
                guidedWorkoutBody
                    .navigationTitle(currentWorkout.name)
                    .inlineNavigationBarTitle()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Exit") {
                                if sessionState == .ready {
                                    endGuidedMode()
                                } else {
                                    showStopConfirmation = true
                                }
                            }
                        }
                    }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                guard sessionState == .running else { return }
                elapsedSeconds += 1
                if restCountdown > 0 {
                    restCountdown -= 1
                    if restCountdown == 0 {
                        advanceToNext()
                    }
                }
            }
            .alert("Stop workout?", isPresented: $showStopConfirmation) {
                Button("Keep going", role: .cancel) {}
                Button("Stop workout", role: .destructive) {
                    finishGuidedWorkoutEarly()
                }
            } message: {
                Text("Your elapsed time will be saved and you can log what you completed.")
            }
            .appReadabilitySettings(appSettings)
        }
        .appReadabilitySettings(appSettings)
    }
    
    private var listBody: some View {
        #if os(macOS)
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                workoutSummarySection
                workoutExercisesSection
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        List {
            workoutSummarySection
            workoutExercisesSection
        }
        #endif
    }

    private var workoutSummarySection: some View {
        Group {
            #if os(macOS)
            VStack(alignment: .leading, spacing: 12) {
                summaryContent
                startWorkoutButton
            }
            .padding()
            .background(PlatformColor.secondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            #else
            Section {
                summaryContent
                startWorkoutButton
            }
            #endif
        }
    }

    private var summaryContent: some View {
        Group {
            Text(currentWorkout.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Estimated time: \(currentWorkout.estimatedMinutes) min")
                .font(.caption)
                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
        }
    }

    private var startWorkoutButton: some View {
        Button {
            startGuidedMode()
        } label: {
            Label(isYoungKid ? "Start activities (timed & auto-advance)" : "Start workout (timed & auto-advance)", systemImage: "play.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                #if os(macOS)
                .background(HSTheme.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                #endif
        }
        .platformListActionButtonStyle()
        .tint(HSTheme.accent)
        #if !os(macOS)
        .listRowBackground(Color.clear)
        #endif
    }

    @ViewBuilder
    private var workoutExercisesSection: some View {
        #if os(macOS)
        VStack(alignment: .leading, spacing: 12) {
            Text(isYoungKid ? "What we'll do" : "Exercises")
                .font(.headline)
            if currentWorkout.exercises.count > exercises.count && !isYoungKid {
                Text("Today's \(exercises.count) of \(currentWorkout.exercises.count) — different day, different mix.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(currentWorkout.exercises) { exercise in
                exerciseCard(exercise)
            }
        }
        #else
        Section(header: Text(isYoungKid ? "What we'll do" : "Exercises"), footer: currentWorkout.exercises.count > exercises.count && !isYoungKid ? Text("Today's \(exercises.count) of \(currentWorkout.exercises.count) — different day, different mix.") : Text("")) {
            ForEach(currentWorkout.exercises) { exercise in
                exerciseCard(exercise)
            }
        }
        #endif
    }

    private func exerciseCard(_ exercise: Exercise) -> some View {
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
                    .environmentObject(appSettings)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 4)
        #if os(macOS)
        .padding()
        .background(PlatformColor.secondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        #endif
    }
    
    private var guidedWorkoutBody: some View {
        Group {
            if showGuidedComplete {
                guidedCompleteView
            } else if let exercise = currentExercise {
                ScrollView {
                    VStack(spacing: HSTheme.spaceLG) {
                        elapsedTimerBlock
                        progressBlock(exercise: exercise)
                        focusedExerciseBlock(exercise: exercise)
                        if restCountdown > 0 {
                            restBlock
                        } else {
                            completeSetButton(exercise: exercise)
                        }
                        if sessionState == .ready {
                            Text("Tap Start when you're ready — the timer begins once you do.")
                                .font(HSTheme.font(.workoutMeta, largeText: appSettings.largeText))
                                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(HSTheme.contentPaddingH)
                    .workoutReadableContent()
                }
                .workoutContentLayout()
                .onChange(of: guidedExerciseIndex) { _, _ in
                    showExerciseInstructions = false
                }
                .onChange(of: guidedSetIndex) { _, _ in
                    showExerciseInstructions = false
                }
            } else {
                guidedCompleteView
            }
        }
    }
    
    private var elapsedTimerBlock: some View {
        VStack(spacing: HSTheme.spaceMD) {
            HStack {
                Image(systemName: "timer")
                    .foregroundStyle(HSTheme.accent)
                Text(formattedElapsed)
                    .font(HSTheme.font(.timer, largeText: appSettings.largeText))
                    .monospacedDigit()
                Text(timerStatusLabel)
                    .font(HSTheme.font(.timerLabel, largeText: appSettings.largeText))
                    .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            }
            workoutTimerControls
        }
        .frame(maxWidth: .infinity)
        .padding(HSTheme.spaceMD)
        .background(HSTheme.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: HSTheme.radiusMD))
    }

    private var timerStatusLabel: String {
        switch sessionState {
        case .ready: return "ready"
        case .running: return restCountdown > 0 ? "resting" : "elapsed"
        case .paused: return "paused"
        }
    }

    private var workoutTimerControls: some View {
        HStack(spacing: 10) {
            switch sessionState {
            case .ready:
                workoutControlButton(title: "Start", systemImage: "play.fill", prominent: true) {
                    startSessionTimer()
                }
            case .running:
                workoutControlButton(title: "Pause", systemImage: "pause.fill") {
                    pauseSessionTimer()
                }
            case .paused:
                workoutControlButton(title: "Resume", systemImage: "play.fill", prominent: true) {
                    resumeSessionTimer()
                }
            }

            workoutControlButton(title: "Stop", systemImage: "stop.fill") {
                showStopConfirmation = true
            }
            .disabled(sessionState == .ready)

            workoutControlButton(title: skipButtonTitle, systemImage: "forward.fill") {
                skipFromControls()
            }
            .disabled(sessionState == .ready)
        }
    }

    private var skipButtonTitle: String {
        if restCountdown > 0 { return "Skip rest" }
        return isYoungKid ? "Skip activity" : "Skip"
    }

    private func workoutControlButton(
        title: String,
        systemImage: String,
        prominent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Group {
            if prominent {
                Button(action: action) {
                    Label(title, systemImage: systemImage)
                        .font(HSTheme.font(.controlButton, largeText: appSettings.largeText))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, appSettings.largeText ? 12 : 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(HSTheme.accent)
            } else {
                Button(action: action) {
                    Label(title, systemImage: systemImage)
                        .font(HSTheme.font(.controlButton, largeText: appSettings.largeText))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, appSettings.largeText ? 12 : 10)
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private func progressBlock(exercise: Exercise) -> some View {
        let exNum = guidedExerciseIndex + 1
        let totalEx = exercises.count
        let setNum = min(guidedSetIndex + 1, exercise.sets)
        let totalSets = exercise.sets
        return HStack(spacing: HSTheme.spaceMD) {
            Text("Exercise \(exNum) of \(totalEx)")
                .font(HSTheme.font(.workoutMeta, largeText: appSettings.largeText))
                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            Text("Set \(setNum) of \(totalSets)")
                .font(HSTheme.font(.workoutMeta, largeText: appSettings.largeText))
                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
        }
        .frame(maxWidth: .infinity)
    }

    private func focusedExerciseBlock(exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: HSTheme.spaceMD) {
            HStack(spacing: 12) {
                Image(systemName: exercise.equipment.icon)
                    .font(HSTheme.font(.workoutSubtitle, largeText: appSettings.largeText))
                    .foregroundStyle(HSTheme.accent)
                Text(exercise.name)
                    .font(HSTheme.font(.workoutTitle, largeText: appSettings.largeText))
            }

            if let instructions = exercise.instructions, !instructions.isEmpty {
                Text(instructions)
                    .font(HSTheme.font(.workoutBody, largeText: appSettings.largeText))
                    .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            }

            if isCardio || exercise.sets == 1 {
                Text(exercise.reps)
                    .font(HSTheme.font(.workoutSubtitle, largeText: appSettings.largeText))
                    .foregroundStyle(.primary)
            } else {
                Text("\(exercise.sets) sets × \(exercise.reps)")
                    .font(HSTheme.font(.workoutSubtitle, largeText: appSettings.largeText))
                    .foregroundStyle(.primary)
                Text("Rest \(exercise.restSeconds)s between sets")
                    .font(HSTheme.font(.workoutMeta, largeText: appSettings.largeText))
                    .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            }

            if let detail = ExerciseDetailStore.detail(forExerciseName: exercise.name), !isYoungKid {
                VStack(alignment: .leading, spacing: HSTheme.spaceSM) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showExerciseInstructions.toggle()
                        }
                    } label: {
                        HStack {
                            Text(showExerciseInstructions ? "Hide instructions" : "Show instructions")
                                .font(HSTheme.font(.sectionHeader, largeText: appSettings.largeText))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: showExerciseInstructions ? "chevron.up" : "chevron.down")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if showExerciseInstructions {
                        ExerciseStepsCard(detail: detail, compact: false, workoutMode: true)
                            .environmentObject(appSettings)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HSTheme.spaceMD)
        .background(
            PlatformColor.secondaryGroupedBackground,
            in: RoundedRectangle(cornerRadius: HSTheme.radiusMD)
        )
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
                    .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            }
            if let detail = ExerciseDetailStore.detail(forExerciseName: exercise.name) {
                ExerciseStepsCard(detail: detail, compact: false)
                    .environmentObject(appSettings)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(PlatformColor.secondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var restBlock: some View {
        VStack(spacing: HSTheme.spaceSM) {
            Text("Rest")
                .font(HSTheme.font(.sectionHeader, largeText: appSettings.largeText))
                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            Text("\(restCountdown)s")
                .font(.system(size: appSettings.largeText ? 52 : 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(restCountdown <= 10 ? HSTheme.accent : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(HSTheme.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: HSTheme.radiusMD))
    }
    
    private func completeSetButton(exercise: Exercise) -> some View {
        let isSingleSet = isCardio || exercise.sets <= 1 || isYoungKid
        let label = isSingleSet ? "Done with this \(isYoungKid ? "activity" : "exercise")" : "Complete set \(guidedSetIndex + 1)"
        return Button {
            completeCurrentSet(exercise: exercise)
        } label: {
            Label(label, systemImage: "checkmark.circle.fill")
                .font(HSTheme.font(.workoutSubtitle, largeText: appSettings.largeText))
                .frame(maxWidth: .infinity)
                .padding(.vertical, appSettings.largeText ? 18 : 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(HSTheme.accent)
        .disabled(sessionState == .ready)
    }
    
    private var guidedCompleteView: some View {
        VStack(spacing: HSTheme.spaceLG) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: appSettings.largeText ? 72 : 64))
                .foregroundStyle(HSTheme.accent)
            Text("Workout complete!")
                .font(HSTheme.font(.workoutTitle, largeText: appSettings.largeText))
            Text("Time: \(formattedElapsed)")
                .font(HSTheme.font(.workoutSubtitle, largeText: appSettings.largeText))
                .foregroundStyle(HSTheme.secondaryText(highContrast: appSettings.highContrast))
            Button {
                endGuidedMode()
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
        .workoutReadableContent()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .workoutContentLayout()
    }
    
    private func startGuidedMode() {
        guard !exercises.isEmpty else { return }
        guidedExerciseIndex = 0
        guidedSetIndex = 0
        restCountdown = 0
        elapsedSeconds = 0
        sessionState = .ready
        showGuidedComplete = false
        showStopConfirmation = false
        showExerciseInstructions = false
        isGuidedMode = true
    }
    
    private func endGuidedMode() {
        isGuidedMode = false
        showGuidedComplete = false
        showStopConfirmation = false
        guidedExerciseIndex = 0
        guidedSetIndex = 0
        restCountdown = 0
        elapsedSeconds = 0
        sessionState = .ready
    }

    private func startSessionTimer() {
        sessionState = .running
    }

    private func pauseSessionTimer() {
        sessionState = .paused
    }

    private func resumeSessionTimer() {
        sessionState = .running
    }

    private func finishGuidedWorkoutEarly() {
        sessionState = .paused
        showGuidedComplete = true
    }

    private func skipFromControls() {
        if restCountdown > 0 {
            restCountdown = 0
            advanceToNext()
        } else {
            skipCurrent()
        }
    }
    
    private func completeCurrentSet(exercise: Exercise) {
        if isLastSetOfExercise && !hasMoreExercises {
            sessionState = .paused
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
            sessionState = .paused
            showGuidedComplete = true
        }
    }
}

/// Steps, tips, safety, and variations for an exercise (like Group Fitness routine detail).
struct ExerciseStepsCard: View {
    @EnvironmentObject var appSettings: AppSettingsStore
    let detail: ExerciseDetail
    var compact: Bool = true
    var workoutMode: Bool = false

    private var bodyFont: Font {
        workoutMode
            ? HSTheme.font(.workoutBody, largeText: appSettings.largeText)
            : (compact ? .callout : .body)
    }

    private var metaFont: Font {
        workoutMode
            ? HSTheme.font(.workoutMeta, largeText: appSettings.largeText)
            : (compact ? .subheadline : .callout)
    }

    private var headerFont: Font {
        workoutMode
            ? HSTheme.font(.sectionHeader, largeText: appSettings.largeText)
            : .subheadline.weight(.semibold)
    }

    private var secondaryColor: Color {
        HSTheme.secondaryText(highContrast: appSettings.highContrast)
    }

    private var metaColor: Color {
        HSTheme.metaText(highContrast: appSettings.highContrast)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !compact && !detail.summary.isEmpty {
                Text(detail.summary)
                    .font(bodyFont)
                    .foregroundStyle(secondaryColor)
            }
            if !detail.steps.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("How to do it")
                        .font(headerFont)
                    ForEach(Array(detail.steps.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .top, spacing: 6) {
                            Text("\(i + 1).")
                                .font(metaFont)
                                .fontWeight(.medium)
                            Text(step)
                                .font(bodyFont)
                                .foregroundStyle(secondaryColor)
                        }
                    }
                }
            }
            if !detail.tips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tips")
                        .font(headerFont)
                    ForEach(detail.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(metaFont)
                                .foregroundStyle(HSTheme.accent)
                            Text(tip)
                                .font(bodyFont)
                                .foregroundStyle(secondaryColor)
                        }
                    }
                }
            }
            if !detail.muscles.isEmpty && !detail.isKidFriendly {
                Text("Muscles: \(detail.muscles.joined(separator: ", "))")
                    .font(metaFont)
                    .foregroundStyle(metaColor)
            }
            if let safety = detail.safetyNote, !safety.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Safety")
                        .font(headerFont)
                    Text(safety)
                        .font(bodyFont)
                        .foregroundStyle(secondaryColor)
                }
            }
            if detail.easyVariation != nil || detail.mediumVariation != nil || detail.difficultVariation != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Variations by level")
                        .font(headerFont)
                    if let e = detail.easyVariation, !e.isEmpty {
                        Text("Easy: \(e)")
                            .font(bodyFont)
                            .foregroundStyle(secondaryColor)
                    }
                    if let m = detail.mediumVariation, !m.isEmpty {
                        Text("Medium: \(m)")
                            .font(bodyFont)
                            .foregroundStyle(secondaryColor)
                    }
                    if let d = detail.difficultVariation, !d.isEmpty {
                        Text("Difficult: \(d)")
                            .font(bodyFont)
                            .foregroundStyle(secondaryColor)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PlatformColor.tertiaryGroupedBackground)
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
                        .foregroundStyle(.secondary)
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
            .environmentObject(AppSettingsStore())
    }
}
