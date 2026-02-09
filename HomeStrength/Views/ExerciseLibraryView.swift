//
//  ExerciseLibraryView.swift
//  HomeStrength
//
//  Browse exercises with descriptions, form tips, and placeholder images.
//

import SwiftUI

struct ExerciseLibraryView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var showProfilePicker = false
    
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
                // Exercise demo image (from Assets when available)
                Group {
                    if let name = detail.imagePlaceholderName, !name.isEmpty {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.15))
                                .frame(height: 180)
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 60))
                                .foregroundStyle(.orange.opacity(0.6))
                        }
                        .overlay(Text("Demo image").font(.caption).foregroundStyle(.secondary).padding(8), alignment: .topLeading)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
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
            difficultVariation: "Heavier dumbbell, pause at bottom, or add a pulse.",
            imagePlaceholderName: nil
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
            difficultVariation: "Minimal rest, add tuck or height focus.",
            imagePlaceholderName: "JumpSquats"
        ),
        ExerciseDetail(
            exerciseName: "High Knees",
            equipment: .bodyweight,
            summary: "Run in place driving knees up quickly. Builds cardio, leg speed, and coordination for volleyball conditioning.",
            steps: [
                "Stand with feet hip-width apart. Lift one knee up toward your chest while driving the opposite arm forward.",
                "Quickly switch: lower that leg and drive the other knee up with the opposite arm.",
                "Keep a quick, steady rhythm. Stay on the balls of your feet.",
                "Continue for the set time (e.g. 20–30 seconds).",
            ],
            tips: [
                "Keep your core tight and stand tall; don’t lean back.",
                "Drive your arms to help speed and balance.",
            ],
            muscles: ["Hip flexors", "Quads", "Calves", "Core"],
            targets: ["Cardio", "Speed", "Coordination"],
            safetyNote: "Land softly. Use a non-slip surface. Reduce speed if you feel knee or hip discomfort.",
            difficultyLevel: .easy,
            easyVariation: "March in place with high knees at a slower pace.",
            mediumVariation: "High knees at a steady pace for 20–30 seconds.",
            difficultVariation: "Faster pace or longer duration; add a slight forward lean for more intensity.",
            imagePlaceholderName: nil
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
            difficultVariation: "Heavy band or add pause at peak contraction.",
            imagePlaceholderName: "BandPullApart"
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
            difficultVariation: "Renegade row or single-arm row with pause.",
            imagePlaceholderName: "DumbbellRow"
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
            difficultVariation: "Extended hold, shoulder taps, or alternating leg lift.",
            imagePlaceholderName: "Plank"
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
            imagePlaceholderName: "FrogJumps",
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
            imagePlaceholderName: "BearCrawl",
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
            imagePlaceholderName: "BunnyHops",
            isKidFriendly: true
        ),
        ExerciseDetail(
            exerciseName: "One-foot balance",
            equipment: .bodyweight,
            summary: "Stand on one foot like a flamingo! Can you count to 10? Then switch feet. Great for balance!",
            steps: [
                "Stand on one foot. Lift the other foot off the floor a little bit.",
                "Try to stay steady. Can you count to 10? You can hold your arms out to help balance.",
                "Put your foot down, then try the other foot!",
                "Do it again and see if you can stand a little longer.",
            ],
            tips: ["Look at something in front of you—it helps you stay steady.", "It's okay to wobble! Just try again."],
            muscles: ["Legs", "Core"],
            targets: ["Balance", "Coordination"],
            safetyNote: "Stand near a wall or chair if you need to touch it. Use a non-slip floor.",
            difficultyLevel: .easy,
            easyVariation: "Hold a wall or chair with one hand while you balance.",
            mediumVariation: "Balance on one foot for 10 seconds each side.",
            difficultVariation: "Close your eyes for a few seconds (with a grown-up nearby), or balance longer.",
            imagePlaceholderName: nil,
            isKidFriendly: true
        ),
        ExerciseDetail(
            exerciseName: "Heel-to-toe walk",
            equipment: .bodyweight,
            summary: "Walk in a straight line like you're on a balance beam! Put one foot right in front of the other.",
            steps: [
                "Stand with your feet together. Pick a line on the floor (or imagine one).",
                "Put one foot in front of the other so the heel of your front foot touches the toe of your back foot.",
                "Take a step with the other foot the same way. Heel, then toe!",
                "Walk slowly along your line. How far can you go without stepping off?",
            ],
            tips: ["Go slow—it's not a race!", "Look ahead, not down at your feet."],
            muscles: ["Legs", "Core"],
            targets: ["Balance", "Coordination"],
            safetyNote: "Use a clear path. Have a wall or furniture nearby if you need to steady yourself.",
            difficultyLevel: .easy,
            easyVariation: "Take small steps or hold a grown-up's hand.",
            mediumVariation: "Heel-to-toe walk in a straight line for 20 seconds.",
            difficultVariation: "Walk backward heel-to-toe, or walk on a real balance beam with help.",
            imagePlaceholderName: nil,
            isKidFriendly: true
        ),
        ExerciseDetail(
            exerciseName: "Star jumps",
            equipment: .bodyweight,
            summary: "Jump and spread your arms and legs out like a star! Land softly. So much fun!",
            steps: [
                "Stand with your feet together and your arms at your sides.",
                "Jump up! While you're in the air, spread your arms and legs out like a star.",
                "Land softly with your feet together and arms back down.",
                "Do it again! How many stars can you make?",
            ],
            tips: ["Land with soft, bouncy knees—like you're landing on a pillow.", "Reach your arms and legs out wide like a star!"],
            muscles: ["Legs", "Arms", "Core"],
            targets: ["Coordination", "Balance", "Strength"],
            safetyNote: "Make sure you have space. Land on both feet. No slippery floors.",
            difficultyLevel: .easy,
            easyVariation: "Small star jumps or step out to the sides instead of jumping.",
            mediumVariation: "Star jumps at a steady pace. Land softly each time.",
            difficultVariation: "Faster star jumps or do a little squat before each jump.",
            imagePlaceholderName: nil,
            isKidFriendly: true
        ),
        // Additional library exercises (full steps and variations)
        ExerciseDetail(
            exerciseName: "Dumbbell Floor Press",
            equipment: .dumbbells,
            summary: "Chest press lying on the floor. Builds chest and triceps with a safe range of motion.",
            steps: [
                "Lie on your back on the floor, knees bent, feet flat. Hold a dumbbell in each hand.",
                "Start with elbows bent about 45° from your body, weights at chest level.",
                "Press the dumbbells up until your arms are straight. Don't lock elbows.",
                "Lower with control back to the start position.",
            ],
            tips: [
                "Keep your lower back on the floor to protect your spine.",
                "Squeeze your chest at the top of the press.",
            ],
            muscles: ["Chest", "Triceps", "Shoulders"],
            targets: ["Strength"],
            safetyNote: "If you have shoulder issues, reduce range or use lighter weight.",
            difficultyLevel: .easy,
            easyVariation: "Use light weights or one arm at a time.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight, or add a pause at the bottom.",
            imagePlaceholderName: "DumbbellFloorPress"
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Shoulder Press",
            equipment: .dumbbells,
            summary: "Press dumbbells overhead from shoulders. Strengthens shoulders and arms.",
            steps: [
                "Sit or stand with feet shoulder-width apart. Hold a dumbbell in each hand at shoulder height, palms forward.",
                "Press both dumbbells straight up until your arms are extended (don't lock elbows).",
                "Lower with control back to shoulder height.",
            ],
            tips: [
                "Keep your core tight to avoid arching your lower back.",
                "Don't let your elbows flare too far out—keep them slightly in front of your body.",
            ],
            muscles: ["Shoulders", "Triceps", "Upper chest"],
            targets: ["Strength"],
            safetyNote: "If standing, keep a slight bend in the knees. Avoid pressing behind the head.",
            difficultyLevel: .medium,
            easyVariation: "Seated with back support; light weights.",
            mediumVariation: "Standing or seated, moderate weight.",
            difficultVariation: "Alternating arms or single-arm press.",
            imagePlaceholderName: "DumbbellShoulderPress"
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Romanian Deadlift",
            equipment: .dumbbells,
            summary: "Hinge at the hips while holding dumbbells. Great for hamstrings and lower back.",
            steps: [
                "Stand with feet hip-width apart, soft bend in knees. Hold dumbbells in front of your thighs.",
                "Push your hips back and lower the dumbbells along your legs. Keep your back flat.",
                "Lower until you feel a stretch in your hamstrings (usually to mid-shin or just below knee).",
                "Drive through your heels and squeeze your glutes to stand back up.",
            ],
            tips: [
                "Think of closing a car door with your hips—push back, don't squat down.",
                "Keep the dumbbells close to your body throughout.",
            ],
            muscles: ["Hamstrings", "Glutes", "Lower back"],
            targets: ["Strength", "Flexibility"],
            safetyNote: "Never round your lower back. Stop if you feel back strain.",
            difficultyLevel: .difficult,
            easyVariation: "Bodyweight or very light dumbbells; shorter range.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Single-leg RDL or heavier weight with pause.",
            imagePlaceholderName: "DumbbellRomanianDeadlift"
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Bicep Curl",
            equipment: .dumbbells,
            summary: "Curl dumbbells to work your biceps. Simple and effective arm exercise.",
            steps: [
                "Stand or sit with a dumbbell in each hand, arms at your sides, palms forward.",
                "Keeping your upper arms still, bend your elbows and curl the weights toward your shoulders.",
                "Squeeze your biceps at the top, then lower with control.",
            ],
            tips: [
                "Don't swing the weights—use a controlled motion.",
                "Keep your elbows close to your body.",
            ],
            muscles: ["Biceps", "Forearms"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control; avoid straining your wrists.",
            difficultyLevel: .easy,
            easyVariation: "Lighter weight or alternate arms.",
            mediumVariation: "Both arms together, moderate weight.",
            difficultVariation: "Hammer curls or concentration curls.",
            imagePlaceholderName: "DumbbellBicepCurl"
        ),
        ExerciseDetail(
            exerciseName: "Tricep Extension",
            equipment: .dumbbells,
            summary: "Extend your arms to target the triceps. Can be done with one or two dumbbells overhead or with a band.",
            steps: [
                "Stand or sit. Hold one dumbbell with both hands (or one in each hand) behind your head, elbows pointing up.",
                "Keeping your upper arms still, straighten your elbows to lift the weight.",
                "Lower with control back to the start position.",
            ],
            tips: [
                "Keep your elbows pointing forward and close to your head.",
                "Don't let your lower back arch—engage your core.",
            ],
            muscles: ["Triceps"],
            targets: ["Strength"],
            safetyNote: "Start with a light weight to avoid elbow strain.",
            difficultyLevel: .medium,
            easyVariation: "Use a resistance band or very light dumbbell.",
            mediumVariation: "Single dumbbell or two light dumbbells.",
            difficultVariation: "Lying tricep extension or heavier weight.",
            imagePlaceholderName: "TricepExtension"
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Lunge",
            equipment: .dumbbells,
            summary: "Step forward or backward into a lunge while holding dumbbells. Builds leg strength and balance.",
            steps: [
                "Stand with feet hip-width apart, a dumbbell in each hand at your sides.",
                "Step one foot forward and lower your back knee toward the floor. Both knees should bend to about 90°.",
                "Keep your front knee over your ankle; don't let it cave inward.",
                "Push through your front heel to return to standing. Alternate legs or complete all reps on one side first.",
            ],
            tips: [
                "Keep your torso upright; don't lean forward.",
                "Take a long enough step so your front knee doesn't go past your toes.",
            ],
            muscles: ["Quads", "Glutes", "Hamstrings"],
            targets: ["Strength", "Balance"],
            safetyNote: "Use a clear space. If balance is an issue, hold onto a wall or use bodyweight only.",
            difficultyLevel: .medium,
            easyVariation: "Bodyweight only or light dumbbells.",
            mediumVariation: "Moderate weight, alternating or walking lunges.",
            difficultVariation: "Reverse lunges, walking lunges, or heavier weight.",
            imagePlaceholderName: "DumbbellLunge"
        ),
        ExerciseDetail(
            exerciseName: "Hammer Curl",
            equipment: .dumbbells,
            summary: "Curl with palms facing each other to target biceps and forearms. Great for grip and arm size.",
            steps: [
                "Stand or sit with a dumbbell in each hand at your sides, palms facing your body (neutral grip).",
                "Keeping your upper arms still and elbows close, curl both dumbbells toward your shoulders.",
                "Squeeze at the top, then lower with control. Don't swing.",
            ],
            tips: [
                "Keep your thumbs pointing forward throughout—no rotation.",
                "Control the negative; don't let the weight drop.",
            ],
            muscles: ["Biceps", "Brachialis", "Forearms"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Avoid shrugging your shoulders.",
            difficultyLevel: .easy,
            easyVariation: "Seated, lighter weight, or one arm at a time.",
            mediumVariation: "Standing, moderate weight, both arms.",
            difficultVariation: "Cross-body hammer curl or heavier weight with pause at top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Lateral Raise",
            equipment: .dumbbells,
            summary: "Raise dumbbells out to the sides to build shoulder width and lateral deltoids.",
            steps: [
                "Stand with feet hip-width apart, a light dumbbell in each hand at your sides, palms in.",
                "With a slight bend in your elbows, raise both arms out to the sides until they reach shoulder height.",
                "Pause briefly, then lower with control. Don't swing.",
            ],
            tips: [
                "Lead with your elbows; keep hands slightly below elbow height.",
                "Use lighter weight—form matters more than load.",
            ],
            muscles: ["Lateral deltoids", "Upper traps"],
            targets: ["Strength"],
            safetyNote: "Don't raise above shoulder height if you have impingement. Start light.",
            difficultyLevel: .easy,
            easyVariation: "Seated, very light weight, or partial range.",
            mediumVariation: "Standing, full range to shoulder height.",
            difficultVariation: "Pause at top, or single-arm with slight lean.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Front Raise",
            equipment: .dumbbells,
            summary: "Raise dumbbells in front of you to target the front deltoids. Complements overhead press.",
            steps: [
                "Stand with feet hip-width apart, dumbbells in front of your thighs, palms facing your legs.",
                "Keeping a slight bend in your elbows, raise one or both dumbbells in front to shoulder height.",
                "Lower with control. Alternate arms or do both together.",
            ],
            tips: [
                "Keep your core tight so you don't arch your back.",
                "Control the weight—don't use momentum.",
            ],
            muscles: ["Front deltoids", "Upper chest"],
            targets: ["Strength"],
            safetyNote: "If you feel shoulder pinch, reduce range or use lighter weight.",
            difficultyLevel: .easy,
            easyVariation: "Alternating arms, light weight.",
            mediumVariation: "Both arms together, moderate weight.",
            difficultVariation: "Hold at top for 1–2 seconds or use a slight incline.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Reverse Fly",
            equipment: .dumbbells,
            summary: "Bent-over raise to target the rear deltoids and upper back. Improves posture.",
            steps: [
                "Hinge at the hips with a soft bend in your knees. Hold light dumbbells, arms hanging down, palms facing each other.",
                "Keeping a slight bend in your elbows, raise both arms out to the sides and slightly back, squeezing your shoulder blades.",
                "Lower with control. Don't stand up between reps.",
            ],
            tips: [
                "Keep your back flat; don't round your spine.",
                "Think of opening your arms like a book behind you.",
            ],
            muscles: ["Rear deltoids", "Rhomboids", "Upper back"],
            targets: ["Strength", "Posture"],
            safetyNote: "Start with light weight. Avoid rounding your lower back.",
            difficultyLevel: .medium,
            easyVariation: "Seated, chest on thighs, or very light weight.",
            mediumVariation: "Standing hinge, moderate weight.",
            difficultVariation: "Single-arm, or pause at top for 2 seconds.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Incline Dumbbell Press",
            equipment: .dumbbells,
            summary: "Press dumbbells on an incline to emphasize upper chest and shoulders.",
            steps: [
                "Set a bench to 30–45° incline. Sit with back supported, feet flat. Hold dumbbells at shoulder height, palms forward.",
                "Press both dumbbells up until your arms are extended (don't lock elbows).",
                "Lower with control to shoulder level. Keep weights in line with your upper chest.",
            ],
            tips: [
                "Keep your shoulder blades squeezed together on the bench.",
                "Don't let the weights drift too far apart at the top.",
            ],
            muscles: ["Upper chest", "Shoulders", "Triceps"],
            targets: ["Strength"],
            safetyNote: "Use a spotter or weights you can control. Secure the bench.",
            difficultyLevel: .difficult,
            easyVariation: "Lower incline (15–20°) or light weight.",
            mediumVariation: "30–45° incline, moderate weight.",
            difficultVariation: "Alternating arms or pause at bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Pullover",
            equipment: .dumbbells,
            summary: "Lower one dumbbell behind your head from your chest. Stretches and works chest and lats.",
            steps: [
                "Lie on your back on a bench or floor. Hold one dumbbell with both hands over your chest, arms slightly bent.",
                "Keeping your arms in a fixed arc, lower the dumbbell behind your head until you feel a stretch in your lats or chest.",
                "Pull the weight back to the start over your chest. Don't straighten your arms fully.",
            ],
            tips: [
                "Keep a slight bend in your elbows throughout.",
                "Control the stretch—don't let the weight pull your arms down quickly.",
            ],
            muscles: ["Lats", "Chest", "Triceps", "Core"],
            targets: ["Strength", "Flexibility"],
            safetyNote: "Use a weight you can control. Avoid overstretching the shoulders.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight, shorter range, or on the floor.",
            mediumVariation: "On bench, full range.",
            difficultVariation: "Heavier weight or pause at the bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Concentration Curl",
            equipment: .dumbbells,
            summary: "Seated curl with elbow braced against your thigh. Isolates the bicep with strict form.",
            steps: [
                "Sit on a bench or chair, legs apart. Hold one dumbbell, arm extended down, elbow resting against the inner thigh.",
                "Curl the dumbbell toward your shoulder, keeping your upper arm still and elbow braced.",
                "Squeeze your bicep at the top, then lower with control. Switch arms.",
            ],
            tips: [
                "Don't swing or use your body to lift.",
                "Focus on squeezing the bicep at the top.",
            ],
            muscles: ["Biceps"],
            targets: ["Strength"],
            safetyNote: "Use a controlled weight. Avoid straining your wrist.",
            difficultyLevel: .easy,
            easyVariation: "Lighter weight, focus on slow tempo.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Pause at top, or add a twist at the top (supination).",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Tricep Kickback",
            equipment: .dumbbells,
            summary: "Extend your arm back from a hinged position to isolate the triceps.",
            steps: [
                "Hinge at the hips, one hand on a bench or thigh for support. Hold a dumbbell in the other hand, elbow at 90° at your side.",
                "Keeping your upper arm still, extend your arm back until it is straight, squeezing your tricep.",
                "Lower with control. Complete reps then switch arms.",
            ],
            tips: [
                "Keep your elbow glued to your side; only your forearm moves.",
                "Squeeze at full extension for a moment.",
            ],
            muscles: ["Triceps"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Don't swing the arm.",
            difficultyLevel: .easy,
            easyVariation: "Lighter weight or both arms with light dumbbells.",
            mediumVariation: "Single arm, moderate weight.",
            difficultVariation: "Pause at full extension or use a slight pulse.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Calf Raise",
            equipment: .dumbbells,
            summary: "Rise onto your toes while holding dumbbells to strengthen your calves.",
            steps: [
                "Stand with feet hip-width apart (or slightly wider), dumbbells at your sides. You can stand on the floor or on a step for more range.",
                "Rise onto the balls of your feet, lifting your heels as high as you can.",
                "Squeeze your calves at the top, then lower with control. Don't bounce.",
            ],
            tips: [
                "Point your toes straight or slightly out—keep knees in line.",
                "For more range, stand on a step and let your heels drop below the step.",
            ],
            muscles: ["Calves (gastrocnemius and soleus)"],
            targets: ["Strength"],
            safetyNote: "Hold onto a wall or bench if balance is an issue. Start with light weight.",
            difficultyLevel: .easy,
            easyVariation: "Bodyweight only or light dumbbells.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Single-leg calf raise or pause at top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Step-Up",
            equipment: .dumbbells,
            summary: "Step onto a bench or box while holding dumbbells. Builds single-leg strength and stability.",
            steps: [
                "Stand in front of a stable bench or step, dumbbells at your sides. Place one foot fully on the bench.",
                "Drive through the standing leg and step up until both feet are on the bench. Keep your torso upright.",
                "Step down with control (same leg or alternate). Complete reps then switch leading leg.",
            ],
            tips: [
                "Push through the heel of the foot on the bench.",
                "Don't push off the back foot—let the front leg do the work.",
            ],
            muscles: ["Quads", "Glutes", "Hamstrings"],
            targets: ["Strength", "Balance"],
            safetyNote: "Use a stable surface. Start with a low step and light weight.",
            difficultyLevel: .difficult,
            easyVariation: "Bodyweight, low step.",
            mediumVariation: "Moderate height and weight.",
            difficultVariation: "Higher step, heavier weight, or hold at top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Swing",
            equipment: .dumbbells,
            summary: "Hip-hinge swing to build power in your hips and posterior chain. One dumbbell or two.",
            steps: [
                "Stand with feet slightly wider than shoulder-width, one dumbbell (or two) in front of you. Hinge at the hips and push them back, soft bend in knees.",
                "Swing the weight back between your legs, then drive your hips forward and swing the weight up to chest or shoulder height.",
                "Let the weight swing back down with control and repeat. Keep your arms relaxed; power comes from your hips.",
            ],
            tips: [
                "Think of the movement as a horizontal jump—explode through your hips.",
                "Don't squat; hinge. Your arms are just holding the weight.",
            ],
            muscles: ["Glutes", "Hamstrings", "Core", "Shoulders"],
            targets: ["Strength", "Power"],
            safetyNote: "Keep your back flat. Start with light weight to learn the pattern.",
            difficultyLevel: .difficult,
            easyVariation: "Lighter weight, swing to waist height.",
            mediumVariation: "Swing to chest height, controlled tempo.",
            difficultVariation: "Heavier weight or swing to shoulder height with pause.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Shrug",
            equipment: .dumbbells,
            summary: "Shrug your shoulders up while holding dumbbells to build traps and upper back.",
            steps: [
                "Stand with feet hip-width apart, a dumbbell in each hand at your sides, palms facing your body.",
                "Keeping your arms straight, shrug your shoulders straight up toward your ears.",
                "Squeeze your traps at the top, then lower with control. Don't roll your shoulders.",
            ],
            tips: [
                "Shrug straight up and back slightly—not in a circle.",
                "Hold the top for a second for a better squeeze.",
            ],
            muscles: ["Upper traps", "Levator scapulae"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can hold securely. Avoid neck strain.",
            difficultyLevel: .easy,
            easyVariation: "Lighter weight, focus on full range.",
            mediumVariation: "Moderate weight, controlled reps.",
            difficultVariation: "Pause at top for 2–3 seconds or use heavier weight.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dumbbell Chest Fly",
            equipment: .dumbbells,
            summary: "Open your arms with dumbbells on your back to stretch and work the chest. Great for chest stretch and definition.",
            steps: [
                "Lie on your back on a bench or floor, knees bent. Hold a dumbbell in each hand, arms extended over your chest with a slight bend in your elbows.",
                "Keeping that bend, lower your arms out to the sides in an arc until you feel a stretch in your chest.",
                "Bring the weights back together over your chest, squeezing your pecs. Don't lock your elbows.",
            ],
            tips: [
                "Keep a slight bend in your elbows throughout—don't straighten them.",
                "Control the stretch; don't let the weight pull your arms down too fast.",
            ],
            muscles: ["Chest", "Front deltoids"],
            targets: ["Strength", "Flexibility"],
            safetyNote: "Don't lower past shoulder level if you have shoulder issues. Use a weight you can control.",
            difficultyLevel: .easy,
            easyVariation: "On the floor for limited range; light weight.",
            mediumVariation: "On bench, full range.",
            difficultVariation: "Pause at the bottom or use a slightly heavier weight.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Arnold Press",
            equipment: .dumbbells,
            summary: "Overhead press with a rotation—starts palms in, ends palms out. Targets all three heads of the shoulder.",
            steps: [
                "Sit or stand with dumbbells at shoulder height, palms facing you, elbows in front.",
                "Press the weights up while rotating your palms outward. At the top, your palms face forward.",
                "Reverse the motion as you lower: rotate palms back in as you return to the start.",
            ],
            tips: [
                "Keep your core tight so you don't arch your back.",
                "Control the rotation—don't rush the turn.",
            ],
            muscles: ["Front deltoids", "Lateral deltoids", "Triceps"],
            targets: ["Strength"],
            safetyNote: "Start with light weight. Avoid pressing behind your head.",
            difficultyLevel: .difficult,
            easyVariation: "Seated, light weight, partial rotation.",
            mediumVariation: "Full rotation, moderate weight.",
            difficultVariation: "Standing, alternating arms, or pause at top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Chest Stretch / Push",
            equipment: .resistanceBands,
            summary: "Press or stretch a resistance band at chest height. Works chest and shoulders.",
            steps: [
                "Hold the band in both hands in front of your chest, arms slightly bent. Stand on the band or anchor it behind you.",
                "Push your hands forward (or apart) against the band until your arms are extended.",
                "Squeeze your chest, then return with control.",
            ],
            tips: [
                "Keep your core tight and don't arch your back.",
                "Control the return—don't let the band snap back.",
            ],
            muscles: ["Chest", "Shoulders", "Triceps"],
            targets: ["Strength"],
            safetyNote: "Check that the band is secure. Use a band with appropriate resistance.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band or shorter range.",
            mediumVariation: "Standard band, full push.",
            difficultVariation: "Heavier band or add a pause at full extension.",
            imagePlaceholderName: "BandChestStretch"
        ),
        ExerciseDetail(
            exerciseName: "Band Glute Bridge",
            equipment: .resistanceBands,
            summary: "Bridge your hips up with a band around your legs to add resistance. Targets glutes and hamstrings.",
            steps: [
                "Lie on your back, knees bent, feet flat. Place a resistance band just above your knees.",
                "Push your knees out slightly against the band. Drive through your heels and lift your hips toward the ceiling.",
                "Squeeze your glutes at the top. Lower with control.",
            ],
            tips: [
                "Don't over-arch your lower back—focus on squeezing your glutes.",
                "Keep the band taut by pushing your knees out.",
            ],
            muscles: ["Glutes", "Hamstrings", "Core"],
            targets: ["Strength"],
            safetyNote: "If you feel back pain, reduce the range or remove the band.",
            difficultyLevel: .easy,
            easyVariation: "Bodyweight bridge first; add band when comfortable.",
            mediumVariation: "Band above knees, full range.",
            difficultVariation: "Single-leg bridge with band or hold at top.",
            imagePlaceholderName: "BandGluteBridge"
        ),
        ExerciseDetail(
            exerciseName: "Band Row",
            equipment: .resistanceBands,
            summary: "Pull the band to your hips to work your back and biceps. Anchor the band in front of you.",
            steps: [
                "Anchor the band at chest height (door, pole, or under your feet). Hold the band with both hands, arms extended.",
                "Pull the band toward your hips, squeezing your shoulder blades together. Keep your elbows close to your body.",
                "Control the return. Don't let the band snap back.",
            ],
            tips: [
                "Keep your core tight; don't swing your body.",
                "Squeeze at the end of the pull for a second.",
            ],
            muscles: ["Lats", "Rhomboids", "Biceps", "Rear deltoids"],
            targets: ["Strength", "Posture"],
            safetyNote: "Secure the anchor. Use a band with appropriate resistance.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band or single-arm row.",
            mediumVariation: "Both arms, moderate tension.",
            difficultVariation: "Heavier band or pause at full contraction.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Chest Press",
            equipment: .resistanceBands,
            summary: "Press the band forward from your chest. Anchor the band behind your back for resistance.",
            steps: [
                "Loop the band behind your back, under your shoulder blades. Hold the ends at chest height, elbows bent.",
                "Press your hands forward until your arms are extended. Don't lock your elbows.",
                "Return with control. Keep the band secure behind you.",
            ],
            tips: [
                "Keep your shoulder blades slightly squeezed.",
                "Don't let your shoulders roll forward at the top.",
            ],
            muscles: ["Chest", "Triceps", "Front deltoids"],
            targets: ["Strength"],
            safetyNote: "Ensure the band is secure. Start with light resistance.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, shorter range.",
            mediumVariation: "Moderate band, full press.",
            difficultVariation: "Heavier band or add a pause at full extension.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Lateral Raise",
            equipment: .resistanceBands,
            summary: "Stand on the band and raise your arms out to the sides to work your lateral deltoids.",
            steps: [
                "Stand on the center of the band with feet hip-width apart. Hold the ends at your sides, palms in.",
                "Keeping a slight bend in your elbows, raise both arms out to the sides to shoulder height.",
                "Lower with control. Don't let the band snap.",
            ],
            tips: [
                "Lead with your elbows; keep hands slightly below elbows.",
                "Use a band that allows 12–15 controlled reps.",
            ],
            muscles: ["Lateral deltoids", "Upper traps"],
            targets: ["Strength"],
            safetyNote: "Don't raise above shoulder height if you have shoulder issues.",
            difficultyLevel: .easy,
            easyVariation: "Seated, lighter band.",
            mediumVariation: "Standing, full range.",
            difficultVariation: "Pause at top or use a heavier band.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Face Pull",
            equipment: .resistanceBands,
            summary: "Pull the band toward your face with elbows high. Great for rear delts and upper back.",
            steps: [
                "Anchor the band at chest or eye level. Hold with both hands, arms extended.",
                "Pull the band toward your face, bringing your elbows out to the sides and back. Squeeze your shoulder blades.",
                "Return with control. Keep your core tight.",
            ],
            tips: [
                "Think of pulling your hands to your ears, elbows wide.",
                "External rotation at the end adds rotator cuff work.",
            ],
            muscles: ["Rear deltoids", "Rhomboids", "Rotator cuff"],
            targets: ["Strength", "Posture", "Shoulder health"],
            safetyNote: "Use a controlled band. Don't jerk the pull.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, pull to chest first.",
            mediumVariation: "Pull to face level, full range.",
            difficultVariation: "Pause at full pull or heavier band.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Bicep Curl",
            equipment: .resistanceBands,
            summary: "Stand on the band and curl your hands to your shoulders to work your biceps.",
            steps: [
                "Stand on the center of the band. Hold the ends at your sides, palms forward.",
                "Keeping your upper arms still, curl your hands toward your shoulders.",
                "Squeeze your biceps at the top, then lower with control.",
            ],
            tips: [
                "Don't swing—use a controlled tempo.",
                "Keep your elbows close to your body.",
            ],
            muscles: ["Biceps", "Forearms"],
            targets: ["Strength"],
            safetyNote: "Use a band you can control. Avoid straining your wrists.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band or single-arm curl.",
            mediumVariation: "Both arms, moderate tension.",
            difficultVariation: "Heavier band or pause at top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Tricep Pushdown",
            equipment: .resistanceBands,
            summary: "Anchor the band above you and push down to target your triceps.",
            steps: [
                "Anchor the band overhead (door, bar, or hold with opposite hand). Grip the band with both hands, elbows at your sides at 90°.",
                "Push your hands down until your arms are straight. Squeeze your triceps.",
                "Return with control. Keep your elbows at your sides.",
            ],
            tips: [
                "Only your forearms should move; upper arms stay fixed.",
                "Squeeze at full extension for a moment.",
            ],
            muscles: ["Triceps"],
            targets: ["Strength"],
            safetyNote: "Secure the anchor. Start with light resistance.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, partial range.",
            mediumVariation: "Full range, moderate band.",
            difficultVariation: "Heavier band or single-arm pushdown.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Squat",
            equipment: .resistanceBands,
            summary: "Squat with the band under your feet or above your knees for extra resistance and glute activation.",
            steps: [
                "Stand on the band with feet shoulder-width apart, or place a loop band just above your knees.",
                "Push your hips back and bend your knees to lower into a squat. Keep your chest up.",
                "Drive through your heels to stand. If using a band above knees, push knees out against the band.",
            ],
            tips: [
                "Keep your knees in line with your toes.",
                "The band above knees helps activate glutes and prevent knee cave.",
            ],
            muscles: ["Quads", "Glutes", "Hamstrings"],
            targets: ["Strength"],
            safetyNote: "Use a stable band. Don't let the band slip.",
            difficultyLevel: .easy,
            easyVariation: "Band above knees only, bodyweight squat depth.",
            mediumVariation: "Band under feet or both band positions.",
            difficultVariation: "Heavier band or pause at bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Leg Curl",
            equipment: .resistanceBands,
            summary: "Curl your heel toward your glutes against band resistance. Lie face down or stand.",
            steps: [
                "Anchor the band behind you (or attach to a fixed point). Loop the band around one ankle. Lie face down or stand holding something for balance.",
                "Keeping your thigh still, curl your heel toward your glutes against the band tension.",
                "Return with control. Switch legs.",
            ],
            tips: [
                "Squeeze your hamstring at the top.",
                "Keep your hips down if lying; don't lift your hip when standing.",
            ],
            muscles: ["Hamstrings"],
            targets: ["Strength"],
            safetyNote: "Secure the anchor. Use a band that allows full range.",
            difficultyLevel: .medium,
            easyVariation: "Lying, lighter band.",
            mediumVariation: "Standing or lying, moderate band.",
            difficultVariation: "Heavier band or slow tempo.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Hip Abduction",
            equipment: .resistanceBands,
            summary: "Push your leg or knee out to the side against the band. Targets outer hip and glutes.",
            steps: [
                "Place a loop band around your legs (above or below knees). Stand or lie on your side.",
                "Keeping your standing leg stable, push the other knee or leg out to the side against the band.",
                "Return with control. Complete reps then switch sides if single-leg.",
            ],
            tips: [
                "Keep your core tight; don't lean or twist.",
                "Squeeze your outer glute at the end range.",
            ],
            muscles: ["Gluteus medius", "Hip abductors"],
            targets: ["Strength", "Hip stability"],
            safetyNote: "Use a band that allows controlled movement. Don't snap the band.",
            difficultyLevel: .easy,
            easyVariation: "Band above knees, smaller range.",
            mediumVariation: "Standing or side-lying, full range.",
            difficultVariation: "Band at ankles or add a hold at peak.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Clam Shell",
            equipment: .resistanceBands,
            summary: "Side-lying with a band above your knees; open your top knee. Great for gluteus medius.",
            steps: [
                "Lie on your side with a loop band around your legs just above your knees. Knees bent at 45°, feet together.",
                "Keeping your feet together, lift your top knee up and out against the band. Don't roll your hips back.",
                "Lower with control. Complete reps then switch sides.",
            ],
            tips: [
                "Keep your core tight; don't let your top hip roll back.",
                "Squeeze at the top for a second.",
            ],
            muscles: ["Gluteus medius", "Hip external rotators"],
            targets: ["Strength", "Hip stability"],
            safetyNote: "Start with a light band. Avoid back or hip pain.",
            difficultyLevel: .easy,
            easyVariation: "No band first; add band when comfortable.",
            mediumVariation: "Light band, full range.",
            difficultVariation: "Heavier band or hold at top for 3 seconds.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Monster Walk",
            equipment: .resistanceBands,
            summary: "Loop band around legs; walk in a slight squat with small steps. Builds glute and hip strength.",
            steps: [
                "Place a loop band around your legs (above knees or at ankles). Stand with feet hip-width, slight bend in knees.",
                "Keeping tension on the band, take small steps forward (or sideways). Stay in a mini-squat position.",
                "Walk 10 steps one direction, then reverse. Don't let your knees cave in.",
            ],
            tips: [
                "Keep constant tension on the band—don't step so far that it goes slack.",
                "Push your knees out against the band with each step.",
            ],
            muscles: ["Glutes", "Hip abductors", "Quads"],
            targets: ["Strength", "Stability"],
            safetyNote: "Use a clear space. Start with a light band.",
            difficultyLevel: .easy,
            easyVariation: "Band above knees, short distance.",
            mediumVariation: "Sideways or forward, moderate band.",
            difficultVariation: "Band at ankles or longer walk.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Lateral Walk",
            equipment: .resistanceBands,
            summary: "Mini-squat with a band around your legs; step sideways. Targets glutes and outer hips.",
            steps: [
                "Place a loop band above your knees. Stand with feet hip-width, slight bend in knees (mini-squat).",
                "Step one foot to the side, then bring the other foot to meet it. Keep tension on the band.",
                "Walk 10 steps one way, then 10 back. Don't let your knees cave.",
            ],
            tips: [
                "Stay low; don't stand up between steps.",
                "Lead with your heels; push knees out.",
            ],
            muscles: ["Gluteus medius", "Glutes", "Hip abductors"],
            targets: ["Strength", "Stability"],
            safetyNote: "Keep the band secure. Use a clear path.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, shorter steps.",
            mediumVariation: "Moderate band, full steps.",
            difficultVariation: "Band at ankles or add a squat at each step.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Deadlift",
            equipment: .resistanceBands,
            summary: "Stand on the band and hinge at the hips while holding the band. Adds resistance to the hip hinge.",
            steps: [
                "Stand on the center of the band with feet hip-width apart. Hold the band at shoulder height or in front of your thighs.",
                "Hinge at your hips, pushing them back. Lower the band along your legs, keeping your back flat.",
                "Drive through your heels and squeeze your glutes to stand. Control the band tension throughout.",
            ],
            tips: [
                "Keep the band close to your body. Think hip hinge, not squat.",
                "Don't round your lower back.",
            ],
            muscles: ["Hamstrings", "Glutes", "Lower back"],
            targets: ["Strength"],
            safetyNote: "Use a band you can control. Never round your spine.",
            difficultyLevel: .difficult,
            easyVariation: "Lighter band, shorter range.",
            mediumVariation: "Moderate band, full hinge.",
            difficultVariation: "Heavier band or pause at the bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Pallof Press",
            equipment: .resistanceBands,
            summary: "Hold the band at chest and press forward while resisting rotation. Anti-rotation core exercise.",
            steps: [
                "Anchor the band to your side at chest height. Hold the band with both hands at your chest, stand perpendicular to the anchor.",
                "Brace your core and press the band straight out in front of you. Resist the band's pull to rotate you.",
                "Hold for a second, then return to chest. Complete reps then face the other way.",
            ],
            tips: [
                "Keep your hips and shoulders square; don't let the band twist you.",
                "Breathe out as you press.",
            ],
            muscles: ["Core", "Obliques", "Hip stabilizers"],
            targets: ["Strength", "Stability"],
            safetyNote: "Secure the anchor. Start with light resistance.",
            difficultyLevel: .difficult,
            easyVariation: "Lighter band, shorter hold.",
            mediumVariation: "Moderate band, full press and hold.",
            difficultVariation: "Heavier band or add a rotation at full extension.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Wood Chop",
            equipment: .resistanceBands,
            summary: "Rotate your torso and pull the band across your body. Works core and obliques.",
            steps: [
                "Anchor the band at one side (high or low). Hold the band with both hands, arms extended toward the anchor.",
                "Rotate your torso and pull the band across your body to the opposite side. Pivot your feet if needed.",
                "Control the return. Complete reps then switch anchor side.",
            ],
            tips: [
                "Move from your core and hips, not just your arms.",
                "Keep a slight bend in your knees.",
            ],
            muscles: ["Core", "Obliques", "Shoulders"],
            targets: ["Strength", "Rotation"],
            safetyNote: "Use a secure anchor. Don't twist your lower back forcefully.",
            difficultyLevel: .difficult,
            easyVariation: "Lighter band, smaller rotation.",
            mediumVariation: "Moderate band, full rotation.",
            difficultVariation: "Heavier band or high-to-low chop.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band External Rotation",
            equipment: .resistanceBands,
            summary: "Rotate your forearm outward with elbow at 90°. Strengthens the rotator cuff.",
            steps: [
                "Anchor the band at your side (or hold with opposite hand). Keep your elbow at your side, bent to 90°, band in hand.",
                "Keeping your elbow fixed, rotate your forearm outward against the band. Don't let your elbow leave your side.",
                "Return with control. Complete reps then switch arms.",
            ],
            tips: [
                "Keep your elbow glued to your side; only the forearm moves.",
                "Use a light band—rotator cuff responds to higher reps.",
            ],
            muscles: ["Rotator cuff", "Rear deltoids"],
            targets: ["Strength", "Shoulder health"],
            safetyNote: "Use light resistance. Stop if you feel shoulder pinch.",
            difficultyLevel: .easy,
            easyVariation: "Very light band, partial range.",
            mediumVariation: "Full range, light to moderate band.",
            difficultVariation: "Pause at full external rotation.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Good Morning",
            equipment: .resistanceBands,
            summary: "Stand on the band with it behind your neck; hinge at the hips. Stretches and strengthens hamstrings.",
            steps: [
                "Stand on the band, feet hip-width. Place the band behind your neck and over your shoulders (or hold at chest).",
                "With a soft bend in your knees, hinge at your hips and push them back. Lower your torso toward the floor.",
                "Feel the stretch in your hamstrings, then drive through your heels to stand. Keep your back flat.",
            ],
            tips: [
                "This is a hinge, not a squat—your knees stay only slightly bent.",
                "Keep your core braced throughout.",
            ],
            muscles: ["Hamstrings", "Glutes", "Lower back"],
            targets: ["Strength", "Flexibility"],
            safetyNote: "Never round your back. Use a light band to start.",
            difficultyLevel: .difficult,
            easyVariation: "No band, bodyweight only.",
            mediumVariation: "Light band, full range.",
            difficultVariation: "Heavier band or pause at bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Donkey Kick",
            equipment: .resistanceBands,
            summary: "Kick one leg back against the band to target your glutes. Anchor the band behind you.",
            steps: [
                "Anchor the band behind you (or loop around the working foot and hold the other end). Get on all fours or stand holding a wall.",
                "Keeping your knee bent, kick one foot back and up, squeezing your glute. Resist the band on the way back.",
                "Return with control. Complete reps then switch legs.",
            ],
            tips: [
                "Keep your hips square; don't rotate your body.",
                "Squeeze your glute at the top of the kick.",
            ],
            muscles: ["Glutes", "Hamstrings"],
            targets: ["Strength"],
            safetyNote: "Secure the anchor. Don't arch your lower back.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band or no band first.",
            mediumVariation: "Moderate band, full range.",
            difficultVariation: "Heavier band or hold at top for 2 seconds.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Y Raise",
            equipment: .resistanceBands,
            summary: "Raise your arms in a Y shape against the band. Targets lower traps and shoulder health.",
            steps: [
                "Stand on the center of the band. Hold the ends, arms down in front, thumbs up.",
                "Raise your arms up and out in a Y shape (about 30° in front of your body) to eye level or slightly above.",
                "Lower with control. Keep a slight bend in your elbows.",
            ],
            tips: [
                "Lead with your thumbs; don't shrug your shoulders up.",
                "Use a light band—focus on lower trap engagement.",
            ],
            muscles: ["Lower traps", "Rear deltoids", "Serratus"],
            targets: ["Strength", "Posture", "Shoulder health"],
            safetyNote: "Use light resistance. Stop if you feel shoulder pinch.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, partial Y.",
            mediumVariation: "Full Y to eye level.",
            difficultVariation: "Pause at top or slightly heavier band.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Single-Arm Row",
            equipment: .resistanceBands,
            summary: "Pull the band with one hand to your hip. Same as band row but one arm at a time.",
            steps: [
                "Anchor the band in front of you at chest height. Hold with one hand, arm extended, other hand can support your knee or a wall.",
                "Pull the band to your hip, squeezing your shoulder blade. Keep your core tight so you don't rotate.",
                "Return with control. Complete reps then switch arms.",
            ],
            tips: [
                "Keep your hips and shoulders square; don't twist toward the band.",
                "Squeeze at the end of the pull.",
            ],
            muscles: ["Lats", "Rhomboids", "Biceps", "Rear deltoids"],
            targets: ["Strength", "Posture"],
            safetyNote: "Secure the anchor. Use appropriate band tension.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, focus on form.",
            mediumVariation: "Moderate band, full range.",
            difficultVariation: "Heavier band or pause at full contraction.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Crunch",
            equipment: .resistanceBands,
            summary: "Crunch forward against band resistance. Anchor the band behind you for added load.",
            steps: [
                "Anchor the band behind you (e.g. behind your back, or around a post). Hold the band at your chest or behind your head.",
                "Lie back until the band has tension. Curl your head and shoulders off the floor, crunching your abs.",
                "Lower with control. Don't pull on your neck.",
            ],
            tips: [
                "Exhale as you crunch; keep the movement in your abs.",
                "Use a band that allows 12–15 controlled reps.",
            ],
            muscles: ["Abs", "Core"],
            targets: ["Strength"],
            safetyNote: "Don't strain your neck. Support your head lightly if needed.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band or bodyweight crunch first.",
            mediumVariation: "Moderate band, full crunch.",
            difficultVariation: "Heavier band or add a twist at the top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Hip Thrust",
            equipment: .resistanceBands,
            summary: "Thrust your hips up with a band above your knees. Back on a bench or floor; glute focus.",
            steps: [
                "Sit on the floor with your upper back on a bench (or against a couch). Place a loop band above your knees. Feet flat, knees bent.",
                "Drive through your heels and lift your hips until your body is in a straight line from shoulders to knees. Push your knees out against the band.",
                "Squeeze your glutes at the top, then lower with control.",
            ],
            tips: [
                "Keep your chin slightly tucked; don't hyperextend your neck.",
                "Push your knees out throughout to keep band tension.",
            ],
            muscles: ["Glutes", "Hamstrings", "Core"],
            targets: ["Strength"],
            safetyNote: "Use a stable bench. Don't over-arch your lower back at the top.",
            difficultyLevel: .difficult,
            easyVariation: "Floor only (no bench), light band.",
            mediumVariation: "Bench, moderate band.",
            difficultVariation: "Heavier band or single-leg hip thrust.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Reverse Fly",
            equipment: .resistanceBands,
            summary: "Hinge and pull the band back with arms out to the sides. Targets rear delts and upper back.",
            steps: [
                "Stand on the band (or anchor in front). Hinge at your hips, soft bend in knees. Hold the band with both hands, arms hanging down.",
                "Keeping a slight bend in your elbows, raise your arms out to the sides and back, squeezing your shoulder blades.",
                "Lower with control. Don't stand up between reps.",
            ],
            tips: [
                "Lead with your elbows; keep your back flat.",
                "Squeeze your rear delts at the top.",
            ],
            muscles: ["Rear deltoids", "Rhomboids", "Upper back"],
            targets: ["Strength", "Posture"],
            safetyNote: "Start with a light band. Avoid rounding your lower back.",
            difficultyLevel: .easy,
            easyVariation: "Seated, chest on thighs; light band.",
            mediumVariation: "Standing hinge, moderate band.",
            difficultVariation: "Heavier band or pause at full contraction.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Band Overhead Press",
            equipment: .resistanceBands,
            summary: "Stand on the band and press your hands overhead from shoulder height.",
            steps: [
                "Stand on the center of the band. Hold the ends at shoulder height, elbows bent, palms forward.",
                "Press both hands straight up until your arms are extended. Don't lock your elbows or arch your back.",
                "Lower with control to shoulder height.",
            ],
            tips: [
                "Keep your core tight throughout.",
                "Don't let your elbows flare too far out.",
            ],
            muscles: ["Shoulders", "Triceps", "Upper chest"],
            targets: ["Strength"],
            safetyNote: "Use a band you can control. Avoid pressing behind your head.",
            difficultyLevel: .easy,
            easyVariation: "Lighter band, seated if needed.",
            mediumVariation: "Standing, moderate band.",
            difficultVariation: "Heavier band or alternating arms.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Cat-Cow",
            equipment: .yogaMat,
            summary: "Gentle spinal movement on all fours. Round then arch your back with your breath. Warms the spine and relieves tension.",
            steps: [
                "Start on hands and knees, wrists under shoulders, knees under hips. Neutral spine.",
                "Inhale: drop your belly, lift your chest and tailbone (Cow—arch). Look slightly up.",
                "Exhale: round your spine, tuck your tailbone, drop your head (Cat). Repeat with each breath.",
            ],
            tips: [
                "Move slowly and link each movement to your breath.",
                "Keep your arms straight; movement comes from your spine.",
            ],
            muscles: ["Spine", "Core", "Neck and shoulders"],
            targets: ["Flexibility", "Mobility", "Relaxation"],
            safetyNote: "If you have wrist pain, use fists or rest on forearms. Go only to a comfortable range.",
            difficultyLevel: .easy,
            easyVariation: "Smaller range; focus on breath only.",
            mediumVariation: "Full Cat-Cow, 8–10 rounds.",
            difficultVariation: "Add a twist at the top of Cow (one arm reaches up).",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Child's Pose",
            equipment: .yogaMat,
            summary: "Restful fold with knees under hips and arms extended. Stretches the back and hips and calms the mind.",
            steps: [
                "Kneel with knees under hips, big toes touching. Sit back toward your heels.",
                "Fold forward and rest your forehead on the mat. Extend your arms forward or alongside your body.",
                "Breathe deeply and hold 30 seconds to 2 minutes. Relax your shoulders.",
            ],
            tips: [
                "If your forehead doesn't reach the floor, rest on stacked hands or a block.",
                "Widen your knees if you need more room for your belly.",
            ],
            muscles: ["Back", "Hips", "Shoulders"],
            targets: ["Flexibility", "Relaxation", "Recovery"],
            safetyNote: "Avoid if you have knee issues. Use a cushion under knees or between heels and hips if needed.",
            difficultyLevel: .easy,
            easyVariation: "Arms by your sides; short hold.",
            mediumVariation: "Arms extended, 30–60 sec hold.",
            difficultVariation: "Reach arms further forward; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Downward Dog",
            equipment: .yogaMat,
            summary: "Inverted V shape with hips high and heels toward the floor. Stretches hamstrings, shoulders, and calves.",
            steps: [
                "From hands and knees, tuck your toes and lift your hips up and back. Straighten your legs as much as you can.",
                "Form an inverted V. Press your hands into the mat, spread your fingers. Heels can stay off the floor.",
                "Hold 30 seconds to 1 minute. Pedal your feet if your hamstrings are tight.",
            ],
            tips: [
                "Bend your knees if your lower back rounds; focus on lengthening your spine.",
                "Press your chest toward your thighs to open your shoulders.",
            ],
            muscles: ["Hamstrings", "Calves", "Shoulders", "Back"],
            targets: ["Flexibility", "Strength", "Energy"],
            safetyNote: "Avoid if you have high blood pressure or wrist issues. Use blocks under hands to reduce wrist angle.",
            difficultyLevel: .easy,
            easyVariation: "Bent knees, short hold.",
            mediumVariation: "Full pose, 30–60 sec.",
            difficultVariation: "Straight legs, heels toward floor; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Hip Stretch",
            equipment: .yogaMat,
            summary: "Seated or lying hip opener to release tension in the hips and groin. Hold 20–30 seconds each side.",
            steps: [
                "Seated: sit with one leg extended, other foot to inner thigh (or sole to opposite thigh for a figure-four). Gently fold or sit tall.",
                "Supine: lie on your back, cross one ankle over the opposite knee, then draw the supporting leg in. Or bring soles together and let knees fall out (butterfly).",
                "Breathe and hold 20–30 seconds. Switch sides.",
            ],
            tips: [
                "Don't force the stretch; let gravity and breath do the work.",
                "Keep your back straight if seated; avoid rounding.",
            ],
            muscles: ["Hips", "Glutes", "Inner thighs"],
            targets: ["Flexibility", "Recovery"],
            safetyNote: "Avoid sharp pain. Ease off if you feel strain in the knee.",
            difficultyLevel: .easy,
            easyVariation: "Shorter hold; supported position.",
            mediumVariation: "20–30 sec each side.",
            difficultVariation: "Deeper fold or longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Cobra",
            equipment: .yogaMat,
            summary: "Backbend from the belly. Press chest up with hands under shoulders; keep hips on the mat. Opens the front body.",
            steps: [
                "Lie on your belly, hands under your shoulders, elbows close. Legs extended, tops of feet on the mat.",
                "Press into your hands and lift your chest off the floor. Keep your hips and legs down; use your back muscles, not just your arms.",
                "Hold a few breaths, then lower with control. Repeat 5–8 times or hold.",
            ],
            tips: [
                "Don't lock your elbows; keep a slight bend. Draw shoulders back and down.",
                "Lengthen your neck; look forward or slightly up, not back.",
            ],
            muscles: ["Spine", "Core", "Chest", "Shoulders"],
            targets: ["Flexibility", "Strength"],
            safetyNote: "Avoid if you have back or neck issues. Keep the bend in your lower back moderate.",
            difficultyLevel: .easy,
            easyVariation: "Small lift; sphinx pose (forearms on floor) instead.",
            mediumVariation: "Full Cobra, 5–8 reps or hold.",
            difficultVariation: "Higher hold or add a gentle sway.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Warrior I",
            equipment: .yogaMat,
            summary: "Standing lunge with back foot turned out and arms raised. Builds leg strength and opens the hips.",
            steps: [
                "From standing, step one foot back and turn the back foot out about 45°. Front knee bends to 90° over the ankle.",
                "Square your hips forward as much as you can. Raise both arms overhead, palms facing or hands together.",
                "Hold 30 seconds. Breathe. Switch sides.",
            ],
            tips: [
                "Keep your back leg straight and strong; press through the outer edge of the back foot.",
                "Draw your lower belly in to protect your lower back.",
            ],
            muscles: ["Quads", "Glutes", "Hip flexors", "Shoulders"],
            targets: ["Strength", "Balance", "Flexibility"],
            safetyNote: "Don't let your front knee go past your toes. Ease off if you feel knee strain.",
            difficultyLevel: .difficult,
            easyVariation: "Shorter stance; arms at heart center.",
            mediumVariation: "Full pose, 30 sec each side.",
            difficultVariation: "Deeper lunge; arms overhead; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Warrior II",
            equipment: .yogaMat,
            summary: "Wide stance with front knee bent and arms extended to the sides. Strengthens legs and opens the hips.",
            steps: [
                "Stand with legs wide. Turn your back foot in slightly, front foot out 90°. Bend your front knee over the ankle.",
                "Arms extend out to the sides at shoulder height, parallel to the floor. Gaze over the front hand.",
                "Hold 30 seconds. Keep your back leg straight. Switch sides.",
            ],
            tips: [
                "Stack your front knee over your ankle; don't let it cave in.",
                "Reach through your fingertips; keep shoulders relaxed.",
            ],
            muscles: ["Quads", "Glutes", "Hip abductors", "Shoulders"],
            targets: ["Strength", "Stability", "Endurance"],
            safetyNote: "Protect your front knee; keep it in line with your toes.",
            difficultyLevel: .difficult,
            easyVariation: "Shorter stance; 20 sec hold.",
            mediumVariation: "Full Warrior II, 30 sec each side.",
            difficultVariation: "Deeper stance; 45–60 sec hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Triangle Pose",
            equipment: .yogaMat,
            summary: "Wide-legged standing pose; reach one hand to shin or floor, other arm up. Stretches sides and legs.",
            steps: [
                "From a wide stance, turn one foot out 90°, other foot in slightly. Extend your arms to the sides.",
                "Reach your front hand down to your shin, ankle, or a block. Lift your back arm straight up; gaze at your top hand or forward.",
                "Keep both legs straight. Hold 30 seconds. Switch sides.",
            ],
            tips: [
                "Lengthen your spine; don't collapse into the bottom hand.",
                "Engage your core; imagine your torso between two panes of glass.",
            ],
            muscles: ["Hamstrings", "Hips", "Side body", "Shoulders"],
            targets: ["Flexibility", "Balance", "Stability"],
            safetyNote: "Don't lock your front knee. Use a block if you can't reach your shin comfortably.",
            difficultyLevel: .difficult,
            easyVariation: "Hand on thigh; shorter hold.",
            mediumVariation: "Hand to shin or block, 30 sec.",
            difficultVariation: "Hand to floor; longer hold or bind.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Seated Forward Fold",
            equipment: .yogaMat,
            summary: "Sit with legs extended and fold forward from the hips. Stretches the entire back body.",
            steps: [
                "Sit with your legs extended in front, feet flexed. Sit tall on your sitting bones.",
                "Inhale to lengthen your spine; exhale and hinge from your hips to fold forward. Reach for your feet, shins, or hold a strap.",
                "Hold 30 seconds to 2 minutes. Breathe and relax into the stretch.",
            ],
            tips: [
                "Fold from the hips, not the lower back. Keep your spine long.",
                "Bend your knees if your hamstrings are very tight.",
            ],
            muscles: ["Hamstrings", "Back", "Calves"],
            targets: ["Flexibility", "Calm"],
            safetyNote: "Avoid rounding your lower back forcefully. Use a strap if you can't reach your feet.",
            difficultyLevel: .easy,
            easyVariation: "Knees bent; hold behind thighs.",
            mediumVariation: "Legs straight, hold 30–60 sec.",
            difficultVariation: "Full fold; longer hold; chest to thighs.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Low Lunge",
            equipment: .yogaMat,
            summary: "One knee down, front foot forward; sink into the hip of the back leg. Deep hip flexor and quad stretch.",
            steps: [
                "From hands and knees or downward dog, step one foot forward between your hands. Lower your back knee to the mat.",
                "Keep your front knee over your ankle. Sink your hips forward and down. You can stay on your hands or raise your arms.",
                "Hold 30 seconds. Switch sides.",
            ],
            tips: [
                "Tuck your back toe to protect the knee; optionally pad the back knee.",
                "Draw your front ribs in to avoid overarching your lower back.",
            ],
            muscles: ["Hip flexors", "Quads", "Glutes"],
            targets: ["Flexibility", "Hip opening"],
            safetyNote: "Pad your back knee if it's sensitive. Ease off if you feel knee or back strain.",
            difficultyLevel: .easy,
            easyVariation: "Hands on blocks or front knee; short hold.",
            mediumVariation: "Arms up; 30 sec each side.",
            difficultVariation: "Back knee up (Crescent); deeper sink; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Pigeon Pose",
            equipment: .yogaMat,
            summary: "One leg bent in front, back leg extended behind. Deep hip opener for glutes and external rotators.",
            steps: [
                "From all fours or downward dog, bring one knee forward and place that shin on the mat (parallel to the front of the mat or slightly angled). Extend your back leg behind.",
                "Keep your hips square. Fold forward over the front leg or stay upright. Breathe and hold 30 seconds to 1 minute.",
                "Switch sides.",
            ],
            tips: [
                "If your front knee feels stressed, slide that foot closer to the opposite hip or use a cushion under the hip.",
                "Stay upright first; fold only if your hips are open enough.",
            ],
            muscles: ["Glutes", "Hip external rotators", "Hip flexors"],
            targets: ["Flexibility", "Hip opening"],
            safetyNote: "Protect your front knee; don't force the angle. Use padding under the hip if needed.",
            difficultyLevel: .difficult,
            easyVariation: "Reclined pigeon (on back) or supported pigeon with block.",
            mediumVariation: "Full pigeon, 30 sec each side.",
            difficultVariation: "Fold forward; longer hold; or king pigeon with back foot reach.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Thread the Needle",
            equipment: .yogaMat,
            summary: "On all fours, thread one arm under your body and twist. Stretches the upper back and shoulders.",
            steps: [
                "Start on hands and knees. Slide one arm under your body (palm up or down), threading it between your opposite arm and leg.",
                "Rest your shoulder and side of your head on the mat. Your other hand can stay on the floor or walk forward. Feel the twist in your upper back.",
                "Hold 30 seconds. Repeat on the other side.",
            ],
            tips: [
                "Keep your hips stacked; don't let them twist with the arm.",
                "Breathe into the side and back that are stretching.",
            ],
            muscles: ["Upper back", "Shoulders", "Side body"],
            targets: ["Flexibility", "Mobility", "Release"],
            safetyNote: "Go slowly. Avoid if you have shoulder impingement.",
            difficultyLevel: .easy,
            easyVariation: "Shallow thread; short hold.",
            mediumVariation: "Full thread, 30 sec each side.",
            difficultVariation: "Reach the top arm up and back for more stretch.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Supine Twist",
            equipment: .yogaMat,
            summary: "Lie on your back and drop both knees to one side. Gentle spinal twist for the whole back.",
            steps: [
                "Lie on your back. Draw both knees into your chest, then lower them together to one side. Arms can be out in a T or one hand on the opposite knee.",
                "Turn your gaze to the opposite side. Keep both shoulders on the floor if you can.",
                "Hold 30 seconds to 1 minute. Inhale knees to center, exhale to the other side.",
            ],
            tips: [
                "Let your knees rest where they're comfortable; they don't have to touch the floor.",
                "Use your breath to soften into the twist.",
            ],
            muscles: ["Spine", "Core", "Hips"],
            targets: ["Flexibility", "Digestion", "Relaxation"],
            safetyNote: "Avoid if you have disc issues. Keep the twist gentle.",
            difficultyLevel: .easy,
            easyVariation: "One knee only; short hold.",
            mediumVariation: "Both knees, 30 sec each side.",
            difficultVariation: "Eagle legs in twist; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Happy Baby",
            equipment: .yogaMat,
            summary: "On your back, grab your feet and rock gently. Releases the lower back and hips.",
            steps: [
                "Lie on your back. Draw your knees toward your armpits and hold the outsides of your feet (or use a strap).",
                "Keep your ankles over your knees. Gently rock side to side or stay still. Relax your lower back toward the floor.",
                "Hold 30 seconds to 1 minute. Breathe.",
            ],
            tips: [
                "Keep your tailbone on the floor; don't lift your hips too high.",
                "If you can't reach your feet, hold your shins or use a strap.",
            ],
            muscles: ["Hips", "Lower back", "Groin", "Hamstrings"],
            targets: ["Flexibility", "Release", "Calm"],
            safetyNote: "Avoid if you have knee or hip issues. Don't force the knees toward the floor.",
            difficultyLevel: .easy,
            easyVariation: "Hold shins; gentle rock.",
            mediumVariation: "Hold feet; 30–60 sec.",
            difficultVariation: "Rock side to side; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Legs Up the Wall",
            equipment: .yogaMat,
            summary: "Lie with your legs vertical against a wall. Restorative pose to drain legs and calm the nervous system.",
            steps: [
                "Sit with one hip close to the wall, then swing your legs up the wall as you lie back. Scoot your hips close to the wall (or a few inches away if more comfortable).",
                "Arms can be out to the sides or on your belly. Close your eyes and breathe. Stay 2–5 minutes or longer.",
                "To come out, bend your knees and roll to one side, then push up to sit.",
            ],
            tips: [
                "Use a cushion under your hips or lower back if you like.",
                "This is a rest pose—do nothing except breathe.",
            ],
            muscles: ["Recovery", "Circulation"],
            targets: ["Recovery", "Relaxation", "Rest"],
            safetyNote: "Avoid if you have eye pressure issues or serious heart conditions. Not recommended in late pregnancy without approval.",
            difficultyLevel: .easy,
            easyVariation: "Legs on a chair instead of wall; 2–3 min.",
            mediumVariation: "Full pose, 3–5 min.",
            difficultVariation: "Add a fold (legs toward chest) or longer rest.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Corpse Pose (Savasana)",
            equipment: .yogaMat,
            summary: "Lie flat on your back, arms and legs relaxed. Final relaxation to integrate practice and rest.",
            steps: [
                "Lie on your back. Let your feet fall out to the sides. Arms rest at your sides, palms up, or on your belly.",
                "Close your eyes. Release tension in your face, jaw, shoulders, and belly. Breathe naturally.",
                "Stay 2–5 minutes (or longer). To exit, wiggle fingers and toes, roll to one side, then sit up slowly.",
            ],
            tips: [
                "Use a blanket under your head or knees if that's more comfortable.",
                "Let the mat support you completely; don't hold any tension.",
            ],
            muscles: ["Rest", "Integration"],
            targets: ["Relaxation", "Recovery", "Mindfulness"],
            safetyNote: "If lying flat is uncomfortable, put a pillow under your knees or use a supported recline.",
            difficultyLevel: .easy,
            easyVariation: "Short 2 min; pillow under knees.",
            mediumVariation: "5 min full Savasana.",
            difficultVariation: "Longer rest; body scan from feet to head.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Upward Dog",
            equipment: .yogaMat,
            summary: "Backbend from the belly with hands under shoulders; chest and thighs lift. Opens the front of the body.",
            steps: [
                "Lie on your belly. Place your hands under your shoulders, elbows close. Tops of feet on the mat.",
                "Press into your hands and lift your chest and thighs off the floor. Keep your legs active; only hands and tops of feet touch the mat.",
                "Draw shoulders back; look forward or slightly up. Hold a few breaths, then lower.",
            ],
            tips: [
                "Don't crunch your lower back—lift from your chest and use your legs.",
                "Keep a slight bend in your elbows if your shoulders feel pinched.",
            ],
            muscles: ["Spine", "Chest", "Shoulders", "Core"],
            targets: ["Flexibility", "Strength"],
            safetyNote: "Avoid if you have back or wrist issues. Use Cobra (hips down) as a gentler option.",
            difficultyLevel: .medium,
            easyVariation: "Cobra instead (hips on floor); or low Upward Dog.",
            mediumVariation: "Full Upward Dog, 3–5 breaths.",
            difficultVariation: "Flow from Upward Dog to Downward Dog.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Mountain Pose",
            equipment: .yogaMat,
            summary: "Standing pose with feet together or hip-width. Foundation for all standing poses; builds awareness and posture.",
            steps: [
                "Stand with feet together or hip-width apart. Distribute weight evenly through both feet.",
                "Lengthen your spine; crown of your head toward the ceiling. Arms at your sides or palms together at your heart.",
                "Hold 1 minute or more. Breathe steadily. Feel grounded and tall.",
            ],
            tips: [
                "Engage your thighs slightly; soften your knees. Draw your belly in a little.",
                "Relax your shoulders away from your ears.",
            ],
            muscles: ["Posture", "Legs", "Core"],
            targets: ["Alignment", "Awareness", "Balance"],
            safetyNote: "None for most people. Adjust stance if you have balance issues.",
            difficultyLevel: .easy,
            easyVariation: "Feet hip-width; 30 sec.",
            mediumVariation: "Feet together, 1 min.",
            difficultVariation: "Eyes closed; longer hold; add arm raises with breath.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Tree Pose",
            equipment: .yogaMat,
            summary: "Balance on one leg with the other foot on calf or thigh. Builds focus and stability.",
            steps: [
                "Stand on one leg. Place the other foot on your inner calf (below the knee) or inner thigh. Avoid placing foot on the knee.",
                "Press your foot and standing leg into each other. Bring your hands to your heart or overhead.",
                "Fix your gaze on a point in front of you. Hold 30 seconds. Switch sides.",
            ],
            tips: [
                "Keep your standing leg strong; don't lock the knee.",
                "Hips stay level; don't let the raised knee drift forward.",
            ],
            muscles: ["Standing leg", "Core", "Hip stabilizers"],
            targets: ["Balance", "Focus", "Stability"],
            safetyNote: "Don't place the foot on the knee—use calf or thigh. Use a wall for support if needed.",
            difficultyLevel: .medium,
            easyVariation: "Foot on calf; hand on wall; short hold.",
            mediumVariation: "Foot on thigh; hands at heart; 30 sec.",
            difficultVariation: "Arms overhead; eyes closed; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Bridge Pose",
            equipment: .yogaMat,
            summary: "Lie on your back, knees bent; lift your hips toward the ceiling. Strengthens glutes and opens the front body.",
            steps: [
                "Lie on your back, knees bent, feet flat and hip-width apart. Arms at your sides.",
                "Press through your feet and lift your hips toward the ceiling. Squeeze your glutes; keep thighs parallel.",
                "Hold 5–10 breaths or pulse 8–10 times. Lower with control.",
            ],
            tips: [
                "Keep your neck long; don't turn your head. Roll your shoulders under if you can.",
                "Press your feet down; don't let your knees splay out.",
            ],
            muscles: ["Glutes", "Hamstrings", "Core", "Back"],
            targets: ["Strength", "Flexibility"],
            safetyNote: "Avoid if you have neck issues. Don't over-arch your lower back.",
            difficultyLevel: .easy,
            easyVariation: "Small lift; short hold.",
            mediumVariation: "Full bridge, 5–10 breaths or 8–10 pulses.",
            difficultVariation: "Single-leg bridge; or walk shoulders under and hold longer.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Reclined Butterfly",
            equipment: .yogaMat,
            summary: "Lie on your back with soles of your feet together and knees falling out. Gentle hip and inner-thigh opener.",
            steps: [
                "Lie on your back. Bring the soles of your feet together and let your knees fall out to the sides. Rest your hands on your belly or out to the sides.",
                "You can place cushions under your knees if they don't reach the floor. Breathe and relax.",
                "Hold 1–2 minutes. Gently draw your feet closer to your hips for a deeper stretch.",
            ],
            tips: [
                "Don't force your knees down; let gravity and breath do the work.",
                "Relax your hips and inner thighs.",
            ],
            muscles: ["Hips", "Inner thighs", "Groin"],
            targets: ["Flexibility", "Relaxation"],
            safetyNote: "Avoid if you have knee or hip issues. Support your knees with blocks or cushions.",
            difficultyLevel: .easy,
            easyVariation: "Feet further from hips; short hold.",
            mediumVariation: "1–2 min hold.",
            difficultVariation: "Feet closer to hips; gentle press on knees; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Figure-Four Stretch",
            equipment: .yogaMat,
            summary: "Lie on your back; cross one ankle over the opposite knee and pull the supporting leg in. Stretches the outer hip and glute.",
            steps: [
                "Lie on your back. Cross one ankle over the opposite knee (figure-four shape).",
                "Thread your hand through the space under the bent leg and clasp your hands behind the supporting thigh (or use a strap).",
                "Draw the supporting leg toward your chest. Feel the stretch in the crossed leg's hip and glute. Hold 30 sec. Switch sides.",
            ],
            tips: [
                "Keep your head and shoulders on the floor. Flex the foot of the crossed leg to protect the knee.",
                "Don't force; ease the leg in as you breathe out.",
            ],
            muscles: ["Glutes", "Hip external rotators", "Piriformis"],
            targets: ["Flexibility", "Hip release"],
            safetyNote: "Protect the crossed knee; don't push it forcefully. Ease off if you feel knee pain.",
            difficultyLevel: .easy,
            easyVariation: "Hands on thigh only; short hold.",
            mediumVariation: "Full hold 30 sec each side.",
            difficultVariation: "Pull leg in closer; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Seated Spinal Twist",
            equipment: .yogaMat,
            summary: "Sit and twist your torso toward one knee. Rotates the spine and massages the abdomen.",
            steps: [
                "Sit with legs extended. Bend one knee and place that foot outside the opposite thigh. Other leg can stay straight or bend.",
                "Hug the bent knee and sit tall. Inhale to lengthen; exhale and twist toward the bent knee. Place opposite elbow outside the knee or hand behind you.",
                "Hold 30 seconds. Breathe into the twist. Repeat on the other side.",
            ],
            tips: [
                "Twist from your belly and chest, not just your neck.",
                "Keep both sitting bones on the floor; lengthen your spine.",
            ],
            muscles: ["Spine", "Core", "Hips"],
            targets: ["Flexibility", "Digestion", "Mobility"],
            safetyNote: "Don't force the twist. Ease off if you have disc issues.",
            difficultyLevel: .easy,
            easyVariation: "Both legs bent; gentle twist.",
            mediumVariation: "Full twist, 30 sec each side.",
            difficultVariation: "Bind (arm behind back); deeper twist; longer hold.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Crescent Lunge",
            equipment: .yogaMat,
            summary: "High lunge with back knee off the floor and arms raised. Stretches the hip flexor and strengthens the legs.",
            steps: [
                "From low lunge or downward dog, step one foot forward. Lift your back knee off the floor. Back foot can be on the ball or flat.",
                "Arms reach overhead, palms facing or hands together. Square your hips forward; tuck your tailbone slightly.",
                "Hold 30 seconds. Feel the stretch in the back leg's hip flexor. Switch sides.",
            ],
            tips: [
                "Keep your front knee over your ankle. Don't let your front knee cave in.",
                "Draw your lower ribs in to avoid overarching your back.",
            ],
            muscles: ["Hip flexors", "Quads", "Glutes", "Core"],
            targets: ["Flexibility", "Strength", "Balance"],
            safetyNote: "Protect your front knee. Ease off if you feel back or knee strain.",
            difficultyLevel: .difficult,
            easyVariation: "Back knee down (low lunge); arms at heart.",
            mediumVariation: "Full crescent, 30 sec each side.",
            difficultVariation: "Back knee up; arms overhead; longer hold; or add a backbend.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Plank (Yoga)",
            equipment: .yogaMat,
            summary: "High plank with shoulders over wrists. Hold to build core and shoulder stability. 30–60 seconds.",
            steps: [
                "From hands and knees, step your feet back so your body forms a straight line from head to heels. Hands under shoulders, fingers spread.",
                "Engage your core; don't let your hips sag or pike up. Draw your belly in and press back through your heels.",
                "Hold 30–60 seconds. Breathe steadily. Lower to your knees or to the floor to rest.",
            ],
            tips: [
                "Keep your neck in line with your spine; look at the floor.",
                "If your wrists hurt, lower to forearms (dolphin plank) or use fists.",
            ],
            muscles: ["Core", "Shoulders", "Arms", "Glutes"],
            targets: ["Strength", "Stability", "Endurance"],
            safetyNote: "Avoid if you have wrist or shoulder issues. Modify to forearms or knees as needed.",
            difficultyLevel: .medium,
            easyVariation: "Plank from knees; 20–30 sec.",
            mediumVariation: "Full plank 30–60 sec.",
            difficultVariation: "Longer hold; alternate leg lift; or side plank.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Glute Bridge",
            equipment: .bodyweight,
            summary: "Lift your hips off the floor from your back. Strengthens glutes and core. Optional: add a band above knees.",
            steps: [
                "Lie on your back, knees bent, feet flat on the floor about hip-width apart.",
                "Drive through your heels and lift your hips until your body forms a straight line from shoulders to knees.",
                "Squeeze your glutes at the top. Hold briefly, then lower with control.",
            ],
            tips: [
                "Keep your chin slightly tucked; don't strain your neck.",
                "Push your knees out slightly to engage glutes more (optional band).",
            ],
            muscles: ["Glutes", "Hamstrings", "Core"],
            targets: ["Strength"],
            safetyNote: "If your lower back feels strained, reduce the height of the lift.",
            difficultyLevel: .easy,
            easyVariation: "Short hold at top; march feet in for less range.",
            mediumVariation: "Full bridge, 2-second hold at top.",
            difficultVariation: "Single-leg bridge or band above knees.",
            imagePlaceholderName: "GluteBridge"
        ),
        ExerciseDetail(
            exerciseName: "Calf Raises",
            equipment: .bodyweight,
            summary: "Rise onto your toes to work your calves. Can be done on the floor or on a step for more range.",
            steps: [
                "Stand with feet hip-width apart. You can hold a wall or chair for balance.",
                "Rise onto the balls of your feet, lifting your heels as high as you can.",
                "Hold briefly at the top, then lower with control.",
            ],
            tips: [
                "Keep your knees slightly bent if needed; focus on the calf squeeze.",
                "For more range, stand on a step and let your heels drop below the step.",
            ],
            muscles: ["Calves"],
            targets: ["Strength", "Balance"],
            safetyNote: "Hold something for balance if needed. Don't bounce at the bottom.",
            difficultyLevel: .easy,
            easyVariation: "Both feet, holding support.",
            mediumVariation: "Both feet, no support, or on a step.",
            difficultVariation: "Single-leg calf raises or weighted.",
            imagePlaceholderName: "CalfRaises"
        ),
        ExerciseDetail(
            exerciseName: "Treadmill Walk/Jog",
            equipment: .treadmill,
            summary: "Walk or jog on the treadmill. Warm up with a walk, then increase pace as comfortable.",
            steps: [
                "Start with a 5-minute walk at an easy pace to warm up.",
                "Gradually increase speed to a brisk walk or light jog. Stay at a pace where you can talk in short sentences.",
                "Continue for 15–25 minutes. Cool down with 3–5 minutes of slower walking.",
            ],
            tips: [
                "Use a slight incline (1–2%) to mimic outdoor walking.",
                "Stay hydrated and use the handrails only for balance if needed.",
            ],
            muscles: ["Legs", "Cardiovascular"],
            targets: ["Cardio", "Endurance"],
            safetyNote: "Know how to use the emergency stop. Start at low speed.",
            difficultyLevel: .easy,
            easyVariation: "Walking only, flat, 15–20 min.",
            mediumVariation: "Walk/jog intervals or steady jog.",
            difficultVariation: "Hill intervals or longer duration.",
            imagePlaceholderName: "TreadmillWalkJog"
        ),
        ExerciseDetail(
            exerciseName: "Exercise Bike",
            equipment: .exerciseBike,
            summary: "Cycle on a stationary bike. Low-impact cardio for heart health and leg endurance.",
            steps: [
                "Adjust the seat so your knee is slightly bent at the bottom of the pedal stroke.",
                "Start pedaling at an easy pace for 3–5 minutes to warm up.",
                "Increase resistance or speed as desired. Maintain a steady rhythm for 15–20 minutes.",
                "Cool down with 3–5 minutes of easy pedaling.",
            ],
            tips: [
                "Keep your core engaged; don't slump.",
                "Vary resistance and cadence for interval options.",
            ],
            muscles: ["Quads", "Calves", "Cardiovascular"],
            targets: ["Cardio", "Endurance"],
            safetyNote: "Ensure the bike is set up correctly. Stop if you feel knee or back pain.",
            difficultyLevel: .easy,
            easyVariation: "Light resistance, 15 min.",
            mediumVariation: "Moderate resistance, 20 min or intervals.",
            difficultVariation: "HIIT intervals or longer steady ride.",
            imagePlaceholderName: "ExerciseBike"
        ),
        ExerciseDetail(
            exerciseName: "Superman",
            equipment: .bodyweight,
            summary: "Lie face down and lift arms and legs off the floor. Strengthens lower back and glutes.",
            steps: [
                "Lie face down on the floor with arms extended in front and legs straight.",
                "Lift your arms, chest, and legs off the floor at the same time. Keep your gaze down.",
                "Hold for 2–3 seconds at the top, squeezing your lower back and glutes.",
                "Lower with control and repeat.",
            ],
            tips: [
                "Keep the movement controlled; don't swing or use momentum.",
                "Lengthen through your spine rather than crunching your neck.",
            ],
            muscles: ["Lower back", "Glutes", "Rear deltoids"],
            targets: ["Strength", "Stability"],
            safetyNote: "If you have lower back issues, do a smaller range or skip this exercise.",
            difficultyLevel: .easy,
            easyVariation: "Lift arms only, or legs only, alternating.",
            mediumVariation: "Full Superman hold 2 sec.",
            difficultVariation: "Hold longer or add pulses at the top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Dead Bug",
            equipment: .bodyweight,
            summary: "On your back, extend opposite arm and leg while keeping your low back pressed down. Builds core stability.",
            steps: [
                "Lie on your back. Press your lower back into the floor. Lift knees to 90° and arms toward the ceiling.",
                "Extend your right arm overhead and left leg toward the floor. Keep your back flat.",
                "Return to the start and repeat with the left arm and right leg.",
                "Move slowly and with control.",
            ],
            tips: [
                "Exhale as you extend; keep your ribs down.",
                "If your back arches, shorten the range or keep the moving leg bent.",
            ],
            muscles: ["Core", "Transverse abdominis"],
            targets: ["Stability", "Strength"],
            safetyNote: "Keep your lower back pressed to the floor. Stop if you feel back strain.",
            difficultyLevel: .medium,
            easyVariation: "Bent legs, or arms only / legs only.",
            mediumVariation: "Full dead bug, slow tempo.",
            difficultVariation: "Straight legs, longer hold at extension.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Bird Dog",
            equipment: .bodyweight,
            summary: "On all fours, extend one arm and the opposite leg. Improves balance and core stability.",
            steps: [
                "Start on hands and knees, wrists under shoulders, knees under hips.",
                "Extend your right arm forward and left leg back. Keep your back flat and core tight.",
                "Hold for 2 seconds, then return to the start.",
                "Repeat with the left arm and right leg.",
            ],
            tips: [
                "Keep your hips level; don't let them rotate.",
                "Look at the floor to keep your neck neutral.",
            ],
            muscles: ["Core", "Lower back", "Glutes"],
            targets: ["Stability", "Balance"],
            safetyNote: "Move slowly. If your back rounds or sags, shorten the arm/leg reach.",
            difficultyLevel: .easy,
            easyVariation: "Touch knee to elbow under body instead of full extension.",
            mediumVariation: "Full extension, 2-second hold.",
            difficultVariation: "Add a pause or pulse at full extension.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Push-ups (or knee push-ups)",
            equipment: .bodyweight,
            summary: "Classic push-up from the floor. Strengthens chest, shoulders, and triceps. Use knees for an easier option.",
            steps: [
                "Start in a plank: hands under shoulders, body in a straight line. (Easier: on your knees.)",
                "Lower your chest toward the floor by bending your elbows. Keep your core tight.",
                "Push back up to the start. Don't let your hips sag or pike up.",
                "Repeat for the desired reps.",
            ],
            tips: [
                "Keep your elbows at about 45° from your body, not flared out.",
                "On knees: keep a straight line from head to knees.",
            ],
            muscles: ["Chest", "Triceps", "Shoulders", "Core"],
            targets: ["Strength"],
            safetyNote: "If your wrists hurt, try fists or push-up handles. Build up from knee push-ups.",
            difficultyLevel: .medium,
            easyVariation: "Knee push-ups, or hands on a raised surface.",
            mediumVariation: "Full push-ups from toes.",
            difficultVariation: "Slower tempo, deficit push-ups, or add a hold at the bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Squats",
            equipment: .bodyweight,
            summary: "Bodyweight squat. Builds leg and glute strength with no equipment.",
            steps: [
                "Stand with feet shoulder-width apart, toes slightly turned out.",
                "Push your hips back and bend your knees to lower into a squat. Keep your chest up.",
                "Go as low as you can while keeping your heels down and back straight.",
                "Drive through your heels to stand back up.",
            ],
            tips: [
                "Push your knees out in line with your toes.",
                "Keep your weight in your heels; don't let your knees cave in.",
            ],
            muscles: ["Quads", "Glutes", "Core"],
            targets: ["Strength"],
            safetyNote: "Avoid rounding your lower back. Reduce depth if you feel knee discomfort.",
            difficultyLevel: .easy,
            easyVariation: "Squat to a chair and stand back up.",
            mediumVariation: "Bodyweight squats, full range.",
            difficultVariation: "Pause at bottom, or add a jump (jump squats).",
            imagePlaceholderName: nil
        ),
        // Volleyball profile exercises
        ExerciseDetail(
            exerciseName: "Skater Jumps",
            equipment: .bodyweight,
            summary: "Jump side to side like a speed skater. Builds lateral power and balance for volleyball court movement.",
            steps: [
                "Stand on one leg with a slight bend in the knee.",
                "Jump sideways to the other foot, landing softly with a slight squat.",
                "Swing your arms in the direction of the jump for balance and power.",
                "Immediately jump back to the other side. Repeat.",
            ],
            tips: [
                "Land on the ball of your foot with a soft knee bend.",
                "Keep your chest up and core tight.",
            ],
            muscles: ["Quads", "Glutes", "Calves", "Hip stabilizers"],
            targets: ["Power", "Balance", "Agility"],
            safetyNote: "Land softly to protect knees and ankles. Use a non-slip surface.",
            difficultyLevel: .medium,
            easyVariation: "Step side to side instead of jumping, or small hops.",
            mediumVariation: "Skater jumps with moderate distance.",
            difficultVariation: "Wider jumps, minimal rest, or add a slight pause at the bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Wall Sits",
            equipment: .bodyweight,
            summary: "Hold a seated position against a wall. Builds quad and glute endurance for blocking and ready position.",
            steps: [
                "Stand with your back against a wall, feet shoulder-width apart.",
                "Slide down until your knees are at about 90° and your thighs are parallel to the floor.",
                "Keep your back flat against the wall. Hold the position.",
                "Stand back up when done.",
            ],
            tips: [
                "Don’t let your knees go past your toes.",
                "Breathe steadily; don’t hold your breath.",
            ],
            muscles: ["Quads", "Glutes"],
            targets: ["Strength", "Endurance"],
            safetyNote: "Stop if you feel sharp knee pain. Reduce depth if needed.",
            difficultyLevel: .easy,
            easyVariation: "Higher position (less bend in knees) or shorter hold.",
            mediumVariation: "90° hold for 30–45 seconds.",
            difficultVariation: "Longer hold, or add a small ball between knees.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Lateral Shuffles",
            equipment: .bodyweight,
            summary: "Quick side-to-side shuffling. Improves foot speed and agility for court coverage.",
            steps: [
                "Stay low in an athletic stance, knees slightly bent.",
                "Shuffle quickly to one side, leading with the same-side foot.",
                "Keep your feet from crossing; stay on the balls of your feet.",
                "Shuffle back the other way. Stay low throughout.",
            ],
            tips: [
                "Stay low and quick; imagine covering the court.",
                "Keep your chest up and eyes forward.",
            ],
            muscles: ["Quads", "Calves", "Hip abductors"],
            targets: ["Agility", "Speed", "Coordination"],
            safetyNote: "Use a clear, non-slip space. Avoid crossing feet to prevent tripping.",
            difficultyLevel: .easy,
            easyVariation: "Slower shuffles or shorter duration.",
            mediumVariation: "Quick shuffles for 20–30 seconds.",
            difficultVariation: "Add a touch or cone at each side; minimal rest.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Single-Leg Hops",
            equipment: .bodyweight,
            summary: "Hop on one leg for distance or in place. Builds single-leg power and balance for jumping and landing.",
            steps: [
                "Stand on one leg with a slight bend in the knee.",
                "Hop forward (or in place), landing on the same foot.",
                "Land softly with a bent knee. Stay balanced.",
                "Complete reps then switch legs.",
            ],
            tips: [
                "Land quietly and with control.",
                "Use your arms for balance and drive.",
            ],
            muscles: ["Quads", "Glutes", "Calves"],
            targets: ["Power", "Balance", "Stability"],
            safetyNote: "Land softly to protect knees and ankles. Start with small hops.",
            difficultyLevel: .medium,
            easyVariation: "Small hops in place or hold a wall for balance.",
            mediumVariation: "Forward hops or hops in place for time.",
            difficultVariation: "Lateral single-leg hops or longer distance.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Mountain Climbers",
            equipment: .bodyweight,
            summary: "Drive knees to chest from a high plank. Builds core and cardio for quick reactions on the court.",
            steps: [
                "Start in a high plank: hands under shoulders, body in a straight line.",
                "Drive one knee toward your chest, then quickly switch and drive the other knee in.",
                "Keep your hips level; don’t let them bounce up and down.",
                "Alternate at a pace you can sustain.",
            ],
            tips: [
                "Keep your core tight and shoulders over wrists.",
                "Start slower to master form, then speed up.",
            ],
            muscles: ["Core", "Hip flexors", "Shoulders"],
            targets: ["Strength", "Cardio", "Coordination"],
            safetyNote: "Stop if you feel wrist or lower-back pain. Reduce speed or range.",
            difficultyLevel: .medium,
            easyVariation: "Slow mountain climbers or from hands on a raised surface.",
            mediumVariation: "Steady pace for 20–30 seconds.",
            difficultVariation: "Faster pace or bring knees toward opposite elbow.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Tricep Dips (chair)",
            equipment: .bodyweight,
            summary: "Lower and push up with hands on a chair. Strengthens triceps and shoulders for serving and hitting.",
            steps: [
                "Sit on the edge of a sturdy chair. Place hands next to your hips, fingers forward.",
                "Slide off the chair so your body is supported by your hands and feet (legs bent or extended).",
                "Bend your elbows to lower your body until upper arms are about parallel to the floor.",
                "Push back up until your arms are straight (don’t lock elbows).",
            ],
            tips: [
                "Keep your shoulders down; don’t shrug.",
                "Control the movement—don’t drop into the bottom.",
            ],
            muscles: ["Triceps", "Shoulders", "Chest"],
            targets: ["Strength"],
            safetyNote: "Use a stable chair. Stop if you feel shoulder or wrist pain.",
            difficultyLevel: .medium,
            easyVariation: "Feet closer to the chair or knees bent for less load.",
            mediumVariation: "Feet out, knees bent; full range.",
            difficultVariation: "Legs extended, or feet on another surface to elevate.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Box Step-Ups (or stairs)",
            equipment: .bodyweight,
            summary: "Step up onto a box or stair, driving through the standing leg. Builds single-leg power for jumping and landing.",
            steps: [
                "Stand in front of a sturdy box or bottom step.",
                "Place one foot fully on the box. Drive through that heel to step up.",
                "Bring the other foot up to meet the first. Stand tall on top.",
                "Step down with control, one foot at a time. Repeat, leading with the same leg then switch.",
            ],
            tips: [
                "Push through the heel of the foot on the box, not the back foot.",
                "Keep your chest up and avoid leaning forward.",
            ],
            muscles: ["Quads", "Glutes", "Calves"],
            targets: ["Strength", "Power", "Balance"],
            safetyNote: "Use a stable surface. Ensure the box or step won’t slip.",
            difficultyLevel: .easy,
            easyVariation: "Lower step or staircase; slow and controlled.",
            mediumVariation: "Knee-height box or 2–3 stairs; steady pace.",
            difficultVariation: "Higher box, or add a small jump at the top.",
            imagePlaceholderName: nil
        ),
        // Bodyweight – Easy (10)
        ExerciseDetail(exerciseName: "March in Place", equipment: .bodyweight, summary: "March with high knees and pump your arms. Gentle warm-up or light cardio.", steps: ["Stand tall; lift one knee at a time as if marching. Pump your arms in opposition.", "Keep a steady pace for 60 seconds. Breathe normally.", "You can march in place or travel slowly forward."], tips: ["Keep your core engaged; don't lean back.", "Use for warm-up before harder exercises."], muscles: ["Legs", "Core", "Cardiovascular"], targets: ["Warm-up", "Cardio"], safetyNote: "Low impact. Stop if you feel dizzy.", difficultyLevel: .easy, easyVariation: "Slow march, low knees.", mediumVariation: "Higher knees, 60 sec.", difficultVariation: "Add arm circles or longer duration.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Heel Raises (Seated)", equipment: .bodyweight, summary: "Sit on a chair and raise your heels off the floor. Strengthens calves and ankles.", steps: ["Sit on a chair, feet flat. Lift both heels so you're on the balls of your feet.", "Squeeze your calves at the top. Lower with control.", "Repeat 15 times. Keep knees over toes."], tips: ["Press through the balls of your feet.", "Add a hold at the top for more burn."], muscles: ["Calves", "Ankles"], targets: ["Strength", "Balance"], safetyNote: "None for most people. Use chair for balance if needed.", difficultyLevel: .easy, easyVariation: "Both feet, 10 reps.", mediumVariation: "15 reps, hold at top.", difficultVariation: "Single leg or add weight on knees.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Arm Circles", equipment: .bodyweight, summary: "Circle your arms forward and back to warm up the shoulders and improve mobility.", steps: ["Stand with arms out to the sides at shoulder height.", "Make small circles forward 10 times, then small circles backward 10 times.", "Repeat with larger circles. Keep shoulders relaxed."], tips: ["Start small; increase size as you warm up.", "Don't shrug your shoulders up."], muscles: ["Shoulders", "Upper back"], targets: ["Mobility", "Warm-up"], safetyNote: "Stop if you feel shoulder pinch or pain.", difficultyLevel: .easy, easyVariation: "Small circles only.", mediumVariation: "Small then large, both directions.", difficultVariation: "Add resistance band or longer duration.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Lying Leg Raise", equipment: .bodyweight, summary: "Lie on your back and raise your legs toward the ceiling. Works lower abs and hip flexors.", steps: ["Lie on your back, legs extended. Place hands under your lower back or at your sides.", "Keeping legs as straight as you can, raise them toward the ceiling.", "Lower with control; don't let legs drop. Repeat 10 times."], tips: ["Press your lower back into the floor.", "Bend knees slightly if your back arches."], muscles: ["Lower abs", "Hip flexors"], targets: ["Strength", "Core"], safetyNote: "Don't swing your legs; use control. Ease off if your back hurts.", difficultyLevel: .easy, easyVariation: "Bent knees; lower range.", mediumVariation: "Straight legs, 10 reps.", difficultVariation: "Add a pause at the top or scissors.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Toe Taps", equipment: .bodyweight, summary: "Stand and tap one foot forward and to the side in a pattern. Light balance and coordination.", steps: ["Stand on one leg (hold a wall or chair if needed). Tap the other foot forward.", "Tap the same foot to the side, then back to center. Repeat 20 times.", "Switch standing leg and repeat."], tips: ["Keep your standing leg slightly bent.", "Stay on the ball of your standing foot for balance."], muscles: ["Legs", "Core", "Balance"], targets: ["Balance", "Coordination"], safetyNote: "Use support if balance is an issue.", difficultyLevel: .easy, easyVariation: "Hold wall; slow taps.", mediumVariation: "Minimal support, 20 each.", difficultVariation: "No support; add speed.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Shoulder Rolls", equipment: .bodyweight, summary: "Roll your shoulders backward and forward to release tension and improve mobility.", steps: ["Stand or sit tall. Lift your shoulders up toward your ears.", "Roll them back and down. Repeat 10 times.", "Then roll them forward 10 times."], tips: ["Move slowly and breathe.", "Keep your neck relaxed."], muscles: ["Upper traps", "Shoulders"], targets: ["Mobility", "Recovery"], safetyNote: "None. Ease off if you feel pain.", difficultyLevel: .easy, easyVariation: "5 each direction.", mediumVariation: "10 each direction.", difficultVariation: "Add arm circles after rolls.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Standing Hip Abduction", equipment: .bodyweight, summary: "Stand on one leg and lift the other leg out to the side. Strengthens hip abductors and balance.", steps: ["Stand tall; hold a wall or chair for balance. Shift weight onto one leg.", "Lift the other leg out to the side, keeping it straight. Don't lean your torso.", "Lower with control. Complete 12 reps then switch legs."], tips: ["Keep your standing leg slightly bent.", "Lift from the hip; don't kick."], muscles: ["Hip abductors", "Gluteus medius"], targets: ["Strength", "Balance"], safetyNote: "Use support if needed. Don't hold your breath.", difficultyLevel: .easy, easyVariation: "Hold wall; 8 each leg.", mediumVariation: "12 each, light support.", difficultVariation: "No support; add hold at top.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Wall Push-Up", equipment: .bodyweight, summary: "Push-ups with your hands on a wall. Easier than floor push-ups; builds pushing strength.", steps: ["Stand arm's length from a wall. Place hands on the wall at shoulder height.", "Bend your elbows and lower your chest toward the wall. Keep your body in a straight line.", "Push back to the start. Repeat 12 times."], tips: ["The farther your feet from the wall, the harder.", "Keep your core tight."], muscles: ["Chest", "Triceps", "Shoulders"], targets: ["Strength"], safetyNote: "None. Great for beginners or shoulder rehab.", difficultyLevel: .easy, easyVariation: "Feet close to wall.", mediumVariation: "Feet at arm's length.", difficultVariation: "Feet further back or one-arm assist.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Chair Squat", equipment: .bodyweight, summary: "Squat to tap a chair seat and stand. Builds confidence in the squat pattern with a safety target.", steps: ["Stand in front of a chair, feet shoulder-width apart.", "Push your hips back and bend your knees; lower until you tap the chair seat.", "Drive through your heels to stand. Don't plop onto the chair. Repeat 10 times."], tips: ["Keep your chest up; look forward.", "The chair is a guide—touch and go."], muscles: ["Quads", "Glutes", "Core"], targets: ["Strength", "Movement pattern"], safetyNote: "Use a stable chair. Sit fully if you need to rest.", difficultyLevel: .easy, easyVariation: "Higher chair; partial squat.", mediumVariation: "Standard chair, full tap.", difficultVariation: "Lower seat or pause at bottom.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Standing Y Raise", equipment: .bodyweight, summary: "Raise your arms in a Y shape in front of you. Targets lower traps and shoulder health.", steps: ["Stand with feet hip-width. Arms down, thumbs forward.", "Raise both arms up and out in a Y (about 30° in front of you) to eye level.", "Lower with control. Repeat 12 times."], tips: ["Don't shrug; lead with your thumbs.", "Use a light range if you feel pinch."], muscles: ["Lower traps", "Rear deltoids", "Serratus"], targets: ["Strength", "Posture"], safetyNote: "Stop if you feel shoulder impingement.", difficultyLevel: .easy, easyVariation: "Small Y; 8 reps.", mediumVariation: "Full Y to eyes, 12 reps.", difficultVariation: "Hold at top 2 sec; add reps.", imagePlaceholderName: nil),
        // Bodyweight – Medium (10)
        ExerciseDetail(exerciseName: "Bodyweight Lunge", equipment: .bodyweight, summary: "Step forward into a lunge; lower your back knee. Builds leg strength and balance.", steps: ["Stand with feet hip-width. Step one foot forward; lower your back knee toward the floor.", "Both knees about 90°. Keep your front knee over your ankle.", "Push through your front heel to return. Alternate or complete one side first. 10 each."], tips: ["Keep your torso upright.", "Take a long enough step so the front knee doesn't pass your toes."], muscles: ["Quads", "Glutes", "Hamstrings"], targets: ["Strength", "Balance"], safetyNote: "Use a clear space. Modify to reverse lunge if needed.", difficultyLevel: .medium, easyVariation: "Hold wall; shorter lunge.", mediumVariation: "Full lunge, 10 each.", difficultVariation: "Walking lunges or add pulse at bottom.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Reverse Lunge", equipment: .bodyweight, summary: "Step one foot back and lower into a lunge. Return to stand. Easier on the knees than forward lunge.", steps: ["Stand tall. Step one foot back and lower your back knee toward the floor.", "Front knee stays over ankle. Keep your torso upright.", "Push through your front foot to return to standing. 10 reps each leg."], tips: ["Don't let your front knee cave in.", "Use your back leg for balance, not push."], muscles: ["Quads", "Glutes", "Hamstrings"], targets: ["Strength", "Balance"], safetyNote: "Clear space behind you. Pad back knee if needed.", difficultyLevel: .medium, easyVariation: "Shorter step; hold support.", mediumVariation: "Full reverse lunge, 10 each.", difficultVariation: "Add a knee drive at the top.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Incline Push-Up", equipment: .bodyweight, summary: "Push-ups with hands on a bench or step. Easier than floor; builds chest and triceps.", steps: ["Place your hands on a sturdy bench or step. Walk your feet back so your body is straight.", "Lower your chest toward the bench; keep your core tight.", "Push back up. Repeat 10–12 times."], tips: ["The higher the surface, the easier.", "Keep your hips in line with your shoulders and heels."], muscles: ["Chest", "Triceps", "Shoulders"], targets: ["Strength"], safetyNote: "Use a stable surface. Wrists under shoulders.", difficultyLevel: .medium, easyVariation: "Higher incline (e.g. wall).", mediumVariation: "Bench or 2–3 steps.", difficultVariation: "Lower step or floor push-up.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Side Plank", equipment: .bodyweight, summary: "Support your body on one forearm and the side of your foot. Holds core and obliques.", steps: ["Lie on your side. Prop up on your forearm; stack your feet or stagger them.", "Lift your hips so your body forms a straight line. Don't let your hips sag.", "Hold 20–30 seconds. Repeat on the other side."], tips: ["Engage your core and squeeze your glutes.", "Look forward or up to protect your neck."], muscles: ["Obliques", "Core", "Shoulders"], targets: ["Strength", "Stability"], safetyNote: "Drop to your knee if your shoulder or wrist hurts.", difficultyLevel: .medium, easyVariation: "Bottom knee down.", mediumVariation: "Full side plank 20–30 sec.", difficultVariation: "Lift top leg; longer hold.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Single-Leg Glute Bridge", equipment: .bodyweight, summary: "One foot on the floor; lift your hips. Other leg extended or bent. Glute and hamstring focus.", steps: ["Lie on your back, knees bent. Extend one leg or keep it bent with foot off the floor.", "Drive through the foot on the floor and lift your hips. Squeeze your glute.", "Lower with control. 10 reps each leg."], tips: ["Keep your hips level; don't let them rotate.", "Press through the heel of the working leg."], muscles: ["Glutes", "Hamstrings", "Core"], targets: ["Strength"], safetyNote: "Don't over-arch your lower back.", difficultyLevel: .medium, easyVariation: "Both feet; single leg for few reps.", mediumVariation: "10 each leg, full range.", difficultVariation: "Hold at top; pulse; or extended leg straight up.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Bicycle Crunch", equipment: .bodyweight, summary: "On your back, pedal your legs while bringing opposite elbow to knee. Core and obliques.", steps: ["Lie on your back, hands behind your head. Lift your shoulders and legs off the floor.", "Bring one knee in and twist to touch it with the opposite elbow. Extend the other leg.", "Alternate in a pedaling motion. 20 total (10 each side)."], tips: ["Don't pull on your neck. Use your abs to curl.", "Keep your lower back pressed down."], muscles: ["Abs", "Obliques"], targets: ["Strength", "Core"], safetyNote: "Stop if your neck hurts. Keep the movement controlled.", difficultyLevel: .medium, easyVariation: "Slower pace; fewer reps.", mediumVariation: "20 total, steady pace.", difficultVariation: "Faster pace; 30 total; or add a hold.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "High Knees", equipment: .bodyweight, summary: "Run in place, driving your knees up quickly. Cardio and leg drive.", steps: ["Stand with feet hip-width. Run in place, driving your knees up toward your chest.", "Pump your arms. Stay on the balls of your feet.", "Go for 30 seconds. Rest 30 seconds; repeat 3 times."], tips: ["Keep your core tight; don't lean back.", "Land softly."], muscles: ["Legs", "Core", "Cardiovascular"], targets: ["Cardio", "Power"], safetyNote: "Use a soft surface if needed. Stop if you feel knee pain.", difficultyLevel: .medium, easyVariation: "March with high knees.", mediumVariation: "30 sec on, 30 sec rest x 3.", difficultVariation: "Faster pace or longer intervals.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Butt Kicks", equipment: .bodyweight, summary: "Run in place, kicking your heels up toward your glutes. Hamstrings and cardio.", steps: ["Stand and run in place. Kick your heels up toward your glutes with each step.", "Keep a quick pace. Pump your arms.", "Continue for 30 seconds. Rest and repeat."], tips: ["Stay on the balls of your feet.", "Keep your knees under your hips."], muscles: ["Hamstrings", "Calves", "Cardiovascular"], targets: ["Cardio", "Warm-up"], safetyNote: "Low impact. Ease off if you feel hamstring strain.", difficultyLevel: .medium, easyVariation: "Slower pace.", mediumVariation: "30 sec x 3 sets.", difficultVariation: "Faster or longer duration.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Jumping Jacks", equipment: .bodyweight, summary: "Jump feet out while arms go up; return. Classic full-body cardio.", steps: ["Stand with feet together, arms at your sides. Jump and spread your feet while raising your arms overhead.", "Jump back to the start position. Stay rhythmic.", "Do 20–30 reps or 30–60 seconds. Rest 30 sec; repeat."], tips: ["Land with soft knees; don't lock them.", "Breathe steadily."], muscles: ["Legs", "Shoulders", "Core", "Cardiovascular"], targets: ["Cardio", "Warm-up"], safetyNote: "Reduce impact by stepping instead of jumping if needed.", difficultyLevel: .medium, easyVariation: "Step jacks (no jump).", mediumVariation: "20–30 jacks, 3 sets.", difficultVariation: "Faster or add a squat at the bottom.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Bear Crawl", equipment: .bodyweight, summary: "On hands and feet with knees off the floor; crawl forward and back. Core and shoulders.", steps: ["Start on all fours; lift your knees an inch off the floor. Keep your back flat.", "Crawl forward by moving opposite hand and foot. Stay low.", "Crawl for 30 seconds forward, then 30 seconds back. Or do a set distance."], tips: ["Keep your core tight; don't let your hips sag or pike.", "Move with control."], muscles: ["Core", "Shoulders", "Legs"], targets: ["Strength", "Stability", "Conditioning"], safetyNote: "Go slow if your wrists hurt. Use fists or rest as needed.", difficultyLevel: .medium, easyVariation: "Knees can tap floor; short distance.", mediumVariation: "Knees off floor, 30 sec each way.", difficultVariation: "Faster crawl or add a push-up every 4 steps.", imagePlaceholderName: nil),
        // Bodyweight – Difficult (10)
        ExerciseDetail(exerciseName: "Burpee", equipment: .bodyweight, summary: "Squat, jump feet back to plank, (optional push-up), jump feet in, jump up. Full-body conditioning.", steps: ["From standing, squat and place your hands on the floor. Jump your feet back to a plank.", "Optional: do a push-up. Jump your feet back to your hands.", "Jump up with arms overhead. That's one rep. Do 6–10; rest 45 sec."], tips: ["Land softly from the jump. Keep your core tight in the plank.", "Scale by stepping instead of jumping."], muscles: ["Full body", "Cardiovascular"], targets: ["Conditioning", "Power"], safetyNote: "High impact. Scale to no jump or step-back if needed.", difficultyLevel: .difficult, easyVariation: "Step back and in; no push-up.", mediumVariation: "Full burpee, no push-up.", difficultVariation: "Burpee with push-up and jump; add a tuck jump.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Pike Push-Up", equipment: .bodyweight, summary: "Hips high, hands and feet on the floor; lower your head toward the floor and push back. Shoulder focus.", steps: ["Start in a pike: hands and feet on the floor, hips high, legs as straight as you can.", "Bend your elbows and lower the top of your head toward the floor between your hands.", "Push back up. Repeat 8–10 times."], tips: ["Keep your hips high throughout.", "This targets shoulders more than chest."], muscles: ["Shoulders", "Triceps", "Core"], targets: ["Strength"], safetyNote: "Don't collapse into your lower back. Ease off if your shoulders pinch.", difficultyLevel: .difficult, easyVariation: "Hands on a box; pike from there.", mediumVariation: "Floor pike push-up, 8–10.", difficultVariation: "Feet on step for more load; or add a hold.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Decline Push-Up", equipment: .bodyweight, summary: "Feet on a step or bench, hands on the floor. Harder than flat push-up; more upper chest and shoulders.", steps: ["Place your feet on a step or bench. Hands on the floor, slightly wider than shoulders.", "Lower your chest toward the floor; keep your body in a straight line.", "Push back up. Do 8–10 reps."], tips: ["The higher your feet, the harder. Start low.", "Keep your core braced."], muscles: ["Chest", "Shoulders", "Triceps"], targets: ["Strength"], safetyNote: "Use a stable surface. Wrists under shoulders.", difficultyLevel: .difficult, easyVariation: "Low step; 6–8 reps.", mediumVariation: "Bench or 2 steps; 8–10.", difficultVariation: "Higher elevation or deficit hand position.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Single-Leg Deadlift", equipment: .bodyweight, summary: "Balance on one leg; hinge and reach toward the floor. Hamstrings, glutes, and balance.", steps: ["Stand on one leg, soft bend in the knee. Hold your arms out or at your sides.", "Hinge at your hip and reach toward the floor. Your free leg goes back for balance.", "Return to standing. Keep your back flat. 8 reps each leg."], tips: ["Think of closing a door with your hip. Don't round your back.", "Use a wall or chair for balance at first."], muscles: ["Hamstrings", "Glutes", "Core", "Balance"], targets: ["Strength", "Balance"], safetyNote: "Don't round your lower back. Use support if balance is poor.", difficultyLevel: .difficult, easyVariation: "Light touch on wall; 6 each.", mediumVariation: "8 each, minimal support.", difficultVariation: "No support; add a hold at the bottom.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Hand-Release Push-Up", equipment: .bodyweight, summary: "Lower to the floor, lift your hands briefly, then push back up. Ensures full range and no cheating.", steps: ["Start in a plank. Lower your chest and thighs to the floor.", "Lift both hands an inch off the floor. Place them back.", "Push back up to plank. That's one rep. Do 6–10."], tips: ["Keep your body in one line; don't sag or pike.", "Full chest contact with the floor."], muscles: ["Chest", "Triceps", "Shoulders", "Core"], targets: ["Strength", "Range of motion"], safetyNote: "Control the descent. Don't flop down.", difficultyLevel: .difficult, easyVariation: "From knees; 6–8.", mediumVariation: "Full from toes, 6–10.", difficultVariation: "Add a clap or pause at the bottom.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Spiderman Push-Up", equipment: .bodyweight, summary: "Push-up while bringing one knee to the same-side elbow. Core and chest.", steps: ["Start in a push-up position. As you lower, bring one knee toward your same-side elbow.", "Push back up and return the leg. Repeat on the other side.", "That's one rep per side. Do 8 each side."], tips: ["Keep your hips level; don't rotate.", "Control the knee drive."], muscles: ["Chest", "Triceps", "Core", "Hip flexors"], targets: ["Strength", "Mobility"], safetyNote: "Don't rush. Keep a controlled push-up.", difficultyLevel: .difficult, easyVariation: "Incline Spiderman; 6 each.", mediumVariation: "Floor, 8 each.", difficultVariation: "Add a pause or touch knee to elbow.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Tuck Jump", equipment: .bodyweight, summary: "Jump and tuck your knees toward your chest. Power and leg drive; land softly.", steps: ["Stand with feet hip-width. Swing your arms and jump as high as you can.", "At the top, tuck your knees toward your chest. Land softly with bent knees.", "Do 6–8 reps. Rest 45 seconds between sets."], tips: ["Land on the balls of your feet; absorb with your legs.", "Use your arms to help you jump."], muscles: ["Legs", "Core", "Power"], targets: ["Power", "Plyometrics"], safetyNote: "Land softly. Use a soft surface. Skip if you have knee or ankle issues.", difficultyLevel: .difficult, easyVariation: "Small tuck; low jump.", mediumVariation: "6–8 tuck jumps.", difficultVariation: "Higher tuck; add a pause in the air.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Long-Lever Plank", equipment: .bodyweight, summary: "Plank with your hands further forward than your shoulders. Harder on the core.", steps: ["Start in a high plank. Walk your hands forward so they're 6–12 inches in front of your shoulders.", "Keep your body in a straight line. Don't let your hips sag or pike.", "Hold 30–45 seconds. Rest and repeat."], tips: ["The further your hands, the harder. Start small.", "Squeeze your quads and glutes."], muscles: ["Core", "Shoulders", "Quads"], targets: ["Strength", "Stability"], safetyNote: "Don't hold past form breakdown. Drop to knees if needed.", difficultyLevel: .difficult, easyVariation: "Hands slightly forward; 20 sec.", mediumVariation: "30–45 sec long-lever hold.", difficultVariation: "Hands further forward; 45–60 sec.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Hollow Hold", equipment: .bodyweight, summary: "On your back, lift your head, shoulders, and legs off the floor. Arms by sides or overhead. Core strength.", steps: ["Lie on your back. Press your lower back into the floor. Lift your head, shoulders, and legs off the floor.", "Arms can be by your sides or overhead. Hold a banana shape.", "Hold 20–30 seconds. Rest and repeat 3 times."], tips: ["Keep your lower back pressed down. Breathe.", "Start with bent knees if straight legs are too hard."], muscles: ["Abs", "Core", "Hip flexors"], targets: ["Strength", "Core"], safetyNote: "Don't strain your neck. Ease off if your back arches.", difficultyLevel: .difficult, easyVariation: "Bent knees; short hold.", mediumVariation: "Straight legs, 20–30 sec.", difficultVariation: "Arms overhead; rock (hollow rock); longer hold.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Jump Lunge", equipment: .bodyweight, summary: "From a lunge, jump and switch legs in the air. Land in a lunge. Power and legs.", steps: ["Start in a lunge: one foot forward, one back. Lower slightly.", "Jump up and switch your legs in the air. Land in a lunge with the other leg forward.", "Land softly. Do 8 reps each side (16 total). Rest 45 sec."], tips: ["Land with control; don't let your knee cave in.", "Use your arms to help with the jump."], muscles: ["Quads", "Glutes", "Power"], targets: ["Power", "Plyometrics"], safetyNote: "Land softly. Skip if you have knee issues. Use a soft surface.", difficultyLevel: .difficult, easyVariation: "Step switch instead of jump.", mediumVariation: "Low jump switch; 8 each.", difficultVariation: "Higher jump; add a tuck.", imagePlaceholderName: nil),
        ExerciseDetail(
            exerciseName: "Cool-down Jog in Place",
            equipment: .bodyweight,
            summary: "Light jog or march in place to bring heart rate down gradually after a workout.",
            steps: [
                "Reduce your pace from the main workout to a slow jog or brisk march in place.",
                "Keep your knees low and movements controlled. Breathe steadily.",
                "After 1–2 minutes, you can slow to a walk in place or add gentle arm circles.",
                "Continue until your breathing and heart rate feel comfortable.",
            ],
            tips: [
                "Don’t stop suddenly after intense exercise—cool down for at least 2 minutes.",
                "Use this time to relax your shoulders and breathe deeply.",
            ],
            muscles: ["Legs", "Core"],
            targets: ["Recovery", "Flexibility"],
            safetyNote: "If you feel dizzy, slow down or stop and rest.",
            difficultyLevel: .easy,
            easyVariation: "March in place or walk slowly.",
            mediumVariation: "Slow jog in place for 2–3 minutes.",
            difficultVariation: "Not applicable—cool-down should stay easy.",
            imagePlaceholderName: nil
        ),
        // Hoist V4 Elite
        ExerciseDetail(
            exerciseName: "Chest Press (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Machine chest press on the Hoist V4 Elite. Adjust the multi-function back pad for a comfortable pressing position.",
            steps: [
                "Sit with your back flat against the pad. Adjust seat height so handles are at mid-chest.",
                "Grip the handles (or use strap handles). Push forward until your arms are extended.",
                "Don't lock elbows. Return with control to the start.",
            ],
            tips: ["Squeeze your chest at full extension.", "Keep shoulder blades slightly pinched."],
            muscles: ["Chest", "Triceps", "Front deltoids"],
            targets: ["Strength"],
            safetyNote: "Set the range-of-motion adjuster to a comfortable arc. Use a weight you can control.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight stack; shorter range.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or slow negative.",
            imagePlaceholderName: "ChestPress"
        ),
        ExerciseDetail(
            exerciseName: "Shoulder Press (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Overhead press using the V4 press arm. Adjust starting position for your range of motion.",
            steps: [
                "Position the V4 press arm for overhead pressing. Sit with back supported.",
                "Grip handles at shoulder height. Press up until arms are extended.",
                "Lower with control. Adjust the range-of-motion as needed.",
            ],
            tips: ["Keep core tight. Don't arch your lower back.", "Control the descent."],
            muscles: ["Shoulders", "Triceps", "Upper chest"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Avoid locking elbows at the top.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight; shorter range.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or pause at bottom.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Lat Pulldown (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Pull the lat bar down to your upper chest. Builds lats and upper back.",
            steps: [
                "Attach the aluminum lat bar. Sit or kneel facing the stack.",
                "Grip the bar wide. Pull the bar down to your upper chest.",
                "Squeeze your shoulder blades together. Return with control.",
            ],
            tips: ["Don't lean back excessively—use your lats.", "Lead with your elbows."],
            muscles: ["Lats", "Rhomboids", "Biceps"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Keep core engaged.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight; focus on squeeze.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or add pause at chest.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Seated Row (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Row the lat bar or strap handles to your hips or lower chest. Strengthens mid-back and biceps.",
            steps: [
                "Use the lat bar or strap handles. Sit with knees slightly bent, back straight.",
                "Pull the handle(s) toward your hips or lower chest.",
                "Squeeze your shoulder blades. Return with control.",
            ],
            tips: ["Keep your back flat; don't round.", "Pull to your belly button or hip."],
            muscles: ["Rhomboids", "Lats", "Biceps", "Rear deltoids"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Don't jerk the weight.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight; focus on form.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or single-arm row with strap.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Leg Extension (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Seated leg extension on the V4 leg station. Isolates the quadriceps.",
            steps: [
                "Sit at the leg station. Adjust the roller pad so it rests on your lower shins.",
                "Extend your legs until they are straight. Don't lock knees hard.",
                "Lower with control. Use the range-of-motion adjuster if needed.",
            ],
            tips: ["Point your toes slightly out or straight.", "Squeeze quads at the top."],
            muscles: ["Quadriceps"],
            targets: ["Strength"],
            safetyNote: "Don't use excessive weight; it can stress the knees. Adjust roller for your leg length.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight; shorter range.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or pause at top.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Leg Curl (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Seated leg curl on the V4 leg station. Targets hamstrings.",
            steps: [
                "Sit at the leg station. Use the ankle strap; adjust the roller for your leg length.",
                "Curl your heels toward the seat. Squeeze your hamstrings.",
                "Lower with control. Adjust ROM as needed.",
            ],
            tips: ["Keep your hips down; don't lift off the seat.", "Control the negative."],
            muscles: ["Hamstrings"],
            targets: ["Strength"],
            safetyNote: "Use the fleece ankle strap for comfort. Don't jerk the weight.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight; focus on squeeze.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or pause at peak.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Bicep Curl (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Curl using the V4 curl bar attachment. Isolates biceps.",
            steps: [
                "Attach the aluminum curl bar. Stand or sit; grip the bar.",
                "Curl the bar toward your shoulders. Keep elbows stable.",
                "Lower with control. Don't swing.",
            ],
            tips: ["Keep your upper arms still.", "Squeeze biceps at the top."],
            muscles: ["Biceps", "Forearms"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Avoid straining wrists.",
            difficultyLevel: .easy,
            easyVariation: "Lighter weight.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or slow negative.",
            imagePlaceholderName: "DumbbellBicepCurl"
        ),
        ExerciseDetail(
            exerciseName: "Tricep Pushdown (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Push the strap or bar down using the V4 high pulley. Targets triceps.",
            steps: [
                "Use the strap handles or bar on the high pulley. Stand with elbows at your sides.",
                "Push the handle(s) down until your arms are extended.",
                "Keep elbows stationary. Return with control.",
            ],
            tips: ["Don't swing your body.", "Squeeze triceps at the bottom."],
            muscles: ["Triceps"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Keep core tight.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or rope attachment.",
            imagePlaceholderName: "TricepExtension"
        ),
        ExerciseDetail(
            exerciseName: "Ab Crunch (V4 Elite)",
            equipment: .hoistV4Elite,
            summary: "Crunch using the V4 ab strap attachment. Targets abs with resistance.",
            steps: [
                "Attach the ab strap. Kneel or stand facing the stack.",
                "Hold the strap near your head or chest. Crunch by curling your torso toward your knees.",
                "Squeeze your abs. Return with control.",
            ],
            tips: ["Don't pull with your arms—use your abs.", "Exhale as you crunch."],
            muscles: ["Abs", "Core"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Don't strain your neck.",
            difficultyLevel: .medium,
            easyVariation: "Lighter weight or bodyweight crunch.",
            mediumVariation: "Moderate weight, full crunch.",
            difficultVariation: "Heavier weight or add twist.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Leg Press (Machine)",
            equipment: .legPressMachine,
            summary: "Leg press on the standalone leg press machine (e.g. HOIST RS-2403). Full range for quads and glutes.",
            steps: [
                "Sit with your back flat against the pad. Place feet shoulder-width on the footplate.",
                "Release the safety and lower by bending your knees. Don't round your lower back.",
                "Lower until knees are at about 90°. Push through your heels to extend.",
                "Don't lock knees at the top.",
            ],
            tips: ["Push through the whole foot.", "High feet = more glutes; lower feet = more quads."],
            muscles: ["Quads", "Glutes", "Hamstrings"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Never lock knees under heavy load. Adjust seat for your leg length.",
            difficultyLevel: .medium,
            easyVariation: "Light weight, shorter range.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Single-leg press or heavier weight.",
            imagePlaceholderName: "LegPress"
        ),
        ExerciseDetail(
            exerciseName: "Calf Raises (Leg Press)",
            equipment: .legPressMachine,
            summary: "Calf raises on the leg press machine footplate. Builds calf strength.",
            steps: [
                "On the leg press: place the balls of your feet on the bottom of the footplate, heels off.",
                "Press the platform to extend your legs (or start with legs extended).",
                "Raise your heels as high as you can, then lower with control.",
            ],
            tips: ["Keep knees slightly bent if needed.", "Squeeze calves at the top."],
            muscles: ["Calves"],
            targets: ["Strength"],
            safetyNote: "Use a light load; calves can be loaded heavily. Don't bounce.",
            difficultyLevel: .easy,
            easyVariation: "Bodyweight or light load.",
            mediumVariation: "Moderate load, full range.",
            difficultVariation: "Heavier load or single-leg.",
            imagePlaceholderName: "CalfRaises"
        ),
        ExerciseDetail(
            exerciseName: "Bench Press",
            equipment: .bench,
            summary: "Classic bench press on a flat bench. Use a barbell or dumbbells. Builds chest, triceps, and shoulders.",
            steps: [
                "Lie on the bench, feet flat. Grip the bar or dumbbells slightly wider than shoulder-width.",
                "Unrack (if barbell). Lower the weight to your mid-chest. Keep elbows at about 45°.",
                "Press up until arms are extended. Don't lock elbows hard.",
            ],
            tips: ["Keep shoulder blades pinched. Don't bounce the bar off your chest.", "Use a spotter with a barbell."],
            muscles: ["Chest", "Triceps", "Front deltoids"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Have a spotter for heavy barbell sets.",
            difficultyLevel: .medium,
            easyVariation: "Dumbbells or light bar; focus on form.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or pause at chest.",
            imagePlaceholderName: nil
        ),
        ExerciseDetail(
            exerciseName: "Incline Bench Press",
            equipment: .bench,
            summary: "Bench press on an inclined bench. Emphasizes upper chest and shoulders.",
            steps: [
                "Set the bench to a 30–45° incline. Lie with feet flat. Grip dumbbells or bar.",
                "Lower the weight to your upper chest. Keep elbows at about 45°.",
                "Press up until arms are extended. Control the negative.",
            ],
            tips: ["Don't set incline too steep.", "Squeeze upper chest at the top."],
            muscles: ["Upper chest", "Shoulders", "Triceps"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Secure the bench angle.",
            difficultyLevel: .medium,
            easyVariation: "Dumbbells or light weight.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or pause at chest.",
            imagePlaceholderName: nil
        ),
        // V4 Elite – full list from Hoist V4 Exercise Manual
        ExerciseDetail(exerciseName: "One Arm Triceps Extension (V4 Elite)", equipment: .hoistV4Elite, summary: "Single-arm tricep extension using the strap handle from the pulley.", steps: ["Adjust pulley height.", "Grasp strap handle with one hand.", "Extend arm down; keep elbow at your side.", "Return with control. Repeat other arm."], tips: ["Keep upper arm still.", "Squeeze tricep at full extension."], muscles: ["Triceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight or pause at extension.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Overhead Curl (V4 Elite)", equipment: .hoistV4Elite, summary: "Bicep curl with the curl bar in an overhead position; adjust V4 press arm and roller pads.", steps: ["Adjust V4 press arm and multi-function roller pads.", "Grasp the curl bar.", "Curl the bar toward your shoulders.", "Lower with control."], tips: ["Keep elbows stable.", "Don't swing."], muscles: ["Biceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Tricep Bench (V4 Elite)", equipment: .hoistV4Elite, summary: "Tricep press using both strap handles with back supported. Adjust V4 press arm and back pad.", steps: ["Adjust V4 press arm and back pad.", "Grasp both strap handles.", "Extend arms (tricep press).", "Return with control."], tips: ["Keep elbows at sides.", "Squeeze triceps at extension."], muscles: ["Triceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Seated Triceps Extension (V4 Elite)", equipment: .hoistV4Elite, summary: "Seated tricep extension using both strap handles from the mid pulley.", steps: ["Adjust V4 press arm and back pad.", "Grasp both strap handles from mid pulley.", "Extend arms; squeeze triceps.", "Return with control."], tips: ["Keep elbows pointing forward.", "Don't arch lower back."], muscles: ["Triceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Kneeling Lat Pulldown (V4 Elite)", equipment: .hoistV4Elite, summary: "Lat pulldown from a kneeling position using both strap handles.", steps: ["Adjust pulley.", "Kneel facing the stack.", "Grasp both strap handles.", "Pull down to upper chest; squeeze lats. Return with control."], tips: ["Don't lean back excessively.", "Lead with elbows."], muscles: ["Lats", "Biceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Standing One Arm Row (V4 Elite)", equipment: .hoistV4Elite, summary: "Single-arm row standing; use strap handle from mid pulley.", steps: ["Adjust V4 press arm.", "Grasp strap handle from mid pulley.", "Row to your hip; squeeze shoulder blade.", "Return with control. Repeat other arm."], tips: ["Keep back flat.", "Don't twist torso."], muscles: ["Lats", "Rhomboids", "Biceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "One Arm Row (V4 Elite)", equipment: .hoistV4Elite, summary: "Single-arm row using the pulley and strap handle.", steps: ["Adjust pulley.", "Grasp strap handle.", "Row to your hip; keep back straight.", "Return with control. Repeat other arm."], tips: ["Keep hips square.", "Lead with elbow."], muscles: ["Lats", "Rhomboids", "Biceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "High Pull (V4 Elite)", equipment: .hoistV4Elite, summary: "Pull both strap handles to upper chest; adjust V4 press arm and roller pads.", steps: ["Adjust V4 press arm and multi-function roller pads.", "Grasp both strap handles.", "Pull to upper chest; squeeze shoulder blades.", "Return with control."], tips: ["Keep core tight.", "Don't shrug excessively."], muscles: ["Traps", "Rear delts", "Biceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Upright Row (V4 Elite)", equipment: .hoistV4Elite, summary: "Pull both strap handles from low pulley up to chin level.", steps: ["Adjust V4 press arm.", "Grasp both strap handles from low pulley.", "Pull up to chin; elbows lead.", "Lower with control."], tips: ["Don't raise past shoulder height if it bothers your shoulders.", "Keep core tight."], muscles: ["Traps", "Shoulders", "Biceps"], targets: ["Strength"], safetyNote: "If you feel shoulder impingement, reduce range or skip.", difficultyLevel: .medium, easyVariation: "Lighter weight; pull to chest.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Shoulder Shrug (V4 Elite)", equipment: .hoistV4Elite, summary: "Shrug shoulders up and down holding the strap handles.", steps: ["Adjust pulley.", "Grasp both strap handles.", "Shrug shoulders up toward ears.", "Lower with control."], tips: ["Don't roll shoulders.", "Squeeze traps at top."], muscles: ["Traps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .easy, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight or hold at top.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Lateral Deltoid (V4 Elite)", equipment: .hoistV4Elite, summary: "Raise one arm out to the side using the strap handle from the low pulley.", steps: ["Adjust V4 press arm.", "Grasp strap handle from low pulley.", "Raise arm out to the side.", "Lower with control. Repeat other arm."], tips: ["Keep slight bend in elbow.", "Don't swing."], muscles: ["Lateral deltoids"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Seated Rear Delt (V4 Elite)", equipment: .hoistV4Elite, summary: "Rear delt pull with both strap handles; back supported. Adjust roller pads.", steps: ["Adjust V4 press arm and multi-function roller pads.", "Grasp both strap handles.", "Pull back; squeeze rear delts.", "Return with control."], tips: ["Keep chest up.", "Lead with elbows."], muscles: ["Rear deltoids", "Upper back"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Rotator Cuff - External (V4 Elite)", equipment: .hoistV4Elite, summary: "External rotation for rotator cuff health; keep elbow at 90°. Use strap handle.", steps: ["Adjust pulley.", "Grasp strap handle. Elbow at 90° at your side.", "Rotate forearm outward.", "Return with control. Repeat other arm."], tips: ["Keep elbow pinned at side.", "Use light weight."], muscles: ["Rotator cuff", "Infraspinatus", "Teres minor"], targets: ["Strength", "Injury prevention"], safetyNote: "Use light weight. Stop if you feel pain.", difficultyLevel: .easy, easyVariation: "Very light weight or band.", mediumVariation: "Light weight, full range.", difficultVariation: "Slightly heavier or add pause.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Pectoral Fly (V4 Elite)", equipment: .hoistV4Elite, summary: "Chest fly with both strap handles; adjust V4 press arm and back pad.", steps: ["Adjust V4 press arm and back pad.", "Grasp both strap handles.", "Open arms out to the sides (fly).", "Bring hands together with control."], tips: ["Slight bend in elbows.", "Squeeze chest at center."], muscles: ["Chest", "Front deltoids"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "One Arm Pectoral Fly (V4 Elite)", equipment: .hoistV4Elite, summary: "Single-arm chest fly using the strap handle from the pulley.", steps: ["Adjust pulley.", "Grasp strap handle.", "Open arm across chest (fly).", "Return with control. Repeat other arm."], tips: ["Keep slight bend in elbow.", "Squeeze chest."], muscles: ["Chest"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Pectoral Crossover (V4 Elite)", equipment: .hoistV4Elite, summary: "Cable crossover motion; grasp strap handle from mid pulley, cross arm across chest.", steps: ["Adjust V4 press arm.", "Grasp strap handle from mid pulley.", "Pull/cross arm across your chest.", "Return with control. Repeat other arm."], tips: ["Squeeze chest at peak.", "Control the return."], muscles: ["Chest"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Punch (V4 Elite)", equipment: .hoistV4Elite, summary: "Punch the strap handle forward; control return. Good for chest and shoulders.", steps: ["Adjust pulley.", "Grasp strap handle.", "Punch forward; extend arm.", "Return with control. Repeat other arm."], tips: ["Keep core tight.", "Don't over-rotate."], muscles: ["Chest", "Shoulders", "Triceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .easy, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight or faster tempo.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Incline Press (V4 Elite)", equipment: .hoistV4Elite, summary: "Incline chest press using the articulating arm hand grips.", steps: ["Adjust V4 press arm and back pad to incline.", "Grasp articulating arm hand grips.", "Press forward/up.", "Return with control."], tips: ["Squeeze upper chest.", "Don't set incline too steep."], muscles: ["Upper chest", "Shoulders", "Triceps"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Vertical Press (V4 Elite)", equipment: .hoistV4Elite, summary: "Chest press with press arm hand grips; vertical pressing position.", steps: ["Adjust V4 press arm and back pad.", "Grasp press arm hand grips.", "Press forward (chest press).", "Return with control."], tips: ["Squeeze chest at extension.", "Keep shoulder blades pinched."], muscles: ["Chest", "Triceps", "Front deltoids"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, summary: "Leg press on the V4 base; adjust back pad. Feet on platform.", steps: ["Adjust back pad.", "Place feet on platform.", "Press to extend legs; don't lock knees.", "Lower with control."], tips: ["Push through heels.", "Keep back flat on pad."], muscles: ["Quads", "Glutes", "Hamstrings"], targets: ["Strength"], safetyNote: "Don't lock knees. Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight or single leg.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Stationary Calf Raise (V4 Elite)", equipment: .hoistV4Elite, summary: "Calf raises on the V4; balls of feet on platform.", steps: ["Adjust back pad.", "Place balls of feet on platform; heels off.", "Raise heels; squeeze calves.", "Lower with control."], tips: ["Full range at top.", "Don't bounce."], muscles: ["Calves"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .easy, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight or single leg.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Ride Leg Press (V4 Elite)", equipment: .hoistV4Elite, summary: "Leg press using the optional V-Ride leg press attachment.", steps: ["Adjust back pad on V-Ride.", "Place feet on platform.", "Press through heels.", "Return with control."], tips: ["Push through whole foot.", "Don't lock knees."], muscles: ["Quads", "Glutes", "Hamstrings"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Ride Calf Raise (V4 Elite)", equipment: .hoistV4Elite, summary: "Calf raises on the V-Ride leg press platform.", steps: ["On V-Ride: balls of feet on platform.", "Raise heels; squeeze calves.", "Lower with control."], tips: ["Full range.", "Don't bounce."], muscles: ["Calves"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .easy, easyVariation: "Lighter load.", mediumVariation: "Moderate load.", difficultVariation: "Heavier load.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Standing Leg Curl (V4 Elite)", equipment: .hoistV4Elite, summary: "Standing single-leg curl using ankle/thigh strap or V4 roller pads.", steps: ["Adjust pulley and ankle/thigh strap (or V4 roller pads).", "Stand on one leg; curl other leg back.", "Squeeze hamstring. Return with control. Switch legs."], tips: ["Keep hips square.", "Don't swing."], muscles: ["Hamstrings"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Standing Leg Extension (V4 Elite)", equipment: .hoistV4Elite, summary: "Standing single-leg extension using ankle/thigh strap from pulley.", steps: ["Adjust pulley and ankle/thigh strap.", "Stand on one leg; extend other leg forward.", "Squeeze quad. Return with control. Switch legs."], tips: ["Don't lock knee.", "Keep standing leg slightly bent."], muscles: ["Quadriceps"], targets: ["Strength"], safetyNote: "Use a weight you can control. Can stress knee if too heavy.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Inner Thigh (V4 Elite)", equipment: .hoistV4Elite, summary: "Adduction: pull leg inward against resistance using ankle strap.", steps: ["Adjust pulley and ankle strap around ankle.", "Stand on one leg; pull other leg inward.", "Squeeze inner thigh. Return with control. Switch legs."], tips: ["Keep torso stable.", "Control the return."], muscles: ["Adductors"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Outer Thigh (V4 Elite)", equipment: .hoistV4Elite, summary: "Abduction: push leg outward against resistance. Ankle/thigh strap from low pulley.", steps: ["Adjust V4 press arm and ankle/thigh strap from low pulley.", "Stand on one leg; push other leg outward.", "Squeeze outer hip. Return with control. Switch legs."], tips: ["Keep torso stable.", "Don't lean."], muscles: ["Hip abductors", "Gluteus medius"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Assisted Lunge (V4 Elite)", equipment: .hoistV4Elite, summary: "Lunge while holding strap handles for balance or light assistance.", steps: ["Adjust pulley.", "Grasp both strap handles.", "Lunge forward (or backward); use straps for balance.", "Push back to start. Switch legs."], tips: ["Keep front knee over ankle.", "Core tight."], muscles: ["Quads", "Glutes", "Hamstrings"], targets: ["Strength", "Balance"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Light or no resistance; balance only.", mediumVariation: "Moderate assist.", difficultVariation: "Less assist or add weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Glute Kick (V4 Elite)", equipment: .hoistV4Elite, summary: "Kick one leg back against resistance; ankle strap. Squeeze glute.", steps: ["Adjust pulley and ankle strap.", "Stand; attach strap to ankle.", "Kick leg back; squeeze glute.", "Return with control. Switch legs."], tips: ["Don't arch lower back.", "Keep standing leg slightly bent."], muscles: ["Glutes", "Hamstrings"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "High Step (V4 Elite)", equipment: .hoistV4Elite, summary: "Step up onto platform with ankle strap for resistance or balance.", steps: ["Adjust pulley and ankle strap.", "Step up onto platform; drive through standing leg.", "Step down with control. Switch legs."], tips: ["Use full foot on platform.", "Keep core tight."], muscles: ["Quads", "Glutes", "Calves"], targets: ["Strength", "Balance"], safetyNote: "Use a stable platform. Light resistance if any.", difficultyLevel: .medium, easyVariation: "No strap; bodyweight step-up.", mediumVariation: "Light resistance.", difficultVariation: "Heavier resistance or higher step.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Side Bends (V4 Elite)", equipment: .hoistV4Elite, summary: "Bend torso to the side against resistance; strap handle from low pulley.", steps: ["Adjust V4 press arm.", "Grasp strap handle from low pulley.", "Bend torso to the side.", "Return to center. Repeat other side."], tips: ["Don't twist; pure side bend.", "Control the return."], muscles: ["Obliques", "Core"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .easy, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Torso Rotation (V4 Elite)", equipment: .hoistV4Elite, summary: "Rotate torso against resistance; grasp strap handle.", steps: ["Adjust pulley.", "Grasp strap handle.", "Rotate torso; control return.", "Repeat other side."], tips: ["Engage core.", "Don't use only arms."], muscles: ["Obliques", "Core", "Rotators"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Golf Swing (V4 Elite)", equipment: .hoistV4Elite, summary: "Rotational swing motion with strap handle; good for core and rotation.", steps: ["Adjust pulley.", "Grasp strap handle.", "Perform rotational swing motion.", "Control return. Repeat other side."], tips: ["Engage core.", "Smooth motion."], muscles: ["Core", "Obliques", "Shoulders"], targets: ["Strength", "Mobility"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
        ExerciseDetail(exerciseName: "Twist & Lift (V4 Elite)", equipment: .hoistV4Elite, summary: "Twist and lift motion with strap handle; engages core.", steps: ["Adjust pulley.", "Grasp strap handle.", "Twist and lift; engage core.", "Control return. Repeat other side."], tips: ["Keep movement controlled.", "Breathe out on effort."], muscles: ["Core", "Obliques"], targets: ["Strength"], safetyNote: "Use a weight you can control.", difficultyLevel: .medium, easyVariation: "Lighter weight.", mediumVariation: "Moderate weight.", difficultVariation: "Heavier weight.", imagePlaceholderName: nil),
    ]
    
    /// Look up detailed steps, tips, and safety for an exercise by name (exact or partial match).
    static func detail(forExerciseName name: String) -> ExerciseDetail? {
        let n = name.trimmingCharacters(in: .whitespaces)
        if n.isEmpty { return nil }
        let lower = n.lowercased()
        return allDetails.first { d in
            let dLower = d.exerciseName.lowercased()
            return dLower == lower || dLower.contains(lower) || lower.contains(dLower)
        }
    }
}

extension ExerciseDetail: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ExerciseDetail, rhs: ExerciseDetail) -> Bool { lhs.id == rhs.id }
}

#Preview {
    ExerciseLibraryView()
        .environmentObject(UserStore())
}
