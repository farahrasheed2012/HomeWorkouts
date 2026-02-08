//
//  GroupFitnessRoutinesView.swift
//  HomeStrength
//
//  Library of full routines by format (full-body, lower body, core, etc.).
//

import SwiftUI

struct GroupFitnessRoutinesView: View {
    @EnvironmentObject var groupFitnessStore: GroupFitnessStore
    @State private var selectedFormat: GroupClassFormat?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Class format") {
                    ForEach(GroupClassFormat.allCases, id: \.self) { format in
                        Button {
                            selectedFormat = selectedFormat == format ? nil : format
                        } label: {
                            HStack {
                                Image(systemName: format.icon)
                                    .foregroundStyle(.teal)
                                    .frame(width: 28)
                                Text(format.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if groupFitnessStore.routines(for: format).count > 0 {
                                    Text("\(groupFitnessStore.routines(for: format).count)")
                                        .foregroundStyle(.secondary)
                                }
                                if selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.teal)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section("Routines") {
                    let routines = groupFitnessStore.routines(for: selectedFormat)
                    ForEach(routines) { routine in
                        NavigationLink(value: routine) {
                            RoutineRow(routine: routine)
                        }
                    }
                }
            }
            .navigationTitle("Class Routines")
            .navigationDestination(for: GroupFitnessRoutine.self) { routine in
                GroupRoutineDetailView(routine: routine)
            }
        }
    }
}

struct RoutineRow: View {
    let routine: GroupFitnessRoutine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: routine.format.icon)
                    .foregroundStyle(.teal)
                    .frame(width: 28)
                Text(routine.name)
                    .font(.headline)
            }
            Text(routine.format.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(routine.estimatedMinutes) min · Bodyweight only")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
