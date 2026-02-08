//
//  ExerciseLibraryView.swift
//  HomeStrength
//
//  Browse exercises with descriptions, form tips, and placeholder images.
//

import SwiftUI

struct ExerciseLibraryView: View {
    @EnvironmentObject var userStore: UserStore
    
    private var details: [ExerciseDetail] { ExerciseDetailStore.allDetails }
    
    var body: some View {
        NavigationStack {
            List(details) { detail in
                NavigationLink(value: detail) {
                    HStack(spacing: 12) {
                        Image(systemName: detail.equipment.icon)
                            .font(.title3)
                            .foregroundStyle(.orange)
                            .frame(width: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(detail.exerciseName)
                                .font(.headline)
                            HStack(spacing: 6) {
                                Text(detail.equipment.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(detail.difficultyLevel.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercise Library")
            .navigationDestination(for: ExerciseDetail.self) { detail in
                ExerciseDetailView(detail: detail)
            }
        }
    }
}

struct ExerciseDetailView: View {
    let detail: ExerciseDetail
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Placeholder for image/GIF
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.15))
                        .frame(height: 180)
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange.opacity(0.6))
                }
                .overlay(Text("Demo image / GIF").font(.caption).foregroundStyle(.secondary).padding(8), alignment: .topLeading)
                
                Text(detail.difficultyLevel.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
                
                Text(detail.summary)
                    .font(.body)
                
                if !detail.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to do it")
                            .font(.headline)
                        ForEach(Array(detail.steps.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(i + 1).")
                                    .fontWeight(.medium)
                                Text(step)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                if !detail.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips (avoid common mistakes)")
                            .font(.headline)
                        ForEach(detail.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.orange)
                                Text(tip)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                if !detail.targets.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What it targets")
                            .font(.headline)
                        Text(detail.targets.joined(separator: ", "))
                            .font(.subheadline)
                    }
                }
                
                if !detail.muscles.isEmpty && !detail.isKidFriendly {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Muscles targeted")
                            .font(.headline)
                        Text(detail.muscles.joined(separator: ", "))
                            .font(.subheadline)
                    }
                }
                
                if let safety = detail.safetyNote, !safety.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Safety")
                            .font(.headline)
                        Text(safety)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if detail.easyVariation != nil || detail.mediumVariation != nil || detail.difficultVariation != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Variations by level")
                            .font(.headline)
                        if let e = detail.easyVariation, !e.isEmpty {
                            Text("Easy")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(e)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let m = detail.mediumVariation, !m.isEmpty {
                            Text("Medium")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(m)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let d = detail.difficultVariation, !d.isEmpty {
                            Text("Difficult")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(d)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(detail.exerciseName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Static exercise detail data (placeholder content; add real images later).
enum ExerciseDetailStore {
    static let allDetails: [ExerciseDetail] = [
        ExerciseDetail(
            exerciseName: "Goblet Squat",
            equipment: .dumbbells,
            summary: "A beginner-friendly squat holding one dumbbell at your chest. Builds leg and core strength.",
            steps: [
                "Hold one dumbbell vertically at your chest, elbows pointing down.",
                "Stand with feet shoulder-width apart, toes slightly out.",
                "Push your hips back and bend your knees to lower into a squat. Keep your chest up.",
                "Go as low as you can while keeping your back straight, then drive through your heels to stand.",
            ],
            tips: [
                "Don't let your knees cave inward—push them out over your toes.",
                "Keep the weight at your chest so you don't lean forward.",
            ],
            muscles: ["Quads", "Glutes", "Core"],
            targets: ["Strength", "Balance"],
            safetyNote: "Avoid rounding your lower back. If you feel knee pain, reduce depth or use no weight.",
            difficultyLevel: .easy,
            easyVariation: "Use a lighter dumbbell or no weight. Sit to a chair and stand back up if needed.",
            mediumVariation: "Bodyweight or light dumbbell, full range.",
            difficultVariation: "Heavier dumbbell, pause at bottom, or add a pulse."
        ),
        ExerciseDetail(
            exerciseName: "Jump Squats",
            equipment: .bodyweight,
            summary: "Explosive squat with a jump. Builds power and leg strength for volleyball jumping.",
            steps: [
                "Start in a squat position, feet shoulder-width apart.",
                "Jump up as high as you can, extending your body.",
                "Land softly on the balls of your feet, then immediately go into the next squat.",
            ],
            tips: [
                "Land with soft knees to protect your joints.",
                "Keep your chest up and core tight.",
            ],
            muscles: ["Quads", "Glutes", "Calves"],
            targets: ["Strength", "Power", "Coordination"],
            safetyNote: "Land softly to protect knees and ankles. Use a soft surface if needed.",
            difficultyLevel: .medium,
            easyVariation: "Do regular squats first, or small hops instead of full jumps.",
            mediumVariation: "Jump squats with full recovery between reps.",
            difficultVariation: "Minimal rest, add tuck or height focus."
        ),
        ExerciseDetail(
            exerciseName: "Band Pull-Apart",
            equipment: .resistanceBands,
            summary: "Pulling the band apart at chest height. Great for shoulder health and upper back.",
            steps: [
                "Hold the band in both hands in front of your chest, arms slightly bent.",
                "Pull the band apart by squeezing your shoulder blades together.",
                "Pause when the band touches your chest, then slowly return.",
            ],
            tips: [
                "Don't shrug your shoulders—keep them down and back.",
                "Control the return; don't let the band snap back.",
            ],
            muscles: ["Rear deltoids", "Rhomboids", "Upper back"],
            targets: ["Strength", "Flexibility"],
            safetyNote: "If the band slips, use one with a secure grip or lower resistance.",
            difficultyLevel: .easy,
            easyVariation: "Use a lighter band or shorten the band for less resistance.",
            mediumVariation: "Standard band, full range.",
            difficultVariation: "Heavy band or add pause at peak contraction."
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Row",
            equipment: .dumbbells,
            summary: "Single-arm row supporting on a bench or chair. Strengthens your back and arms.",
            steps: [
                "Place one knee and same-side hand on a bench or chair. Hold a dumbbell in the other hand.",
                "Keep your back flat and core tight. Pull the dumbbell to your hip.",
                "Squeeze your shoulder blade at the top, then lower with control.",
            ],
            tips: [
                "Don't twist your torso—keep your hips square.",
                "Lead with your elbow, not your hand.",
            ],
            muscles: ["Lats", "Rhomboids", "Biceps"],
            targets: ["Strength"],
            safetyNote: "Keep your back flat to avoid strain. Don't swing the weight.",
            difficultyLevel: .medium,
            easyVariation: "Use a light weight. Support your hand on your knee if no bench.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Renegade row or single-arm row with pause."
        ),
        ExerciseDetail(
            exerciseName: "Plank",
            equipment: .bodyweight,
            summary: "Hold a push-up position with arms straight or on forearms. Builds core stability.",
            steps: [
                "Start on hands and knees. Step feet back so your body is in a straight line.",
                "Support on your forearms (or hands) and toes. Keep your hips level.",
                "Hold without letting your hips sag or pike up.",
            ],
            tips: [
                "Squeeze your glutes and core to keep your body straight.",
                "Breathe normally; don't hold your breath.",
            ],
            muscles: ["Core", "Shoulders", "Glutes"],
            targets: ["Strength", "Balance"],
            safetyNote: "Stop if you feel wrist or lower-back pain. Drop to knees to reduce load.",
            difficultyLevel: .medium,
            easyVariation: "Hold from your knees instead of toes, or hold for 10–15 seconds at a time.",
            mediumVariation: "Standard forearm or high plank 30–45 sec.",
            difficultVariation: "Extended hold, shoulder taps, or alternating leg lift."
        ),
        // Kid-friendly activities with fun descriptions
        ExerciseDetail(
            exerciseName: "Frog Jumps",
            equipment: .bodyweight,
            summary: "Pretend you're a frog! Squat down and jump forward. Land softly like a frog on a lily pad.",
            steps: [
                "Squat down low like a frog.",
                "Jump forward (or up) and land with soft feet.",
                "Do it again! Ribbit!",
            ],
            tips: ["Land quietly.", "Keep it fun—no need to jump super far."],
            muscles: ["Legs", "Core"],
            targets: ["Coordination", "Balance", "Strength"],
            safetyNote: "Use a clear space. Land on both feet.",
            difficultyLevel: .easy,
            easyVariation: "Small hops in place.",
            mediumVariation: "Frog jumps forward.",
            difficultVariation: "Frog jumps with a clap at the top.",
            isKidFriendly: true
        ),
        ExerciseDetail(
            exerciseName: "Bear Crawl",
            equipment: .bodyweight,
            summary: "Walk on your hands and feet like a bear! Keep your knees off the floor and move around the room.",
            steps: [
                "Get on your hands and feet, knees off the floor.",
                "Move one hand and the opposite foot, then the other hand and foot.",
                "Crawl around like a bear. Growl if you want!",
            ],
            tips: ["Keep your bottom down.", "Move slowly at first."],
            muscles: ["Arms", "Core", "Legs"],
            targets: ["Coordination", "Strength"],
            safetyNote: "Watch for furniture. Take breaks if your arms get tired.",
            difficultyLevel: .easy,
            easyVariation: "Crawl on knees (bear-style).",
            mediumVariation: "Full bear crawl.",
            difficultVariation: "Bear crawl backward or with a pause.",
            isKidFriendly: true
        ),
        ExerciseDetail(
            exerciseName: "Bunny Hops",
            equipment: .bodyweight,
            summary: "Hop like a bunny! Small, quick hops in place or around the room. So much fun!",
            steps: [
                "Stand with feet together.",
                "Hop in place or hop forward like a bunny.",
                "Keep hopping! You're doing great!",
            ],
            tips: ["Land softly.", "You can hop in a circle or in a line."],
            muscles: ["Legs"],
            targets: ["Coordination", "Balance"],
            safetyNote: "Make sure the floor isn't slippery.",
            difficultyLevel: .easy,
            easyVariation: "Hop in place only.",
            mediumVariation: "Hop forward or in a circle.",
            difficultVariation: "Fast bunny hops or hop on one foot.",
            isKidFriendly: true
        ),
    ]
}

extension ExerciseDetail: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ExerciseDetail, rhs: ExerciseDetail) -> Bool { lhs.id == rhs.id }
}

#Preview {
    ExerciseLibraryView()
        .environmentObject(UserStore())
}
