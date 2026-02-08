//
//  MainTabView.swift
//  HomeStrength
//
//  Tabs: Workouts, Dashboard, Library — or for Group Fitness: Routines, Lead Class, History.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var showProfilePicker = false
    
    private var isGroupFitness: Bool { userStore.currentUser?.profileType.isGroupFitness == true }
    
    var body: some View {
        Group {
            if isGroupFitness {
                GroupFitnessTabView()
            } else {
                standardTabs
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
    
    private var standardTabs: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Workouts", systemImage: "list.bullet")
                }
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
            ExerciseLibraryView()
                .tabItem {
                    Label("Library", systemImage: "book")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserStore())
        .environmentObject(WorkoutStore())
        .environmentObject(ProgressStore())
}
