//
//  GroupFitnessTabView.swift
//  HomeStrength
//
//  Tabs for Group Fitness profile: Routines, Lead Class (timer), History.
//

import SwiftUI

struct GroupFitnessTabView: View {
    var body: some View {
        TabView {
            GroupFitnessRoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "list.bullet.rectangle")
                }
            GroupFitnessTimerPlaceholderView()
                .tabItem {
                    Label("Lead Class", systemImage: "timer")
                }
            GroupFitnessHistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
        }
    }
}
