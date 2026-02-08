//
//  GroupFitnessHistoryView.swift
//  HomeStrength
//
//  History of classes led: date, participants, class type, notes.
//

import SwiftUI

struct GroupFitnessHistoryView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var groupFitnessStore: GroupFitnessStore
    @State private var showProfilePicker = false
    
    private var logs: [GroupClassLog] {
        guard let uid = userStore.currentUser?.id else { return [] }
        return groupFitnessStore.logs(forUserId: uid)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No classes logged")
                            .font(.title2)
                        Text("After leading a class, tap \"Log class\" from the routine or timer to track it here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(logs) { log in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(log.routineName)
                                    .font(.headline)
                                HStack {
                                    Text(log.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("·")
                                    Text(log.classFormat.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if let count = log.participantCount {
                                    Text("\(count) participants")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                if let n = log.notes, !n.isEmpty {
                                    Text(n)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Classes led")
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
            }
            .sheet(isPresented: $showProfilePicker) {
                UserSelectionView(onProfileSelected: { showProfilePicker = false })
                    .environmentObject(userStore)
            }
        }
    }
}
