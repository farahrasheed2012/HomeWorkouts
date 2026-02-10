//
//  RestTimerView.swift
//  HomeStrength
//
//  Countdown timer for rest between sets. Plays audio and haptic when time is ending so you don't need to watch the screen.
//

import SwiftUI
import AudioToolbox

@MainActor
final class RestTimerState: ObservableObject {
    @Published var remaining: Int
    @Published var isRunning = false
    private var timer: Timer?
    private let initialSeconds: Int
    
    init(initialSeconds: Int) {
        self.initialSeconds = initialSeconds
        self.remaining = initialSeconds
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
        if remaining > 0 {
            remaining -= 1
            if remaining == 10 {
                AudioServicesPlaySystemSound(1057)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            if remaining == 0 {
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
        remaining = initialSeconds
    }
}

struct RestTimerView: View {
    let initialSeconds: Int
    let onDismiss: () -> Void
    @StateObject private var state: RestTimerState
    
    init(initialSeconds: Int = 60, onDismiss: @escaping () -> Void) {
        self.initialSeconds = initialSeconds
        self.onDismiss = onDismiss
        _state = StateObject(wrappedValue: RestTimerState(initialSeconds: initialSeconds))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Rest")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(state.remaining)s")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(state.remaining <= 10 ? HSTheme.accent : .primary)
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
                .tint(HSTheme.accent)
                
                Button("Reset") {
                    state.reset()
                }
                .buttonStyle(.bordered)
                
                Button("Done") {
                    state.stop()
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(32)
        .onChange(of: state.remaining) { newValue in
            if newValue == 0 {
                // Auto-dismiss shortly after rest ends so the workout can advance without tapping Done
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    state.stop()
                    onDismiss()
                }
            }
        }
        .onDisappear {
            state.stop()
        }
    }
}
