//
//  MainTabView.swift
//  HomeStrength
//
//  Tabs: Workouts, Dashboard, Library — or for Group Fitness: Routines, Lead Class, History.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userStore: UserStore
    
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
                        userStore.signOut()
                    } label: {
                        Label("Switch user", systemImage: "person.2")
                    }
                } label: {
                    Label("User", systemImage: "person.circle")
                }
            }
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
