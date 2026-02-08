//
//  GroupFitnessTimerPlaceholderView.swift
//  HomeStrength
//
//  Lead Class tab: quick link to start a timer; open a routine to begin.
//

import SwiftUI

struct GroupFitnessTimerPlaceholderView: View {
    @EnvironmentObject var groupFitnessStore: GroupFitnessStore
    @EnvironmentObject var userStore: UserStore
    @State private var showRoutinePicker = false
    @State private var routineForTimer: GroupFitnessRoutine?
    @State private var routineToLog: GroupFitnessRoutine?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundStyle(.teal.opacity(0.8))
                Text("Lead a class")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Choose a routine to start the class timer, or open the Routines tab and tap a routine → \"Start class timer\".")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button {
                    showRoutinePicker = true
                } label: {
                    Label("Pick routine & start timer", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Lead Class")
            .sheet(isPresented: $showRoutinePicker) {
                GroupFitnessRoutinePickerView(onPick: { routine in
                    showRoutinePicker = false
                    routineForTimer = routine
                })
                .environmentObject(groupFitnessStore)
            }
            .fullScreenCover(item: $routineForTimer) { routine in
                ClassTimerView(
                    routine: routine,
                    onDismiss: { routineForTimer = nil },
                    onClassComplete: {
                        routineToLog = routine
                        routineForTimer = nil
                    }
                )
            }
            .sheet(item: $routineToLog) { routine in
                if let uid = userStore.currentUser?.id {
                    LogClassSheet(
                        routine: routine,
                        userId: uid,
                        onLog: { groupFitnessStore.logClass($0); routineToLog = nil }
                    )
                }
            }
        }
    }
}

/// Simple list to pick a routine and start its timer (used from Lead Class tab).
struct GroupFitnessRoutinePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var groupFitnessStore: GroupFitnessStore
    let onPick: (GroupFitnessRoutine) -> Void
    
    var body: some View {
        NavigationStack {
            List(groupFitnessStore.allRoutines) { routine in
                Button {
                    onPick(routine)
                    dismiss()
                } label: {
                    RoutineRow(routine: routine)
                }
            }
            .navigationTitle("Choose routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
