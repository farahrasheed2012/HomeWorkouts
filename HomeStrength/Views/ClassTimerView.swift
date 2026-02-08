//
//  ClassTimerView.swift
//  HomeStrength
//
//  Full-session timer for leading a class (e.g. 35 min). Audio/haptic when time is ending.
//

import SwiftUI
import AudioToolbox

@MainActor
final class ClassTimerState: ObservableObject {
    @Published var remainingSeconds: Int
    @Published var isRunning = false
    private var timer: Timer?
    private let totalSeconds: Int
    
    init(totalMinutes: Int) {
        self.totalSeconds = totalMinutes * 60
        self.remainingSeconds = totalMinutes * 60
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func tick() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            if remainingSeconds == 60 {
                AudioServicesPlaySystemSound(1057)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            if remainingSeconds == 0 {
                AudioServicesPlaySystemSound(1304)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                stop()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        stop()
        remainingSeconds = totalSeconds
    }
    
    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

/// Duration options for group fitness class timer (minutes).
enum GroupClassDuration: Int, CaseIterable, Identifiable {
    case min15 = 15
    case min20 = 20
    case min25 = 25
    case min30 = 30
    case min35 = 35
    case min40 = 40
    case min45 = 45
    case min60 = 60
    var minutes: Int { rawValue }
    var label: String { "\(rawValue) min" }
    var id: Int { rawValue }
}

struct GroupClassDurationSheet: View {
    let routineName: String
    let defaultMinutes: Int
    @Binding var selectedMinutes: Int
    let onStart: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Set how long this class will run. The timer will count down from this duration.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("Class duration") {
                    Picker("Length", selection: $selectedMinutes) {
                        ForEach(GroupClassDuration.allCases) { d in
                            Text(d.label).tag(d.minutes)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section {
                    Button {
                        onStart()
                    } label: {
                        Label("Start timer", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                }
            }
            .navigationTitle("Set duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
            }
        }
        .onAppear {
            if !GroupClassDuration.allCases.map(\.minutes).contains(selectedMinutes) {
                selectedMinutes = GroupClassDuration.allCases.min(by: { abs($0.minutes - defaultMinutes) < abs($1.minutes - defaultMinutes) })?.minutes ?? 30
            }
        }
    }
}

struct ClassTimerView: View {
    let routine: GroupFitnessRoutine
    /// Override duration for this session (defaults to routine.estimatedMinutes when nil).
    let sessionMinutes: Int?
    let onDismiss: () -> Void
    let onClassComplete: () -> Void
    @StateObject private var state: ClassTimerState
    
    init(routine: GroupFitnessRoutine, sessionMinutes: Int? = nil, onDismiss: @escaping () -> Void, onClassComplete: @escaping () -> Void) {
        self.routine = routine
        self.sessionMinutes = sessionMinutes
        self.onDismiss = onDismiss
        self.onClassComplete = onClassComplete
        let total = sessionMinutes ?? routine.estimatedMinutes
        _state = StateObject(wrappedValue: ClassTimerState(totalMinutes: total))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text(routine.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(state.formattedTime)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(state.remainingSeconds <= 60 ? .teal : .primary)
                
                HStack(spacing: 16) {
                    Button {
                        if state.isRunning {
                            state.stop()
                        } else {
                            state.start()
                        }
                    } label: {
                        Label(state.isRunning ? "Pause" : "Start", systemImage: state.isRunning ? "pause.fill" : "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    
                    Button("Reset") {
                        state.reset()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 24)
                
                if state.remainingSeconds <= 0 {
                    Text("Class time complete!")
                        .font(.headline)
                        .foregroundStyle(.teal)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Done (no log)") {
                        state.stop()
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    Button("Log class") {
                        state.stop()
                        onClassComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                }
                .padding()
            }
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        state.stop()
                        onDismiss()
                    }
                }
            }
        }
    }
}
