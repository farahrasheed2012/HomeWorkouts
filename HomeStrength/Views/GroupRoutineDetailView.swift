//
//  GroupRoutineDetailView.swift
//  HomeStrength
//
//  Full routine view: warm-up, main sections, cool-down, timing cues, modifications (low/intermediate/pro), instructor cues, BPM, space.
//

import SwiftUI

struct GroupRoutineDetailView: View {
    @EnvironmentObject var groupFitnessStore: GroupFitnessStore
    @EnvironmentObject var userStore: UserStore
    let routine: GroupFitnessRoutine
    @State private var showTimer = false
    @State private var showDurationSheet = false
    @State private var selectedSessionMinutes: Int = 30
    @State private var showLogSheet = false
    @State private var showProfilePicker = false
    
    private var currentRoutine: GroupFitnessRoutine {
        groupFitnessStore.allRoutines.first { $0.id == routine.id } ?? routine
    }
    
    /// Routine scaled to the currently selected class duration (section mins and exercise work/rest adapt).
    private var scaledRoutine: (warmUp: ScaledSectionView, mainSections: [ScaledSectionView], coolDown: ScaledSectionView, displayMinutes: Int) {
        currentRoutine.scaled(toTargetMinutes: selectedSessionMinutes)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                overviewCard
                classDurationCard
                sectionCard("Warm-up", section: scaledRoutine.warmUp)
                ForEach(scaledRoutine.mainSections) { section in
                    sectionCard(section.name, section: section)
                }
                sectionCard("Cool-down", section: scaledRoutine.coolDown)
                spaceAndNotesCard
                scalingCard
            }
            .padding()
        }
        .navigationTitle(currentRoutine.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
                Menu {
                    Button {
                        showDurationSheet = true
                    } label: {
                        Label("Start class timer", systemImage: "timer")
                    }
                    Button {
                        showLogSheet = true
                    } label: {
                        Label("Log class led", systemImage: "checkmark.circle")
                    }
                    Button {
                        _ = groupFitnessStore.duplicateRoutine(currentRoutine)
                    } label: {
                        Label("Duplicate & customize", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showProfilePicker) {
            UserSelectionView(onProfileSelected: { showProfilePicker = false })
                .environmentObject(userStore)
        }
        .sheet(isPresented: $showDurationSheet) {
            GroupClassDurationSheet(
                routineName: currentRoutine.name,
                defaultMinutes: currentRoutine.estimatedMinutes,
                selectedMinutes: $selectedSessionMinutes,
                onStart: {
                    showDurationSheet = false
                    showTimer = true
                },
                onCancel: { showDurationSheet = false }
            )
        }
        .fullScreenCover(isPresented: $showTimer) {
            ClassTimerView(
                routine: currentRoutine,
                sessionMinutes: selectedSessionMinutes,
                onDismiss: { showTimer = false },
                onClassComplete: {
                    showTimer = false
                    showLogSheet = true
                }
            )
        }
        .sheet(isPresented: $showLogSheet) {
            if let uid = userStore.currentUser?.id {
                LogClassSheet(
                    routine: currentRoutine,
                    userId: uid,
                    onLog: { groupFitnessStore.logClass($0); showLogSheet = false }
                )
            }
        }
        .onAppear {
            selectedSessionMinutes = closestClassDuration(to: currentRoutine.estimatedMinutes)
        }
        .onChange(of: currentRoutine.id) { _ in
            selectedSessionMinutes = closestClassDuration(to: currentRoutine.estimatedMinutes)
        }
    }
    
    private func closestClassDuration(to minutes: Int) -> Int {
        let options = GroupClassDuration.allCases.map(\.minutes)
        return options.min(by: { abs($0 - minutes) < abs($1 - minutes) }) ?? 30
    }
    
    private var classDurationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Class duration")
                .font(.headline)
            Text("Set how long the timer will run when you start the class. Tap \"Start class timer\" in the menu to begin.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Duration", selection: $selectedSessionMinutes) {
                ForEach(GroupClassDuration.allCases) { d in
                    Text(d.label).tag(d.minutes)
                }
            }
            .pickerStyle(.menu)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var overviewCard: some View {
        let scaled = scaledRoutine
        let isScaled = selectedSessionMinutes != currentRoutine.estimatedMinutes
        return VStack(alignment: .leading, spacing: 8) {
            Label(currentRoutine.format.rawValue, systemImage: currentRoutine.format.icon)
                .font(.subheadline)
                .foregroundStyle(.teal)
            Text(isScaled ? "\(scaled.displayMinutes) min class (scaled from \(currentRoutine.estimatedMinutes) min) · Bodyweight only · Mixed levels" : "\(scaled.displayMinutes) min · Bodyweight only · Mixed levels")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let notes = currentRoutine.generalNotes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func sectionCard(_ title: String, section: ScaledSectionView) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(section.durationMinutes) min")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let bpm = section.bpmSuggested {
                Text("Music: ~\(bpm) BPM")
                    .font(.caption)
                    .foregroundStyle(.teal)
            }
            if !section.instructorCues.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Timing & cues")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    ForEach(section.instructorCues, id: \.self) { cue in
                        Text("• \(cue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            ForEach(section.exercises) { ex in
                scaledExerciseRow(ex)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func scaledExerciseRow(_ ex: ScaledExerciseView) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ex.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(ex.workSeconds)s work · \(ex.restSeconds)s rest")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if ex.postpartumSafe {
                Text("Pelvic floor safe")
                    .font(.caption2)
                    .foregroundStyle(.teal)
            }
            Group {
                Text("Low-key (postpartum/beginner): \(ex.lowKeyOption)")
                    .font(.caption)
                Text("Intermediate: \(ex.intermediateOption)")
                    .font(.caption)
                Text("Pro/advanced: \(ex.proOption)")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            if let form = ex.formNotes, !form.isEmpty {
                Text("Form: \(form)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if !ex.motivationalCues.isEmpty {
                Text("Callouts: \(ex.motivationalCues.joined(separator: " · "))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var spaceAndNotesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Space requirements")
                .font(.headline)
            Text(currentRoutine.spaceRequirements)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var scalingCard: some View {
        Group {
            if let scaling = currentRoutine.scalingNotes, !scaling.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scaling (real-time)")
                        .font(.headline)
                    Text(scaling)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
