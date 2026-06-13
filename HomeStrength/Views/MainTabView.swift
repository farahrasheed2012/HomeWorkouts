//
//  MainTabView.swift
//  HomeStrength
//
//  Tabs on iOS; sidebar + detail on macOS.
//

import SwiftUI

private enum StandardTab: String, CaseIterable, Identifiable {
    case workouts, dashboard, library

    var id: String { rawValue }

    var title: String {
        switch self {
        case .workouts: return "Workouts"
        case .dashboard: return "Dashboard"
        case .library: return "Library"
        }
    }

    var systemImage: String {
        switch self {
        case .workouts: return "list.bullet"
        case .dashboard: return "chart.bar"
        case .library: return "book"
        }
    }
}

private enum GroupFitnessTab: String, CaseIterable, Identifiable {
    case routines, leadClass, history

    var id: String { rawValue }

    var title: String {
        switch self {
        case .routines: return "Routines"
        case .leadClass: return "Lead Class"
        case .history: return "History"
        }
    }

    var systemImage: String {
        switch self {
        case .routines: return "list.bullet.rectangle"
        case .leadClass: return "timer"
        case .history: return "calendar"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var showProfilePicker = false
    @State private var standardTab: StandardTab = .workouts
    @State private var groupTab: GroupFitnessTab = .routines

    private var isGroupFitness: Bool { userStore.currentUser?.profileType.isGroupFitness == true }

    var body: some View {
        Group {
            #if os(macOS)
            macLayout
            #else
            iosLayout
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                profileMenu
            }
        }
        .sheet(isPresented: $showProfilePicker) {
            UserSelectionView(onProfileSelected: { showProfilePicker = false })
                .environmentObject(userStore)
        }
    }

    #if os(iOS)
    private var iosLayout: some View {
        Group {
            if isGroupFitness {
                GroupFitnessTabView()
            } else {
                TabView {
                    ContentView()
                        .tabItem { Label(StandardTab.workouts.title, systemImage: StandardTab.workouts.systemImage) }
                    DashboardView()
                        .tabItem { Label(StandardTab.dashboard.title, systemImage: StandardTab.dashboard.systemImage) }
                    ExerciseLibraryView()
                        .tabItem { Label(StandardTab.library.title, systemImage: StandardTab.library.systemImage) }
                }
            }
        }
    }
    #endif

    #if os(macOS)
    private var macLayout: some View {
        NavigationSplitView {
            Group {
                if isGroupFitness {
                    List(selection: $groupTab) {
                        Section("Group Fitness") {
                            ForEach(GroupFitnessTab.allCases) { tab in
                                Label(tab.title, systemImage: tab.systemImage)
                                    .tag(tab)
                            }
                        }
                    }
                } else {
                    List(selection: $standardTab) {
                        Section("HomeStrength") {
                            ForEach(StandardTab.allCases) { tab in
                                Label(tab.title, systemImage: tab.systemImage)
                                    .tag(tab)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle(isGroupFitness ? "Group Fitness" : "HomeStrength")
            .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 280)
        } detail: {
            Group {
                if isGroupFitness {
                    groupFitnessRoot(for: groupTab)
                } else {
                    standardRoot(for: standardTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PlatformColor.groupedBackground)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 700)
        .onChange(of: isGroupFitness) { _, _ in
            if isGroupFitness {
                groupTab = .routines
            } else {
                standardTab = .workouts
            }
        }
    }

    @ViewBuilder
    private func standardRoot(for tab: StandardTab) -> some View {
        switch tab {
        case .workouts: ContentView()
        case .dashboard: DashboardView()
        case .library: ExerciseLibraryView()
        }
    }

    @ViewBuilder
    private func groupFitnessRoot(for tab: GroupFitnessTab) -> some View {
        switch tab {
        case .routines: GroupFitnessRoutinesView()
        case .leadClass: GroupFitnessTimerPlaceholderView()
        case .history: GroupFitnessHistoryView()
        }
    }
    #endif

    private var profileMenu: some View {
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

#Preview {
    MainTabView()
        .environmentObject(UserStore())
        .environmentObject(WorkoutStore())
        .environmentObject(ProgressStore())
}
