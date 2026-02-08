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
            imagePlaceholderName: "GobletSquat"
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
            difficultyLevel: .medium,
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
            exerciseName: "Leg Press",
            equipment: .homeGym,
            summary: "Push the weight platform with your feet. Builds quads and glutes with machine support.",
            steps: [
                "Sit in the leg press with your back flat against the pad. Place your feet shoulder-width apart on the platform.",
                "Release the safety and bend your knees to lower the platform. Don't let your lower back round.",
                "Lower until your knees are at about 90°, then push through your heels to extend your legs.",
                "Don't lock your knees at the top.",
            ],
            tips: [
                "Push through your whole foot; avoid letting your heels rise.",
                "Keep your knees in line with your toes.",
            ],
            muscles: ["Quads", "Glutes", "Hamstrings"],
            targets: ["Strength"],
            safetyNote: "Use a weight you can control. Never lock knees under heavy load.",
            difficultyLevel: .medium,
            easyVariation: "Light weight, shorter range.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Single-leg press or heavier weight.",
            imagePlaceholderName: "LegPress"
        ),
        ExerciseDetail(
            exerciseName: "Chest Press",
            equipment: .homeGym,
            summary: "Press the handles or bar away from your chest on a machine. Builds chest and triceps.",
            steps: [
                "Sit with your back flat. Grip the handles or bar at chest height.",
                "Push the weight forward until your arms are extended. Don't lock elbows.",
                "Return with control to the start position.",
            ],
            tips: [
                "Squeeze your chest at full extension.",
                "Keep your shoulder blades slightly pinched together.",
            ],
            muscles: ["Chest", "Triceps", "Shoulders"],
            targets: ["Strength"],
            safetyNote: "Set the seat so the handles are at mid-chest. Use a weight you can control.",
            difficultyLevel: .medium,
            easyVariation: "Light weight, full control.",
            mediumVariation: "Moderate weight, full range.",
            difficultVariation: "Heavier weight or slow negative.",
            imagePlaceholderName: "ChestPress"
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
