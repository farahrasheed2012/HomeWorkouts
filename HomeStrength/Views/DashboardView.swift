//
//  DashboardView.swift
//  HomeStrength
//
//  Metrics: workouts completed, frequency, streak, progress charts.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var progressStore: ProgressStore
    @State private var showProfilePicker = false
    
    private var userId: UUID? { userStore.currentUser?.id }
    private var profileType: UserProfileType? { userStore.currentUser?.profileType }
    private var isMom: Bool { profileType == .mom }
    private var isYoungKid: Bool { profileType?.isYoungKid == true }
    
    var body: some View {
        NavigationStack {
            Group {
                if let uid = userId {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            statsGrid(userId: uid)
                            streakSection(userId: uid)
                            workoutsPerWeekChart(userId: uid)
                            if isMom {
                                strengthProgressSection(userId: uid)
                            } else if profileType == .daughterMiddleSchool {
                                verticalJumpSection(userId: uid)
                            } else if isYoungKid {
                                kidBadgesSection(userId: uid)
                            }
                            recentHistorySection(userId: uid)
                        }
                        .padding()
                    }
                } else {
                    Text("Select a user to see dashboard.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Dashboard")
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
    
    private func statsGrid(userId: UUID) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Total workouts", value: "\(progressStore.totalWorkoutsCount(userId: userId))")
            StatCard(title: "This week", value: "\(progressStore.workoutsThisWeek(userId: userId))")
            StatCard(title: "This month", value: "\(progressStore.workoutsThisMonth(userId: userId))")
            StatCard(title: "Day streak", value: "\(progressStore.currentStreakDays(userId: userId))")
        }
    }
    
    private func streakSection(userId: UUID) -> some View {
        let streak = progressStore.currentStreakDays(userId: userId)
        return Group {
            if streak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("You're on a \(streak)-day streak! Keep it up.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func workoutsPerWeekChart(userId: UUID) -> some View {
        let calendar = Calendar.current
        let completed = progressStore.completed(forUserId: userId)
        var weekCounts: [(weekStart: Date, count: Int)] = []
        for i in 0..<6 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: Date()) else { continue }
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            let count = completed.filter { $0.completedAt >= weekStart && $0.completedAt < weekEnd }.count
            weekCounts.append((weekStart, count))
        }
        weekCounts.reverse()
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Workouts per week")
                .font(.headline)
            if weekCounts.allSatisfy({ $0.count == 0 }) {
                Text("Complete workouts to see your chart.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(weekCounts, id: \.weekStart) { item in
                    BarMark(
                        x: .value("Week", item.weekStart, unit: .weekOfYear),
                        y: .value("Workouts", item.count)
                    )
                    .foregroundStyle(Color.orange.gradient)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                        AxisValueLabel(format: Date.FormatStyle().month(.abbreviated).day())
                    }
                }
                .frame(height: 160)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func strengthProgressSection(userId: UUID) -> some View {
        let keyExercises = ["Goblet Squat", "Dumbbell Row", "Chest Press"]
        let weightHistoryGoblet = progressStore.weightHistory(userId: userId, exerciseName: "Goblet Squat")
        return VStack(alignment: .leading, spacing: 12) {
            Text("Strength progress (weight used)")
                .font(.headline)
            ForEach(keyExercises, id: \.self) { name in
                StrengthExerciseRow(
                    name: name,
                    history: progressStore.weightHistory(userId: userId, exerciseName: name)
                )
            }
            if !weightHistoryGoblet.isEmpty {
                let chartData = Array(weightHistoryGoblet.prefix(12))
                VStack(alignment: .leading, spacing: 6) {
                    Text("Goblet Squat weight over time")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Chart(Array(chartData.enumerated()), id: \.offset) { item in
                        LineMark(
                            x: .value("Date", item.element.0),
                            y: .value("Weight (lb)", item.element.1)
                        )
                        .foregroundStyle(Color.orange.gradient)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: Date.FormatStyle().month(.abbreviated).day())
                        }
                    }
                    .frame(height: 120)
                }
            }
            if keyExercises.allSatisfy({ progressStore.weightHistory(userId: userId, exerciseName: $0).isEmpty }) {
                Text("Log weight when you complete workouts to see progress here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func verticalJumpSection(userId: UUID) -> some View {
        let history = progressStore.verticalJumpHistory(userId: userId)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Vertical jump (inches)")
                .font(.headline)
            if let latest = history.first {
                HStack {
                    Text("Latest")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f\"", latest.1))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            } else {
                Text("Log vertical jump when completing workouts to track progress.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func kidBadgesSection(userId: UUID) -> some View {
        let total = progressStore.totalWorkoutsCount(userId: userId)
        let streak = progressStore.currentStreakDays(userId: userId)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Your achievements")
                .font(.headline)
            HStack(spacing: 12) {
                if total >= 1 {
                    BadgePill(icon: "star.fill", label: "First activity!", color: .yellow)
                }
                if total >= 5 {
                    BadgePill(icon: "flame.fill", label: "5 done!", color: .orange)
                }
                if total >= 10 {
                    BadgePill(icon: "trophy.fill", label: "10 activities!", color: .purple)
                }
                if streak >= 3 {
                    BadgePill(icon: "flame.fill", label: "\(streak)-day streak!", color: .red)
                }
            }
            .padding(.vertical, 4)
            if total == 0 {
                Text("Complete activities to earn badges!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func recentHistorySection(userId: UUID) -> some View {
        let recent = progressStore.completed(forUserId: userId).prefix(10)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Recent workouts")
                .font(.headline)
            if recent.isEmpty {
                Text("No workouts logged yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(recent)) { log in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.workoutName)
                                .font(.subheadline)
                            Text(log.completedAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct StrengthExerciseRow: View {
    let name: String
    let history: [(Date, Double)]
    
    var body: some View {
        if let latest = history.first {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(latest.1)) lb")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 4)
        }
    }
}

struct BadgePill: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(label)
                .font(.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserStore())
        .environmentObject(ProgressStore())
}
