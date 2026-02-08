//
//  LogClassSheet.swift
//  HomeStrength
//
//  Log a class you led: date, participants, class type, notes (how group responded).
//

import SwiftUI

struct LogClassSheet: View {
    @Environment(\.dismiss) private var dismiss
    let routine: GroupFitnessRoutine
    let userId: UUID
    let onLog: (GroupClassLog) -> Void
    
    @State private var participantCountText = ""
    @State private var notes = ""
    @State private var durationMinutesText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Class") {
                    LabeledContent("Routine", value: routine.name)
                    LabeledContent("Format", value: routine.format.rawValue)
                }
                Section("Session") {
                    TextField("Number of participants (optional)", text: $participantCountText)
                        .keyboardType(.numberPad)
                    TextField("Duration used in min (optional)", text: $durationMinutesText)
                        .keyboardType(.numberPad)
                }
                Section("Notes") {
                    TextField("How did the group respond? Modifications used? Feedback?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log class led")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                }
            }
        }
    }
    
    private func saveAndDismiss() {
        let count = Int(participantCountText.trimmingCharacters(in: .whitespaces))
        let duration = Int(durationMinutesText.trimmingCharacters(in: .whitespaces))
        let log = GroupClassLog(
            userId: userId,
            routineId: routine.id,
            routineName: routine.name,
            classFormat: routine.format,
            date: Date(),
            participantCount: count,
            notes: notes.isEmpty ? nil : notes,
            durationMinutes: duration
        )
        onLog(log)
        dismiss()
    }
}
