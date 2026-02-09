//
//  WorkoutStore.swift
//  HomeStrength
//
//  Beginner-friendly home workouts: dumbbells, resistance bands, home gym, treadmill, bike.
//

import Foundation
import SwiftUI

@MainActor
class WorkoutStore: ObservableObject {
    @Published var workouts: [Workout] = []
    
    /// Library of exercises to choose from when designing a workout. Filter by equipment. Nonisolated for Swift 6 (immutable Sendable, safe to read from any context).
    nonisolated static let exerciseLibrary: [Exercise] = buildExerciseLibrary()
    
    init() {
        workouts = WorkoutStore.buildDefaultWorkouts()
            + WorkoutStore.buildDaughterWorkouts()
            + WorkoutStore.buildKid7Workouts()
            + WorkoutStore.buildKid5Workouts()
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
    
    func updateWorkout(_ workout: Workout) {
        guard let i = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        workouts[i] = workout
    }
    
    func deleteWorkout(id: UUID) {
        workouts.removeAll { $0.id == id }
    }
    
    /// Workouts for the given profile, optionally filtered by equipment and/or muscle group focus.
    func workouts(for profileType: UserProfileType, using equipment: Set<Equipment> = [], focus: MuscleGroup? = nil) -> [Workout] {
        var list = workouts.filter { $0.profileType == profileType }
        if !equipment.isEmpty {
            list = list.filter { workout in
                workout.exercises.allSatisfy { equipment.contains($0.equipment) }
            }
        }
        if let focus = focus {
            list = list.filter { $0.primaryFocus == focus }
        }
        return list
    }
    
    /// Legacy: workouts using only given equipment (no profile filter). Prefer workouts(for:using:).
    func workouts(using equipment: Set<Equipment>) -> [Workout] {
        if equipment.isEmpty { return workouts }
        return workouts.filter { workout in
            workout.exercises.allSatisfy { equipment.contains($0.equipment) }
        }
    }
    
    nonisolated static func exercises(using equipment: Set<Equipment>) -> [Exercise] {
        if equipment.isEmpty { return exerciseLibrary }
        return exerciseLibrary.filter { equipment.contains($0.equipment) }
    }
    
    nonisolated static func buildExerciseLibrary() -> [Exercise] {
        [
            Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Hold one dumbbell at chest. Squat down, keep chest up.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
            Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press dumbbells up from floor.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
            Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs.", sets: 3, reps: "8 each"),
            Exercise(name: "Hammer Curl", equipment: .dumbbells, instructions: "Palms face each other. Curl dumbbells to shoulders; keep elbows at sides.", sets: 3, reps: "10–12"),
            Exercise(name: "Lateral Raise", equipment: .dumbbells, instructions: "Raise dumbbells out to the sides to shoulder height. Control the lower.", sets: 3, reps: "10–12"),
            Exercise(name: "Front Raise", equipment: .dumbbells, instructions: "Raise one or both dumbbells in front to shoulder height. Keep core tight.", sets: 3, reps: "10–12"),
            Exercise(name: "Reverse Fly", equipment: .dumbbells, instructions: "Hinge at hips, slight bend in knees. Raise dumbbells out to sides for rear delts.", sets: 3, reps: "10–12"),
            Exercise(name: "Incline Dumbbell Press", equipment: .dumbbells, instructions: "Set bench to incline or use floor with hips raised. Press dumbbells from upper chest.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Pullover", equipment: .dumbbells, instructions: "Lie on back, one dumbbell over chest. Lower behind head then pull back to start.", sets: 3, reps: "10–12"),
            Exercise(name: "Concentration Curl", equipment: .dumbbells, instructions: "Seated, elbow against inner thigh. Curl dumbbell to shoulder; squeeze at top.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Tricep Kickback", equipment: .dumbbells, instructions: "Hinge at hips, elbow at side. Extend arm back; squeeze tricep. Alternate or both.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Dumbbell Calf Raise", equipment: .dumbbells, instructions: "Hold dumbbells at sides. Rise onto toes; lower with control.", sets: 3, reps: "15"),
            Exercise(name: "Dumbbell Step-Up", equipment: .dumbbells, instructions: "Step onto bench or box with one foot; drive up. Alternate legs.", sets: 3, reps: "10 each"),
            Exercise(name: "Dumbbell Swing", equipment: .dumbbells, instructions: "Hinge at hips, swing one dumbbell between legs then up to chest height. Control the arc.", sets: 3, reps: "12"),
            Exercise(name: "Dumbbell Shrug", equipment: .dumbbells, instructions: "Hold dumbbells at sides. Shrug shoulders up toward ears; lower slowly.", sets: 3, reps: "12–15"),
            Exercise(name: "Dumbbell Chest Fly", equipment: .dumbbells, instructions: "Lie on back. Open arms with slight bend; bring dumbbells together over chest.", sets: 3, reps: "10–12"),
            Exercise(name: "Arnold Press", equipment: .dumbbells, instructions: "Start palms in at shoulders. Press up while rotating palms out. Full range.", sets: 3, reps: "10"),
            Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
            Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
            Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
            Exercise(name: "Band Row", equipment: .resistanceBands, instructions: "Anchor band; pull handles to hips. Squeeze shoulder blades.", sets: 3, reps: "12"),
            Exercise(name: "Band Chest Press", equipment: .resistanceBands, instructions: "Anchor band behind back. Press hands forward from chest.", sets: 3, reps: "12"),
            Exercise(name: "Band Lateral Raise", equipment: .resistanceBands, instructions: "Stand on band; raise arms out to sides to shoulder height.", sets: 3, reps: "12"),
            Exercise(name: "Band Face Pull", equipment: .resistanceBands, instructions: "Pull band to face level; elbows out. Rear delts and upper back.", sets: 3, reps: "15"),
            Exercise(name: "Band Bicep Curl", equipment: .resistanceBands, instructions: "Stand on band; curl hands to shoulders. Control the negative.", sets: 3, reps: "12"),
            Exercise(name: "Band Tricep Pushdown", equipment: .resistanceBands, instructions: "Anchor band high; push down with elbows at sides.", sets: 3, reps: "12"),
            Exercise(name: "Band Squat", equipment: .resistanceBands, instructions: "Stand on band or loop above knees. Squat with tension.", sets: 3, reps: "12"),
            Exercise(name: "Band Leg Curl", equipment: .resistanceBands, instructions: "Anchor band; lie face down or stand. Curl heel toward glutes.", sets: 3, reps: "12 each"),
            Exercise(name: "Band Hip Abduction", equipment: .resistanceBands, instructions: "Band around legs. Push knee or leg out to the side.", sets: 3, reps: "15 each"),
            Exercise(name: "Band Clam Shell", equipment: .resistanceBands, instructions: "Side-lying, band above knees. Open top knee; squeeze glutes.", sets: 3, reps: "15 each"),
            Exercise(name: "Band Monster Walk", equipment: .resistanceBands, instructions: "Band around legs; slight squat. Step sideways or forward in small steps.", sets: 3, reps: "10 each direction"),
            Exercise(name: "Band Lateral Walk", equipment: .resistanceBands, instructions: "Band above knees; mini squat. Step sideways keeping tension.", sets: 3, reps: "10 each direction"),
            Exercise(name: "Band Deadlift", equipment: .resistanceBands, instructions: "Stand on band; hinge at hips. Pull band tension as you stand.", sets: 3, reps: "12"),
            Exercise(name: "Band Pallof Press", equipment: .resistanceBands, instructions: "Anchor band to side. Hold at chest and press forward; resist rotation.", sets: 3, reps: "10 each side"),
            Exercise(name: "Band Wood Chop", equipment: .resistanceBands, instructions: "Anchor band low or high. Rotate torso and pull band across body.", sets: 3, reps: "10 each side"),
            Exercise(name: "Band External Rotation", equipment: .resistanceBands, instructions: "Elbow at 90°, band in hand. Rotate forearm out; rotator cuff.", sets: 3, reps: "15 each"),
            Exercise(name: "Band Good Morning", equipment: .resistanceBands, instructions: "Stand on band, band behind neck. Hinge at hips; feel hamstring stretch.", sets: 3, reps: "12"),
            Exercise(name: "Band Donkey Kick", equipment: .resistanceBands, instructions: "Band around foot, anchor behind. Kick one leg back; squeeze glute.", sets: 3, reps: "12 each"),
            Exercise(name: "Band Y Raise", equipment: .resistanceBands, instructions: "Stand on band. Raise arms in Y shape; lower traps and shoulders.", sets: 3, reps: "12"),
            Exercise(name: "Band Single-Arm Row", equipment: .resistanceBands, instructions: "Anchor band; pull one hand to hip. Keep core tight.", sets: 3, reps: "12 each"),
            Exercise(name: "Band Crunch", equipment: .resistanceBands, instructions: "Anchor band behind; hold at chest. Crunch forward against resistance.", sets: 3, reps: "15"),
            Exercise(name: "Band Hip Thrust", equipment: .resistanceBands, instructions: "Band above knees, back on bench. Drive hips up; squeeze glutes.", sets: 3, reps: "12"),
            Exercise(name: "Band Reverse Fly", equipment: .resistanceBands, instructions: "Anchor in front or hold band. Hinge and pull arms back for rear delts.", sets: 3, reps: "15"),
            Exercise(name: "Band Overhead Press", equipment: .resistanceBands, instructions: "Stand on band; press hands overhead from shoulders.", sets: 3, reps: "12"),
            Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
            Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
            Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
            Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min warm-up walk, then 15–20 min jog or brisk walk.", sets: 1, reps: "20–25 min"),
            Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Steady pace 15–20 min, or intervals.", sets: 1, reps: "15–20 min"),
            Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10"),
            Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
            Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
            Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
            Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
            // Volleyball / agility
            Exercise(name: "Skater Jumps", equipment: .bodyweight, instructions: "Jump side to side, landing on one foot. Swing arms for balance.", sets: 3, reps: "8 each", restSeconds: 45),
            Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, slide down until knees at 90°. Hold.", sets: 3, reps: "30 sec", restSeconds: 45),
            Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side low and quick. Stay on balls of feet.", sets: 3, reps: "20 sec", restSeconds: 30),
            Exercise(name: "Single-Leg Hops", equipment: .bodyweight, instructions: "Hop on one foot forward or in place. Land softly. Switch legs.", sets: 3, reps: "6 each", restSeconds: 45),
            Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately. Keep hips level.", sets: 3, reps: "20 sec", restSeconds: 30),
            Exercise(name: "Tricep Dips (chair)", equipment: .bodyweight, instructions: "Hands on chair, lower and push back up. Strengthens triceps for serving.", sets: 3, reps: "8", restSeconds: 45),
            Exercise(name: "Box Step-Ups (or stairs)", equipment: .bodyweight, instructions: "Step up and down, drive through the standing leg. Builds single-leg power.", sets: 3, reps: "10 each", restSeconds: 45),
            // Bodyweight – Easy (10)
            Exercise(name: "March in Place", equipment: .bodyweight, instructions: "March with high knees; pump arms. Warm-up or light cardio.", sets: 2, reps: "60 sec", restSeconds: 30),
            Exercise(name: "Heel Raises (Seated)", equipment: .bodyweight, instructions: "Sit on chair; raise heels off floor. Calves and ankles.", sets: 3, reps: "15"),
            Exercise(name: "Arm Circles", equipment: .bodyweight, instructions: "Arms out to sides; small then large circles. Shoulder mobility.", sets: 2, reps: "10 each direction"),
            Exercise(name: "Lying Leg Raise", equipment: .bodyweight, instructions: "Lie on back; raise legs toward ceiling. Lower with control. Core and hip flexors.", sets: 3, reps: "10"),
            Exercise(name: "Toe Taps", equipment: .bodyweight, instructions: "Stand; tap one foot forward and to the side, alternate. Light balance and coordination.", sets: 2, reps: "20 each"),
            Exercise(name: "Shoulder Rolls", equipment: .bodyweight, instructions: "Roll shoulders back 10, then forward 10. Release tension.", sets: 2, reps: "10 each direction"),
            Exercise(name: "Standing Hip Abduction", equipment: .bodyweight, instructions: "Stand on one leg; lift other leg out to the side. Hold wall if needed.", sets: 3, reps: "12 each"),
            Exercise(name: "Wall Push-Up", equipment: .bodyweight, instructions: "Hands on wall, body angled; lower chest to wall and push back. Easier than floor push-up.", sets: 3, reps: "12"),
            Exercise(name: "Chair Squat", equipment: .bodyweight, instructions: "Stand in front of chair; squat to tap seat and stand. Builds confidence in squat pattern.", sets: 3, reps: "10"),
            Exercise(name: "Standing Y Raise", equipment: .bodyweight, instructions: "Arms in Y shape; raise and lower with control. Lower traps and shoulders.", sets: 2, reps: "12"),
            // Bodyweight – Medium (10)
            Exercise(name: "Bodyweight Lunge", equipment: .bodyweight, instructions: "Step forward into lunge; back knee toward floor. Alternate or same leg.", sets: 3, reps: "10 each"),
            Exercise(name: "Reverse Lunge", equipment: .bodyweight, instructions: "Step one foot back; lower back knee. Return to stand. Alternate legs.", sets: 3, reps: "10 each"),
            Exercise(name: "Incline Push-Up", equipment: .bodyweight, instructions: "Hands on bench or step; body angled. Push up and down. Easier than floor.", sets: 3, reps: "10–12"),
            Exercise(name: "Side Plank", equipment: .bodyweight, instructions: "Support on one forearm and side of foot; hold. Core and obliques.", sets: 2, reps: "20–30 sec each"),
            Exercise(name: "Single-Leg Glute Bridge", equipment: .bodyweight, instructions: "One foot on floor; lift hips. Other leg extended or bent. Squeeze glutes.", sets: 3, reps: "10 each"),
            Exercise(name: "Bicycle Crunch", equipment: .bodyweight, instructions: "On back; bring opposite elbow to knee in a pedaling motion. Core.", sets: 3, reps: "20 total"),
            Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up quickly. Cardio and leg drive.", sets: 3, reps: "30 sec", restSeconds: 30),
            Exercise(name: "Butt Kicks", equipment: .bodyweight, instructions: "Run in place, heels toward glutes. Hamstrings and cardio.", sets: 3, reps: "30 sec", restSeconds: 30),
            Exercise(name: "Jumping Jacks", equipment: .bodyweight, instructions: "Jump feet out while arms go up; return. Full-body cardio.", sets: 3, reps: "20–30", restSeconds: 30),
            Exercise(name: "Bear Crawl", equipment: .bodyweight, instructions: "On hands and feet, knees off floor; crawl forward and back. Core and shoulders.", sets: 2, reps: "30 sec", restSeconds: 45),
            // Bodyweight – Difficult (10)
            Exercise(name: "Burpee", equipment: .bodyweight, instructions: "Squat, jump feet back to plank, (optional push-up), jump feet in, jump up. Full-body.", sets: 3, reps: "6–10", restSeconds: 45),
            Exercise(name: "Pike Push-Up", equipment: .bodyweight, instructions: "Hips high, hands and feet; lower head toward floor and push back. Shoulders.", sets: 3, reps: "8–10"),
            Exercise(name: "Decline Push-Up", equipment: .bodyweight, instructions: "Feet on step or bench, hands on floor. Push up. Harder than flat push-up.", sets: 3, reps: "8–10"),
            Exercise(name: "Single-Leg Deadlift", equipment: .bodyweight, instructions: "Balance on one leg; hinge and reach toward floor. Return to stand. Hamstrings and balance.", sets: 3, reps: "8 each"),
            Exercise(name: "Hand-Release Push-Up", equipment: .bodyweight, instructions: "Lower to floor, lift hands briefly, then push back up. Full range.", sets: 3, reps: "6–10"),
            Exercise(name: "Spiderman Push-Up", equipment: .bodyweight, instructions: "Push-up; bring one knee to same-side elbow. Alternate. Core and chest.", sets: 3, reps: "8 each"),
            Exercise(name: "Tuck Jump", equipment: .bodyweight, instructions: "Jump and tuck knees toward chest. Land softly. Power and legs.", sets: 3, reps: "6–8", restSeconds: 45),
            Exercise(name: "Long-Lever Plank", equipment: .bodyweight, instructions: "Plank with hands further forward than shoulders. Harder on core.", sets: 2, reps: "30–45 sec"),
            Exercise(name: "Hollow Hold", equipment: .bodyweight, instructions: "On back; lift head, shoulders, and legs off floor. Arms by sides or overhead. Core.", sets: 3, reps: "20–30 sec"),
            Exercise(name: "Jump Lunge", equipment: .bodyweight, instructions: "Lunge; jump and switch legs in the air. Land in lunge. Power and legs.", sets: 3, reps: "8 each", restSeconds: 45),
            // Yoga Mat – stretches, poses, and mat-based movement
            Exercise(name: "Cat-Cow", equipment: .yogaMat, instructions: "On all fours, round spine then arch. Breathe with the movement.", sets: 2, reps: "8", restSeconds: 15),
            Exercise(name: "Child's Pose", equipment: .yogaMat, instructions: "Knees under hips, fold forward, arms extended. Hold and breathe.", sets: 2, reps: "30 sec", restSeconds: 20),
            Exercise(name: "Downward Dog", equipment: .yogaMat, instructions: "Hips up, heels toward floor. Stretch hamstrings and shoulders.", sets: 2, reps: "30 sec", restSeconds: 20),
            Exercise(name: "Hip Stretch", equipment: .yogaMat, instructions: "Seated or supine hip opener. Hold 20–30 sec each side.", sets: 2, reps: "30 sec", restSeconds: 15),
            Exercise(name: "Cobra", equipment: .yogaMat, instructions: "Lie on belly; press chest up, hands under shoulders. Keep hips down.", sets: 2, reps: "8", restSeconds: 15),
            Exercise(name: "Warrior I", equipment: .yogaMat, instructions: "Lunge with back foot turned out; arms up. Hold 30 sec each side.", sets: 2, reps: "30 sec each", restSeconds: 20),
            Exercise(name: "Warrior II", equipment: .yogaMat, instructions: "Wide stance, front knee bent; arms out to sides. Hold 30 sec each side.", sets: 2, reps: "30 sec each", restSeconds: 20),
            Exercise(name: "Triangle Pose", equipment: .yogaMat, instructions: "Wide legs; reach down to shin or floor, other arm up. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Seated Forward Fold", equipment: .yogaMat, instructions: "Sit with legs extended; fold forward from hips. Hold 30 sec.", sets: 2, reps: "30 sec", restSeconds: 20),
            Exercise(name: "Low Lunge", equipment: .yogaMat, instructions: "One knee down, front foot forward; sink into hip stretch. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Pigeon Pose", equipment: .yogaMat, instructions: "One leg bent in front, back leg extended. Hip opener. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 20),
            Exercise(name: "Thread the Needle", equipment: .yogaMat, instructions: "On all fours; thread one arm under body, twist. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Supine Twist", equipment: .yogaMat, instructions: "Lie on back; drop both knees to one side. Spinal twist. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Happy Baby", equipment: .yogaMat, instructions: "On back, grab feet; rock side to side. Release lower back and hips.", sets: 2, reps: "30 sec", restSeconds: 15),
            Exercise(name: "Legs Up the Wall", equipment: .yogaMat, instructions: "Lie with legs vertical against a wall. Rest and drain legs. 2–5 min.", sets: 1, reps: "2–5 min", restSeconds: 0),
            Exercise(name: "Corpse Pose (Savasana)", equipment: .yogaMat, instructions: "Lie flat, arms and legs relaxed. Rest and breathe. 2–5 min.", sets: 1, reps: "2–5 min", restSeconds: 0),
            Exercise(name: "Upward Dog", equipment: .yogaMat, instructions: "From belly, press into hands; lift chest and thighs. Opens front body.", sets: 2, reps: "5–8", restSeconds: 15),
            Exercise(name: "Mountain Pose", equipment: .yogaMat, instructions: "Stand tall, feet together or hip-width. Ground and lengthen spine. Hold 1 min.", sets: 2, reps: "1 min", restSeconds: 10),
            Exercise(name: "Tree Pose", equipment: .yogaMat, instructions: "Stand on one leg; place other foot on calf or thigh. Balance. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Bridge Pose", equipment: .yogaMat, instructions: "Lie on back, knees bent; lift hips toward ceiling. Squeeze glutes. Hold or pulse.", sets: 2, reps: "8–10", restSeconds: 20),
            Exercise(name: "Reclined Butterfly", equipment: .yogaMat, instructions: "Lie on back, soles of feet together, knees out. Hip and inner-thigh stretch.", sets: 2, reps: "30 sec", restSeconds: 15),
            Exercise(name: "Figure-Four Stretch", equipment: .yogaMat, instructions: "Lie on back; cross one ankle over opposite knee. Pull leg in. Each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Seated Spinal Twist", equipment: .yogaMat, instructions: "Sit; twist torso toward one knee. Hold each side. Breathe into the twist.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Crescent Lunge", equipment: .yogaMat, instructions: "High lunge with arms up. Stretch hip flexor and quad. Hold each side.", sets: 2, reps: "30 sec each", restSeconds: 15),
            Exercise(name: "Plank (Yoga)", equipment: .yogaMat, instructions: "High plank, shoulders over wrists. Hold 30–60 sec. Core and shoulders.", sets: 2, reps: "30–60 sec", restSeconds: 30),
            // Hoist V4 Elite (https://www.hoistfitness.com/collections/v-series-gyms/products/v4-elite-gym)
            Exercise(name: "Chest Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Sit with back on pad. Grip handles and press forward. Adjust back pad for comfort.", sets: 3, reps: "10–12"),
            Exercise(name: "Shoulder Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use V4 press arm in overhead position. Press handles up. Adjust range-of-motion as needed.", sets: 3, reps: "10"),
            Exercise(name: "Lat Pulldown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use lat bar attachment. Sit or kneel; pull bar to upper chest. Squeeze shoulder blades.", sets: 3, reps: "10–12"),
            Exercise(name: "Seated Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use lat bar or strap handles. Pull to hips or lower chest. Keep back straight.", sets: 3, reps: "10–12"),
            Exercise(name: "Leg Extension (V4 Elite)", equipment: .hoistV4Elite, instructions: "Seated at leg station. Extend legs against pad. Adjust roller for leg length.", sets: 3, reps: "10–12"),
            Exercise(name: "Leg Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Seated at leg station. Curl heels toward seat. Use ankle strap; adjust ROM as needed.", sets: 3, reps: "10–12"),
            Exercise(name: "Bicep Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use curl bar attachment. Curl toward shoulders. Keep elbows stable.", sets: 3, reps: "10–12"),
            Exercise(name: "Tricep Pushdown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use strap or bar on high pulley. Push down; keep elbows at sides.", sets: 3, reps: "10–12"),
            Exercise(name: "Ab Crunch (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use ab strap attachment. Kneel or stand; crunch by pulling strap toward knees.", sets: 3, reps: "12–15"),
            // V4 Elite – full list from Hoist V4 Exercise Manual (arms, back, shoulders, chest, legs, abs)
            Exercise(name: "One Arm Triceps Extension (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Extend arm down; keep elbow at side.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Overhead Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and roller pads. Grasp curl bar. Curl overhead.", sets: 3, reps: "10–12"),
            Exercise(name: "Tricep Bench (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad. Grasp both strap handles. Extend arms (tricep press).", sets: 3, reps: "10–12"),
            Exercise(name: "Seated Triceps Extension (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad. Grasp both strap handles from mid pulley. Extend arms.", sets: 3, reps: "10–12"),
            Exercise(name: "Kneeling Lat Pulldown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Kneel; grasp both strap handles. Pull down to upper chest.", sets: 3, reps: "10–12"),
            Exercise(name: "Standing One Arm Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp strap handle from mid pulley. Row to hip.", sets: 3, reps: "10–12 each"),
            Exercise(name: "One Arm Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Row to hip; keep back straight.", sets: 3, reps: "10–12 each"),
            Exercise(name: "High Pull (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and roller pads. Grasp both strap handles. Pull to upper chest.", sets: 3, reps: "10–12"),
            Exercise(name: "Upright Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp both strap handles from low pulley. Pull up to chin.", sets: 3, reps: "10–12"),
            Exercise(name: "Shoulder Shrug (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp both strap handles. Shrug shoulders up; lower with control.", sets: 3, reps: "12–15"),
            Exercise(name: "Lateral Deltoid (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp strap handle from low pulley. Raise arm out to side.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Seated Rear Delt (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and roller pads. Grasp both strap handles. Pull back for rear delts.", sets: 3, reps: "10–12"),
            Exercise(name: "Rotator Cuff - External (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Rotate arm externally; keep elbow at 90°.", sets: 3, reps: "12–15 each"),
            Exercise(name: "Pectoral Fly (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad. Grasp both strap handles. Open and close arms (fly).", sets: 3, reps: "10–12"),
            Exercise(name: "One Arm Pectoral Fly (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Single-arm pec fly.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Pectoral Crossover (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp strap handle from mid pulley. Cross arm across chest.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Punch (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Punch forward; control return.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Incline Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad to incline. Grasp articulating arm hand grips. Press.", sets: 3, reps: "10–12"),
            Exercise(name: "Vertical Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad. Grasp press arm hand grips. Press forward (chest press).", sets: 3, reps: "10–12"),
            Exercise(name: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust back pad. Feet on platform. Press and return; don't lock knees.", sets: 3, reps: "10–12"),
            Exercise(name: "Stationary Calf Raise (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust back pad. Balls of feet on platform; raise heels.", sets: 3, reps: "15"),
            Exercise(name: "Ride Leg Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use V-Ride leg press option. Adjust back pad. Press through heels.", sets: 3, reps: "10–12"),
            Exercise(name: "Ride Calf Raise (V4 Elite)", equipment: .hoistV4Elite, instructions: "On V-Ride leg press. Balls of feet on platform; raise heels.", sets: 3, reps: "15"),
            Exercise(name: "Standing Leg Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley and ankle/thigh strap. Stand; curl one leg back. Or use V4 roller pads.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Standing Leg Extension (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley and ankle/thigh strap. Stand; extend one leg forward.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Inner Thigh (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley and ankle strap around ankle. Pull leg inward against resistance.", sets: 3, reps: "12–15 each"),
            Exercise(name: "Outer Thigh (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and ankle/thigh strap from low pulley. Push leg outward.", sets: 3, reps: "12–15 each"),
            Exercise(name: "Assisted Lunge (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp both strap handles. Lunge forward or back; use straps for balance.", sets: 3, reps: "8–10 each"),
            Exercise(name: "Glute Kick (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley and ankle strap. Kick one leg back; squeeze glute. Return with control.", sets: 3, reps: "10–12 each"),
            Exercise(name: "High Step (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley and ankle strap. Step up onto platform; drive through standing leg.", sets: 3, reps: "10 each"),
            Exercise(name: "Side Bends (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp strap handle from low pulley. Bend torso to the side.", sets: 3, reps: "12–15 each"),
            Exercise(name: "Torso Rotation (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Rotate torso; control return.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Golf Swing (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Rotational swing motion; control return.", sets: 3, reps: "10–12 each"),
            Exercise(name: "Twist & Lift (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Twist and lift; engage core.", sets: 3, reps: "10–12 each"),
            // Leg Press Machine (RS-2403)
            Exercise(name: "Leg Press (Machine)", equipment: .legPressMachine, instructions: "Feet on footplate. Push through heels; don't lock knees. Adjust seat for range.", sets: 3, reps: "10–12"),
            Exercise(name: "Calf Raises (Leg Press)", equipment: .legPressMachine, instructions: "On leg press: balls of feet on platform, press to extend legs then raise heels.", sets: 3, reps: "15"),
            // Bench (flat/incline)
            Exercise(name: "Bench Press", equipment: .bench, instructions: "Lie on bench. Lower bar or dumbbells to chest, press up. Use spotter if using barbell.", sets: 3, reps: "8–10"),
            Exercise(name: "Incline Bench Press", equipment: .bench, instructions: "Set bench to incline. Press dumbbells or bar from upper chest. Control the negative.", sets: 3, reps: "8–10"),
        ]
    }
    
    static func buildDefaultWorkouts() -> [Workout] {
        [
            Workout(
                name: "Full Body A",
                summary: "Dumbbells + bands. Great for building a base.",
                exercises: [
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Hold one dumbbell at chest. Squat down, keep chest up.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
                    Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press dumbbells up from floor.", sets: 3, reps: "10"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
                ],
                estimatedMinutes: 35,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            Workout(
                name: "Full Body B",
                summary: "Home gym + dumbbells. Presses and legs.",
                exercises: [
                    Exercise(name: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Feet shoulder-width. Push through heels.", sets: 3, reps: "10–12"),
                    Exercise(name: "Chest Press (V4 Elite)", equipment: .hoistV4Elite, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Hold one dumbbell at chest. Squat down, keep chest up.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10"),
                ],
                estimatedMinutes: 40,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            Workout(
                name: "Upper Body",
                summary: "Dumbbells, bands, and home gym.",
                exercises: [
                    Exercise(name: "Chest Press (V4 Elite)", equipment: .hoistV4Elite, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, sets: 3, reps: "10 each"),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
                    Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press dumbbells up from floor.", sets: 3, reps: "10"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                ],
                estimatedMinutes: 35,
                profileType: .mom,
                primaryFocus: .upperBody
            ),
            Workout(
                name: "Lower Body",
                summary: "Legs with home gym, dumbbells, and bands.",
                exercises: [
                    Exercise(name: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, sets: 3, reps: "10–12"),
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs.", sets: 3, reps: "8 each"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                ],
                estimatedMinutes: 40,
                profileType: .mom,
                primaryFocus: .legs
            ),
            Workout(
                name: "Cardio",
                summary: "Treadmill and exercise bike. Ease in, then push.",
                exercises: [
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min warm-up walk, then 15–20 min jog or brisk walk.", sets: 1, reps: "20–25 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Steady pace 15–20 min, or intervals.", sets: 1, reps: "15–20 min"),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up quickly.", sets: 3, reps: "30 sec", restSeconds: 30),
                    Exercise(name: "Jump Squats", equipment: .bodyweight, instructions: "Squat then jump up. Land softly.", sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately.", sets: 3, reps: "30 sec", restSeconds: 30),
                    Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side low and quick.", sets: 3, reps: "30 sec", restSeconds: 30),
                    Exercise(name: "Skater Jumps", equipment: .bodyweight, instructions: "Jump side to side, land on one foot. Swing arms.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Single-Leg Hops", equipment: .bodyweight, instructions: "Hop on one foot forward or in place. Land softly. Switch legs.", sets: 3, reps: "6 each", restSeconds: 45),
                    Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, knees at 90°. Hold.", sets: 3, reps: "45 sec", restSeconds: 45),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "45 sec"),
                ],
                estimatedMinutes: 45,
                profileType: .mom,
                primaryFocus: .cardio,
                targetExerciseCount: 2
            ),
            Workout(
                name: "Dumbbells Only",
                summary: "Full body with just dumbbells. No other equipment needed.",
                exercises: [
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Hold one dumbbell at chest. Squat down, keep chest up.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
                    Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press dumbbells up from floor.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs.", sets: 3, reps: "8 each"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                ],
                estimatedMinutes: 35,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            Workout(
                name: "Bodyweight Only",
                summary: "No equipment needed. Strength and core at home.",
                exercises: [
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips.", sets: 3, reps: "12"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10"),
                    Exercise(name: "Jump Squats", equipment: .bodyweight, instructions: "Squat then jump up. Land softly.", sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up quickly.", sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately.", sets: 3, reps: "20 sec", restSeconds: 30),
                ],
                estimatedMinutes: 25,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            Workout(
                name: "Resistance Bands Only",
                summary: "Full band workout. No dumbbells or other equipment.",
                exercises: [
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                ],
                estimatedMinutes: 20,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            Workout(
                name: "Treadmill Session",
                summary: "Treadmill only. Walk or jog.",
                exercises: [
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min warm-up walk, then 15–20 min jog or brisk walk.", sets: 1, reps: "20–25 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "10 min easy walk, then 10 min brisk walk.", sets: 1, reps: "20 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min walk, 15 min jog, 5 min cool-down.", sets: 1, reps: "25 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "Intervals: 2 min walk, 3 min jog. Repeat 4 times.", sets: 1, reps: "20 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "Steady jog 20 min at comfortable pace.", sets: 1, reps: "20 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "Incline walk 15 min. Moderate incline.", sets: 1, reps: "15 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "Warm-up 5 min, then 20 min mixed walk/jog.", sets: 1, reps: "25 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "Long steady walk 30 min.", sets: 1, reps: "30 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "10 min walk, 10 min jog, 5 min walk.", sets: 1, reps: "25 min"),
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "Progressive: start slow, increase speed every 5 min.", sets: 1, reps: "20 min"),
                ],
                estimatedMinutes: 25,
                profileType: .mom,
                primaryFocus: .cardio,
                targetExerciseCount: 1
            ),
            Workout(
                name: "Exercise Bike Session",
                summary: "Exercise bike only. Steady or intervals.",
                exercises: [
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Steady pace 15–20 min, or intervals.", sets: 1, reps: "15–20 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Warm-up 5 min, steady 15 min, cool-down 5 min.", sets: 1, reps: "25 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Intervals: 2 min easy, 2 min hard. Repeat 5 times.", sets: 1, reps: "20 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Easy pace 25 min.", sets: 1, reps: "25 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Moderate pace 20 min.", sets: 1, reps: "20 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Progressive resistance: increase every 5 min.", sets: 1, reps: "20 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "10 min warm-up, 15 min tempo, 5 min cool-down.", sets: 1, reps: "30 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "30 min steady state.", sets: 1, reps: "30 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Sprint intervals: 30 sec hard, 90 sec easy. 8 rounds.", sets: 1, reps: "16 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Recovery ride: easy 20 min.", sets: 1, reps: "20 min"),
                ],
                estimatedMinutes: 20,
                profileType: .mom,
                primaryFocus: .cardio,
                targetExerciseCount: 1
            ),
            Workout(
                name: "Hoist V4 Elite Only",
                summary: "Full-body V4 Elite routine. All 42 machine exercises available in All exercises below.",
                exercises: [
                    Exercise(name: "Chest Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Sit with back on pad. Grip handles and press forward. Adjust back pad for comfort.", sets: 3, reps: "10–12"),
                    Exercise(name: "Lat Pulldown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use lat bar attachment. Sit or kneel; pull bar to upper chest. Squeeze shoulder blades.", sets: 3, reps: "10–12"),
                    Exercise(name: "Leg Extension (V4 Elite)", equipment: .hoistV4Elite, instructions: "Seated at leg station. Extend legs against pad. Adjust roller for leg length.", sets: 3, reps: "10–12"),
                    Exercise(name: "Leg Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Seated at leg station. Curl heels toward seat. Use ankle strap; adjust ROM as needed.", sets: 3, reps: "10–12"),
                    Exercise(name: "Shoulder Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use V4 press arm in overhead position. Press handles up. Adjust range-of-motion as needed.", sets: 3, reps: "10"),
                    Exercise(name: "Seated Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use lat bar or strap handles. Pull to hips or lower chest. Keep back straight.", sets: 3, reps: "10–12"),
                    Exercise(name: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust back pad. Feet on platform. Press and return; don't lock knees.", sets: 3, reps: "10–12"),
                    Exercise(name: "Bicep Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use curl bar attachment. Curl toward shoulders. Keep elbows stable.", sets: 3, reps: "10–12"),
                    Exercise(name: "Tricep Pushdown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use strap or bar on high pulley. Push down; keep elbows at sides.", sets: 3, reps: "10–12"),
                    Exercise(name: "Incline Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad to incline. Grasp articulating arm hand grips. Press.", sets: 3, reps: "10–12"),
                    Exercise(name: "High Pull (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and roller pads. Grasp both strap handles. Pull to upper chest.", sets: 3, reps: "10–12"),
                    Exercise(name: "Lateral Deltoid (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp strap handle from low pulley. Raise arm out to side.", sets: 3, reps: "10–12 each"),
                    Exercise(name: "Seated Rear Delt (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and roller pads. Grasp both strap handles. Pull back for rear delts.", sets: 3, reps: "10–12"),
                    Exercise(name: "Pectoral Fly (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm and back pad. Grasp both strap handles. Open and close arms (fly).", sets: 3, reps: "10–12"),
                    Exercise(name: "Stationary Calf Raise (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust back pad. Balls of feet on platform; raise heels.", sets: 3, reps: "15"),
                    Exercise(name: "Ab Crunch (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use ab strap attachment. Kneel or stand; crunch by pulling strap toward knees.", sets: 3, reps: "12–15"),
                    Exercise(name: "One Arm Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust pulley. Grasp strap handle. Row to hip; keep back straight.", sets: 3, reps: "10–12 each"),
                    Exercise(name: "Upright Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp both strap handles from low pulley. Pull up to chin.", sets: 3, reps: "10–12"),
                    Exercise(name: "Side Bends (V4 Elite)", equipment: .hoistV4Elite, instructions: "Adjust V4 press arm. Grasp strap handle from low pulley. Bend torso to the side.", sets: 3, reps: "12–15 each"),
                ],
                estimatedMinutes: 55,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            Workout(
                name: "Hoist V4 Elite + Leg Press + Bench",
                summary: "Full body using Hoist V4 Elite, standalone leg press, and bench. All exercises match your home setup.",
                exercises: [
                    Exercise(name: "Leg Press (Machine)", equipment: .legPressMachine, instructions: "Feet on footplate. Push through heels; don't lock knees.", sets: 3, reps: "10–12"),
                    Exercise(name: "Chest Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Sit with back on pad. Grip handles and press forward.", sets: 3, reps: "10–12"),
                    Exercise(name: "Lat Pulldown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use lat bar. Pull to upper chest. Squeeze shoulder blades.", sets: 3, reps: "10–12"),
                    Exercise(name: "Leg Extension (V4 Elite)", equipment: .hoistV4Elite, instructions: "Seated at leg station. Extend legs against pad.", sets: 3, reps: "10–12"),
                    Exercise(name: "Leg Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Seated at leg station. Curl heels toward seat.", sets: 3, reps: "10–12"),
                    Exercise(name: "Shoulder Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use V4 press arm overhead. Press handles up.", sets: 3, reps: "10"),
                    Exercise(name: "Seated Row (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use lat bar or strap. Pull to hips. Keep back straight.", sets: 3, reps: "10–12"),
                    Exercise(name: "Bicep Curl (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use curl bar. Curl toward shoulders.", sets: 3, reps: "10–12"),
                    Exercise(name: "Tricep Pushdown (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use strap or bar. Push down; elbows at sides.", sets: 3, reps: "10–12"),
                    Exercise(name: "Calf Raises (Leg Press)", equipment: .legPressMachine, instructions: "Balls of feet on platform; raise heels.", sets: 3, reps: "15"),
                    Exercise(name: "Bench Press", equipment: .bench, instructions: "Lie on bench. Lower bar or dumbbells to chest, press up.", sets: 3, reps: "8–10"),
                    Exercise(name: "Ab Crunch (V4 Elite)", equipment: .hoistV4Elite, instructions: "Use ab strap. Crunch by pulling toward knees.", sets: 3, reps: "12–15"),
                ],
                estimatedMinutes: 50,
                profileType: .mom,
                primaryFocus: .fullBody
            ),
            // Muscle-group focused workouts
            Workout(
                name: "Legs",
                summary: "Quads, hamstrings, and calves. Build strong legs.",
                exercises: [
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Hold one dumbbell at chest. Squat down, keep chest up.", sets: 3, reps: "10"),
                    Exercise(name: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "Feet shoulder-width. Push through heels.", sets: 3, reps: "10–12"),
                    Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs.", sets: 3, reps: "8 each"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, knees at 90°. Hold.", sets: 3, reps: "30 sec", restSeconds: 45),
                    Exercise(name: "Jump Squats", equipment: .bodyweight, instructions: "Squat then jump up. Land softly.", sets: 3, reps: "8", restSeconds: 45),
                ],
                estimatedMinutes: 35,
                profileType: .mom,
                primaryFocus: .legs
            ),
            Workout(
                name: "Glutes",
                summary: "Glute-focused. Bridges and hinges.",
                exercises: [
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Squeeze glutes at top.", sets: 3, reps: "12"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Hinge at hips, feel the stretch in hamstrings.", sets: 3, reps: "10"),
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Squat deep to engage glutes.", sets: 3, reps: "10"),
                    Exercise(name: "Hip thrust (bodyweight)", equipment: .bodyweight, instructions: "Back on bench or floor, drive through heels, squeeze glutes at top.", sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs. Long stride for glutes.", sets: 3, reps: "8 each"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Core and hip stability.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, focus on pushing through heels.", sets: 3, reps: "12"),
                    Exercise(name: "Stationary Leg Press (V4 Elite)", equipment: .hoistV4Elite, instructions: "High feet on platform for glute focus.", sets: 3, reps: "10–12"),
                ],
                estimatedMinutes: 28,
                profileType: .mom,
                primaryFocus: .glutes
            ),
            Workout(
                name: "Back",
                summary: "Rows and upper back. Posture and pull strength.",
                exercises: [
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Posterior chain.", sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Single-arm row. Squeeze shoulder blade.", sets: 3, reps: "10 each"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold at forehead height for upper traps.", sets: 3, reps: "15"),
                ],
                estimatedMinutes: 30,
                profileType: .mom,
                primaryFocus: .back
            ),
            Workout(
                name: "Chest",
                summary: "Presses and push. Chest and front delts.",
                exercises: [
                    Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press dumbbells up from floor.", sets: 3, reps: "10"),
                    Exercise(name: "Chest Press (V4 Elite)", equipment: .hoistV4Elite, sets: 3, reps: "10"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart. Antagonist.", sets: 3, reps: "15"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Core.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips.", sets: 3, reps: "12"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead. Triceps assist chest.", sets: 3, reps: "10"),
                ],
                estimatedMinutes: 28,
                profileType: .mom,
                primaryFocus: .chest
            ),
            Workout(
                name: "Shoulders",
                summary: "Overhead press and rear delts. Strong, stable shoulders.",
                exercises: [
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, instructions: "Press dumbbells overhead. Control the descent.", sets: 3, reps: "10"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart. Great for rear delts.", sets: 3, reps: "15"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench. Row to hip. Upper back.", sets: 3, reps: "10 each"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders. Front delts.", sets: 3, reps: "8–10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead.", sets: 3, reps: "10"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Stability.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10"),
                ],
                estimatedMinutes: 25,
                profileType: .mom,
                primaryFocus: .shoulders
            ),
            Workout(
                name: "Arms",
                summary: "Biceps and triceps. Curls and extensions.",
                exercises: [
                    Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench. Row to hip; also works biceps.", sets: 2, reps: "10 each"),
                    Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press up; triceps assist.", sets: 2, reps: "10"),
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart.", sets: 3, reps: "15"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders. Triceps.", sets: 3, reps: "8–10"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Full body balance.", sets: 3, reps: "12"),
                ],
                estimatedMinutes: 28,
                profileType: .mom,
                primaryFocus: .arms
            ),
            Workout(
                name: "Core",
                summary: "Abs and stability. Planks and anti-rotation.",
                exercises: [
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Engages core.", sets: 3, reps: "12"),
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side"),
                    Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10"),
                    Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats. Core bracing.", sets: 3, reps: "12"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Hinge at hips. Core stability.", sets: 3, reps: "10"),
                    Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side. Core rotation control.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up. Core and cardio.", sets: 3, reps: "25 sec", restSeconds: 30),
                ],
                estimatedMinutes: 22,
                profileType: .mom,
                primaryFocus: .core
            ),
        ]
    }
    
    static func buildDaughterWorkouts() -> [Workout] {
        [
            Workout(
                name: "Jump & Leg Power",
                summary: "Build vertical jump and explosive legs for serving and spiking.",
                exercises: [
                    Exercise(name: "Jump Squats", equipment: .bodyweight, instructions: "Squat down then jump up. Land softly.", sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "Box Step-Ups (or stairs)", equipment: .bodyweight, instructions: "Step up and down, drive through the standing leg.", sets: 3, reps: "10 each", restSeconds: 45),
                    Exercise(name: "Lateral Bounds", equipment: .bodyweight, instructions: "Jump side to side, land on one foot.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, instructions: "Rise onto toes; control the way down.", sets: 3, reps: "15", restSeconds: 30),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up quickly.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Skater Jumps", equipment: .bodyweight, instructions: "Jump side to side, land on one foot. Swing arms.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, knees at 90°. Hold.", sets: 3, reps: "30 sec", restSeconds: 45),
                    Exercise(name: "Single-Leg Hops", equipment: .bodyweight, instructions: "Hop on one foot forward or in place. Land softly. Switch legs.", sets: 3, reps: "6 each", restSeconds: 45),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side low and quick.", sets: 3, reps: "20 sec", restSeconds: 30),
                ],
                estimatedMinutes: 25,
                profileType: .daughterMiddleSchool
            ),
            Workout(
                name: "Arm & Shoulder for Serving",
                summary: "Shoulder stability and arm strength for jump serves and overhead work.",
                exercises: [
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart. Good for shoulder health.", sets: 3, reps: "15", restSeconds: 45),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, instructions: "Light weight. Press overhead with control.", sets: 3, reps: "10", restSeconds: 45),
                    Exercise(name: "Tricep Dips (chair)", equipment: .bodyweight, instructions: "Hands on chair, lower and push back up.", sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "Arm Circles", equipment: .bodyweight, instructions: "Small then large circles forward and back.", sets: 2, reps: "30 sec each", restSeconds: 20),
                    Exercise(name: "Push-ups (or knee push-ups)", equipment: .bodyweight, instructions: "Hands under shoulders, lower and push back up.", sets: 3, reps: "8–10"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
                ],
                estimatedMinutes: 20,
                profileType: .daughterMiddleSchool
            ),
            Workout(
                name: "Volleyball Agility & Conditioning",
                summary: "Quick feet and conditioning for matches.",
                exercises: [
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Fast feet, drive knees up.", sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side low and quick.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Jump Squats", equipment: .bodyweight, sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Cool-down Jog in Place", equipment: .bodyweight, instructions: "Easy pace 2 min.", sets: 1, reps: "2 min"),
                    Exercise(name: "Skater Jumps", equipment: .bodyweight, instructions: "Jump side to side, land on one foot. Swing arms.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Single-Leg Hops", equipment: .bodyweight, instructions: "Hop on one foot forward or in place. Land softly. Switch legs.", sets: 3, reps: "6 each", restSeconds: 45),
                    Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, knees at 90°. Hold.", sets: 3, reps: "30 sec", restSeconds: 45),
                    Exercise(name: "Lateral Bounds", equipment: .bodyweight, instructions: "Jump side to side, land on one foot.", sets: 3, reps: "8 each", restSeconds: 45),
                ],
                estimatedMinutes: 25,
                profileType: .daughterMiddleSchool
            ),
            Workout(
                name: "Core & Stability for Volleyball",
                summary: "Core strength and stability for passing, blocking, and injury prevention.",
                exercises: [
                    Exercise(name: "Dead Bug", equipment: .bodyweight, instructions: "On back, extend opposite arm and leg. Keep low back pressed down.", sets: 3, reps: "8 each side", restSeconds: 30),
                    Exercise(name: "Bird Dog", equipment: .bodyweight, instructions: "On all fours, extend one arm and opposite leg. Hold 2 sec.", sets: 3, reps: "8 each side", restSeconds: 30),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Superman", equipment: .bodyweight, instructions: "Lie face down, lift arms and legs off the floor. Hold 2 sec.", sets: 3, reps: "10", restSeconds: 30),
                    Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12", restSeconds: 30),
                    Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats. Core bracing.", sets: 3, reps: "12"),
                    Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side. Core rotation control.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up. Core and cardio.", sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, instructions: "Rise onto toes; control the way down.", sets: 3, reps: "15", restSeconds: 30),
                ],
                estimatedMinutes: 22,
                profileType: .daughterMiddleSchool
            ),
            Workout(
                name: "Reaction & Quick Feet",
                summary: "Explosive lateral movement and reaction time for court coverage.",
                exercises: [
                    Exercise(name: "Lateral Shuffles", equipment: .bodyweight, instructions: "Shuffle side to side low and quick.", sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Skater Jumps", equipment: .bodyweight, instructions: "Jump side to side, land on one foot. Swing arms.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Fast feet, drive knees up.", sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Single-Leg Hops", equipment: .bodyweight, instructions: "Hop on one foot forward or in place. Land softly. Switch legs.", sets: 3, reps: "6 each", restSeconds: 45),
                    Exercise(name: "Mountain Climbers", equipment: .bodyweight, instructions: "High plank; drive knees toward chest alternately.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Cool-down March", equipment: .bodyweight, instructions: "Easy march in place 2 min.", sets: 1, reps: "2 min"),
                    Exercise(name: "Jump Squats", equipment: .bodyweight, instructions: "Squat then jump up. Land softly.", sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "Lateral Bounds", equipment: .bodyweight, instructions: "Jump side to side, land on one foot.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "25 sec", restSeconds: 30),
                    Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, knees at 90°. Hold.", sets: 3, reps: "30 sec", restSeconds: 45),
                ],
                estimatedMinutes: 28,
                profileType: .daughterMiddleSchool
            ),
            Workout(
                name: "Jump & Block Power",
                summary: "Vertical jump and leg endurance for blocking and attacking.",
                exercises: [
                    Exercise(name: "Wall Sits", equipment: .bodyweight, instructions: "Back against wall, knees at 90°. Hold.", sets: 3, reps: "30 sec", restSeconds: 45),
                    Exercise(name: "Jump Squats", equipment: .bodyweight, instructions: "Squat then jump up. Land softly.", sets: 3, reps: "8", restSeconds: 45),
                    Exercise(name: "Box Step-Ups (or stairs)", equipment: .bodyweight, instructions: "Step up and down, drive through standing leg.", sets: 3, reps: "10 each", restSeconds: 45),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, instructions: "Rise onto toes; control the way down.", sets: 3, reps: "15", restSeconds: 30),
                    Exercise(name: "Lateral Bounds", equipment: .bodyweight, instructions: "Jump side to side, land on one foot.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Skater Jumps", equipment: .bodyweight, instructions: "Jump side to side, land on one foot. Swing arms.", sets: 3, reps: "8 each", restSeconds: 45),
                    Exercise(name: "Single-Leg Hops", equipment: .bodyweight, instructions: "Hop on one foot forward or in place. Land softly. Switch legs.", sets: 3, reps: "6 each", restSeconds: 45),
                    Exercise(name: "High Knees", equipment: .bodyweight, instructions: "Run in place, drive knees up quickly.", sets: 3, reps: "20 sec", restSeconds: 30),
                    Exercise(name: "Squats", equipment: .bodyweight, instructions: "Bodyweight squats, chest up.", sets: 3, reps: "12"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "25 sec", restSeconds: 30),
                ],
                estimatedMinutes: 26,
                profileType: .daughterMiddleSchool
            ),
        ]
    }
    
    static func buildKid7Workouts() -> [Workout] {
        [
            Workout(
                name: "Animal Moves",
                summary: "Jump like a frog, crawl like a bear, and more!",
                exercises: [
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Pretend you're a frog! Squat down and jump forward. Land softly.", sets: 1, reps: "8 jumps", restSeconds: 20),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "On hands and feet, crawl like a bear. Keep your knees off the floor!", sets: 1, reps: "30 sec", restSeconds: 20),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop around the room like a bunny. Small, quick hops!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Sit, put hands behind you, and walk on hands and feet like a crab.", sets: 1, reps: "20 sec", restSeconds: 20),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings. Fly around the room!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier. Lift those knees!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs out like a star. Land softly!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Can you count to 10? Switch feet!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a line, putting one foot right in front of the other.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Clap, jump! Repeat.", sets: 1, reps: "8", restSeconds: 0),
                ],
                estimatedMinutes: 12,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Dance & Stretch",
                summary: "Fun music moves and gentle stretching.",
                exercises: [
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Put on your favorite song and dance however you like!", sets: 1, reps: "2 min", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Stand tall and reach your arms up high. Stretch side to side.", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Gently bend and try to touch your toes. No bouncing!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, put feet together, and gently flap your knees like butterfly wings.", sets: 1, reps: "30 sec", restSeconds: 0),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle slowly. Stop if you feel dizzy!", sets: 1, reps: "3 spins", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier to the beat!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Repeat!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Can you count to 10?", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs like a star!", sets: 1, reps: "6", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop in place or forward like a bunny.", sets: 1, reps: "15 sec", restSeconds: 10),
                ],
                estimatedMinutes: 8,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Balance & Coordination",
                summary: "Practice balance and have fun!",
                exercises: [
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Can you count to 10? Switch feet!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a line, putting one foot right in front of the other.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs out like a star. Land softly!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "On hands and feet, crawl like a bear. Keep your knees off the floor!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Sit, put hands behind you, and walk on hands and feet like a crab.", sets: 1, reps: "20 sec", restSeconds: 20),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Squat down and jump forward. Land softly like a frog!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier. Lift those knees!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop in place or forward like a bunny.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Repeat!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach your arms up high. Stretch side to side.", sets: 1, reps: "30 sec", restSeconds: 10),
                ],
                estimatedMinutes: 10,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Jump & Run Fun",
                summary: "Get your heart pumping with jumps and running in place.",
                exercises: [
                    Exercise(name: "Jumping jacks", equipment: .bodyweight, instructions: "Jump and spread your legs while your arms go up. Then bring them back together!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Run in place", equipment: .bodyweight, instructions: "Run without going anywhere. Pump your arms!", sets: 1, reps: "30 sec", restSeconds: 20),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs like a star. Land softly!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "High knees", equipment: .bodyweight, instructions: "Run in place and lift your knees up high!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier. Lift those knees!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop in place or forward like a bunny.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Repeat!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach your arms up high. Breathe!", sets: 1, reps: "20 sec", restSeconds: 10),
                ],
                estimatedMinutes: 8,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Superhero Training",
                summary: "Train like a superhero. Strong and brave!",
                exercises: [
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up like you're flying. Stretch side to side!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "On hands and feet, crawl like a bear. You're strong!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread out like a star. Pow!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a superhero army. Lift those knees!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Squat and jump forward like a superhero leap!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Balance like a hero. Switch feet!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like you're flying to save the day!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a straight line. One foot in front of the other.", sets: 1, reps: "20 sec", restSeconds: 15),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Stretch & Breathe",
                summary: "Gentle stretches and calm breathing.",
                exercises: [
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Stand tall. Reach your arms up high. Stretch side to side.", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Gently bend and try to touch your toes. No bouncing!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, put feet together, and gently flap your knees like butterfly wings.", sets: 1, reps: "30 sec", restSeconds: 0),
                    Exercise(name: "Hug yourself", equipment: .bodyweight, instructions: "Wrap your arms around yourself and give a gentle squeeze. Breathe.", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Arm circles", equipment: .bodyweight, instructions: "Make small circles with your arms. Forward, then backward.", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March slowly. Nice and easy.", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle slowly. Stop if you feel dizzy!", sets: 1, reps: "3 spins", restSeconds: 10),
                    Exercise(name: "Blow bubbles", equipment: .bodyweight, instructions: "Take a deep breath in. Blow out slowly like blowing bubbles.", sets: 1, reps: "3 breaths", restSeconds: 0),
                ],
                estimatedMinutes: 7,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Dinosaur Adventure",
                summary: "Move like dinosaurs. Roar!",
                exercises: [
                    Exercise(name: "Stomp like a dinosaur", equipment: .bodyweight, instructions: "Stomp your feet. Big, heavy steps. Roar!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl on hands and feet like a dinosaur. Keep knees off the floor!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Jump like a little dinosaur. Land softly!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a dinosaur parade!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach your arms up like a tall dinosaur. Stretch!", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread out. Rawr!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk carefully like crossing a river. One foot in front of the other.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a tiny dino. Quick hops!", sets: 1, reps: "15 sec", restSeconds: 15),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Ocean Explorer",
                summary: "Swim, crab walk, and move like sea creatures!",
                exercises: [
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Sit, hands behind you, walk like a crab!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings. Fly over the ocean!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread like a starfish!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like you're walking on the beach!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Balance on a wobbly boat! Switch feet.", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a line like a balance beam over water.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a little fish jumping!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up like the sun above the ocean. Stretch!", sets: 1, reps: "25 sec", restSeconds: 10),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Space Mission",
                summary: "Blast off and move like you're in space!",
                exercises: [
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread like a star in the sky!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin like you're floating in space. Stop if dizzy!", sets: 1, reps: "3 spins", restSeconds: 15),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up to touch the stars!", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a space walk. Slow and floaty!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl like exploring a new planet!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop in low gravity. Small bounces!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Balance on one foot. You're on the moon! Switch feet.", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. Blast off!", sets: 1, reps: "8", restSeconds: 0),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Jungle Safari",
                summary: "Move like animals in the jungle!",
                exercises: [
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl like a bear through the jungle!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Jump like a frog from leaf to leaf!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap like a parrot. Fly through the trees!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Walk like a crab by the river!", sets: 1, reps: "20 sec", restSeconds: 20),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March through the jungle. Lift those knees!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like a monkey! Spread arms and legs.", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a little jungle animal!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk carefully on a narrow path. One foot in front of the other.", sets: 1, reps: "20 sec", restSeconds: 15),
                ],
                estimatedMinutes: 10,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Quick Energy Boost",
                summary: "Short and fun. Get moving!",
                exercises: [
                    Exercise(name: "Jumping jacks", equipment: .bodyweight, instructions: "Jump and spread. Then together. Go!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Run in place", equipment: .bodyweight, instructions: "Run as fast as you can without going anywhere!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread like a star!", sets: 1, reps: "6", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Lift those knees!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap, jump. Repeat!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up high. Stretch!", sets: 1, reps: "20 sec", restSeconds: 10),
                ],
                estimatedMinutes: 5,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Coordination Challenge",
                summary: "Practice balance and tricky moves!",
                exercises: [
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a line. One foot right in front of the other.", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Can you count to 10? Switch!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Hop on one foot", equipment: .bodyweight, instructions: "Hop on your left foot. Then try your right!", sets: 1, reps: "10 sec each", restSeconds: 15),
                    Exercise(name: "Side steps", equipment: .bodyweight, instructions: "Step to the side. Then step back. Keep going!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Nice and steady!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread. Land with control!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Can you keep the rhythm?", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Tiptoe walk", equipment: .bodyweight, instructions: "Walk on your tiptoes. Quiet as a mouse!", sets: 1, reps: "20 sec", restSeconds: 10),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Music & Moves",
                summary: "Dance and move to the beat!",
                exercises: [
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Put on a song and dance however you like!", sets: 1, reps: "1 min", restSeconds: 0),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March to the beat. Left, right, left, right!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap to the beat, then jump. Repeat!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread when the music goes boom!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin to the music. Stop if you feel dizzy!", sets: 1, reps: "3 spins", restSeconds: 10),
                    Exercise(name: "Wiggle dance", equipment: .bodyweight, instructions: "Wiggle your whole body. Arms, hips, everything!", sets: 1, reps: "20 sec", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up and sway side to side.", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop to the music like a bunny!", sets: 1, reps: "15 sec", restSeconds: 15),
                ],
                estimatedMinutes: 7,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Strong & Steady",
                summary: "Build strength with animal moves!",
                exercises: [
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl on hands and feet. Keep knees off the floor. You're strong!", sets: 1, reps: "30 sec", restSeconds: 25),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Sit, hands behind you. Walk like a crab!", sets: 1, reps: "25 sec", restSeconds: 25),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Squat and jump. Strong legs!", sets: 1, reps: "8 jumps", restSeconds: 20),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Keep it steady!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Balance! Switch.", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up. Stretch your arms and back.", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread. Land softly!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a line. Steady steps!", sets: 1, reps: "20 sec", restSeconds: 15),
                ],
                estimatedMinutes: 10,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Morning Wake-Up",
                summary: "Start the day with gentle, fun movement.",
                exercises: [
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach way up. Stretch and yawn!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Arm circles", equipment: .bodyweight, instructions: "Circle your arms forward. Then backward.", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March slowly. Wake up those legs!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Gently bend and touch your toes. No bouncing!", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "A few star jumps to get energy!", sets: 1, reps: "6", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny. Good morning!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Flap your knees like a butterfly.", sets: 1, reps: "25 sec", restSeconds: 0),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. You're awake!", sets: 1, reps: "6", restSeconds: 0),
                ],
                estimatedMinutes: 7,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Copy the Leader",
                summary: "Do what the leader does. Great for playing with a grown-up!",
                exercises: [
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "Leader marches. You copy! Lift those knees!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Leader does star jumps. You copy!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Leader reaches up. You copy! Stretch!", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Leader crawls like a bear. You copy!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Leader hops like a bunny. You copy!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Leader claps and jumps. You copy!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Leader stands on one foot. You copy! Switch!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Leader flaps like a bird. You copy!", sets: 1, reps: "20 sec", restSeconds: 15),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Quiet & Calm",
                summary: "Slow, gentle moves. Perfect before bed or when you need to settle.",
                exercises: [
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up slowly. Breathe in. Lower. Breathe out.", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Gently flap your knees. Relax.", sets: 1, reps: "30 sec", restSeconds: 0),
                    Exercise(name: "Hug yourself", equipment: .bodyweight, instructions: "Wrap your arms around yourself. Take a deep breath.", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Bend slowly. Touch your toes. No bouncing.", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March very slowly. Nice and easy.", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Blow bubbles", equipment: .bodyweight, instructions: "Breathe in. Blow out slowly like blowing bubbles.", sets: 1, reps: "3 breaths", restSeconds: 0),
                    Exercise(name: "Arm circles", equipment: .bodyweight, instructions: "Slow, small circles with your arms.", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin one time, very slowly. Stop. Breathe.", sets: 1, reps: "1 spin", restSeconds: 10),
                ],
                estimatedMinutes: 6,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Speed Round",
                summary: "Quick moves. How fast can you go?",
                exercises: [
                    Exercise(name: "Run in place", equipment: .bodyweight, instructions: "Run as fast as you can! Go!", sets: 1, reps: "20 sec", restSeconds: 20),
                    Exercise(name: "Jumping jacks", equipment: .bodyweight, instructions: "As many as you can. Fast!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "High knees", equipment: .bodyweight, instructions: "Knees up high. Fast!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread. Quick!", sets: 1, reps: "6", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop as fast as a bunny!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March fast. Lift those knees!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. Quick!", sets: 1, reps: "8", restSeconds: 0),
                ],
                estimatedMinutes: 6,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Under the Sea",
                summary: "Move like fish, crabs, and ocean friends!",
                exercises: [
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Walk like a crab on the beach!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap like a seagull flying over the water!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like a starfish!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like walking in the sand!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Balance on one foot like standing on a rock. Switch!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a little fish jumping out of the water!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk on a narrow bridge over the sea!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up like the sun above the ocean!", sets: 1, reps: "25 sec", restSeconds: 10),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Treasure Hunt Moves",
                summary: "Get ready for an adventure. Move like an explorer!",
                exercises: [
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl through the jungle to find treasure!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk carefully across a wobbly bridge!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Balance on one foot on a stone. Switch!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump for joy when you find treasure!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March through the forest!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Jump over logs like a frog!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. We found it!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up and celebrate!", sets: 1, reps: "20 sec", restSeconds: 10),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Rainy Day Fun",
                summary: "No going outside? Move and play inside!",
                exercises: [
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Put on music and dance in the living room!", sets: 1, reps: "1 min", restSeconds: 0),
                    Exercise(name: "Jumping jacks", equipment: .bodyweight, instructions: "Jump and spread. Get the wiggles out!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl around the room like a bear!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March around the couch!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Star jumps. You're a star!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop from one end of the room to the other!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit and do the butterfly. Relax.", sets: 1, reps: "25 sec", restSeconds: 0),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. Rain, rain, go away!", sets: 1, reps: "8", restSeconds: 0),
                ],
                estimatedMinutes: 8,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Super Stretchy",
                summary: "Stretch your whole body. Feel good!",
                exercises: [
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up. Stretch to the left. To the right.", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Bend and touch your toes. Hold. No bouncing!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Flap your knees like a butterfly.", sets: 1, reps: "30 sec", restSeconds: 0),
                    Exercise(name: "Arm circles", equipment: .bodyweight, instructions: "Big circles with your arms. Forward. Then backward.", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Hug yourself", equipment: .bodyweight, instructions: "Give yourself a big stretch. Squeeze!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March slowly. Keep stretching your legs.", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin once. Stretch your whole body!", sets: 1, reps: "2 spins", restSeconds: 10),
                    Exercise(name: "Blow bubbles", equipment: .bodyweight, instructions: "Deep breath in. Blow out slowly. Relax.", sets: 1, reps: "3 breaths", restSeconds: 0),
                ],
                estimatedMinutes: 7,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Ninja Training",
                summary: "Move quietly and quickly. Like a ninja!",
                exercises: [
                    Exercise(name: "Tiptoe walk", equipment: .bodyweight, instructions: "Walk on tiptoes. Silent like a ninja!", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl low and quiet. Sneak!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Balance on one foot. Ninjas have great balance! Switch.", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a straight line. Steady!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and land softly. Ninja landing!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March quietly. Shh!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Jump forward. Land softly!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Quick clap, quick jump. Ninja speed!", sets: 1, reps: "8", restSeconds: 0),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Farm Friends",
                summary: "Move like animals on the farm!",
                exercises: [
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny in the garden!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap like a chicken. Buck buck!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bear crawl", equipment: .bodyweight, instructions: "Crawl like a bear. Grr!", sets: 1, reps: "25 sec", restSeconds: 20),
                    Exercise(name: "Frog jumps", equipment: .bodyweight, instructions: "Jump like a frog by the pond!", sets: 1, reps: "6 jumps", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like the farmer walking to the barn!", sets: 1, reps: "30 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like you're spreading hay!", sets: 1, reps: "8", restSeconds: 15),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Walk like a crab by the creek!", sets: 1, reps: "20 sec", restSeconds: 20),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up like the sun over the farm!", sets: 1, reps: "25 sec", restSeconds: 10),
                ],
                estimatedMinutes: 9,
                profileType: .child7,
                targetExerciseCount: 5
            ),
        ]
    }
    
    static func buildKid5Workouts() -> [Workout] {
        [
            Workout(
                name: "Super Simple Moves",
                summary: "Easy, fun moves. You've got this!",
                exercises: [
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny! Small hops are perfect.", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach your arms up to the sky. Stretch!", sets: 1, reps: "10 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier. Lift those knees!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Sit and stand", equipment: .bodyweight, instructions: "Sit on the floor, then stand up. Do it a few times!", sets: 1, reps: "5", restSeconds: 10),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings. Fly around!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Repeat!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle slowly. Stop if you feel dizzy!", sets: 1, reps: "2 spins", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs like a star!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Can you count to 5? Switch!", sets: 1, reps: "5 sec each foot", restSeconds: 10),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet like a bear. Roar!", sets: 1, reps: "15 sec", restSeconds: 15),
                ],
                estimatedMinutes: 8,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Animal Fun",
                summary: "Move like animals. So much fun!",
                exercises: [
                    Exercise(name: "Frog jump", equipment: .bodyweight, instructions: "Squat and give a little jump. You're a frog!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet like a bear. Roar!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings. Fly around the room!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny! Small hops.", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Sit, hands behind you, walk like a crab!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier. Lift those knees!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs like a star!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Repeat!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach your arms up to the sky!", sets: 1, reps: "10 sec", restSeconds: 10),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle slowly. Stop if dizzy!", sets: 1, reps: "2 spins", restSeconds: 10),
                ],
                estimatedMinutes: 6,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Dance Party",
                summary: "Dance to the music. You're awesome!",
                exercises: [
                    Exercise(name: "Dance!", equipment: .bodyweight, instructions: "Play a song and dance. Any way you want!", sets: 1, reps: "1 min", restSeconds: 0),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle slowly. Stop if you feel dizzy!", sets: 1, reps: "3 spins", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Clap, jump! Repeat.", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach your arms up high. Stretch!", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March to the beat!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs like a star!", sets: 1, reps: "6", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny to the music!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings. Fly!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together, flap your knees like butterfly wings.", sets: 1, reps: "20 sec", restSeconds: 0),
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Dance however you like! You're awesome!", sets: 1, reps: "1 min", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Little Bouncers",
                summary: "Lots of hopping and jumping. So fun!",
                exercises: [
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny! Small hops.", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread like a star!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Repeat!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a soldier!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach your arms to the sky!", sets: 1, reps: "10 sec", restSeconds: 10),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your wings. Fly!", sets: 1, reps: "15 sec", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Animal Parade",
                summary: "Be a bear, a frog, a bunny. Go!",
                exercises: [
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet like a bear. Roar!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Frog jump", equipment: .bodyweight, instructions: "Squat and give a little jump. Ribbit!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny!", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Hands behind you. Walk like a crab!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March in the parade!", sets: 1, reps: "20 sec", restSeconds: 15),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Reach & Stretch",
                summary: "Reach up, bend down. Feel good!",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach your arms up. Stretch!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Bend and touch your toes. Gentle!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Flap your knees!", sets: 1, reps: "20 sec", restSeconds: 0),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Nice and easy!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle. Stop if dizzy!", sets: 1, reps: "2 spins", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap, jump. Again!", sets: 1, reps: "6", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Sunny Day Moves",
                summary: "Happy moves for a happy day!",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up to the sun!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like a star!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March in the sunshine!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a happy bunny!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap like a bird in the sky!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. Yay!", sets: 1, reps: "6", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Quiet Time",
                summary: "Slow, gentle moves. Calm and cozy.",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up slowly. Breathe.", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Gentle flap.", sets: 1, reps: "25 sec", restSeconds: 0),
                    Exercise(name: "Hug yourself", equipment: .bodyweight, instructions: "Give yourself a hug. Squeeze!", sets: 1, reps: "10 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March very slowly.", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin one time. Slow!", sets: 1, reps: "1 spin", restSeconds: 10),
                    Exercise(name: "Blow bubbles", equipment: .bodyweight, instructions: "Breathe in. Blow out like bubbles.", sets: 1, reps: "3 breaths", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Dinosaur Stomp",
                summary: "Stomp and roar like a dinosaur!",
                exercises: [
                    Exercise(name: "Stomp like a dinosaur", equipment: .bodyweight, instructions: "Stomp your feet. Big steps. Roar!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet. Rawr!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a dino!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump. Spread out!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up like a tall dinosaur!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a little dino!", sets: 1, reps: "10 sec", restSeconds: 15),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Follow the Leader",
                summary: "Do what the leader does. So fun with a grown-up!",
                exercises: [
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "Leader marches. You copy!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Leader claps and jumps. You copy!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Leader reaches up. You copy!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Leader hops. You copy!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Leader does star jumps. You copy!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Leader flaps. You copy!", sets: 1, reps: "15 sec", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Wiggle & Giggle",
                summary: "Wiggle your body. Giggle. Repeat!",
                exercises: [
                    Exercise(name: "Wiggle dance", equipment: .bodyweight, instructions: "Wiggle your arms. Wiggle your hips!", sets: 1, reps: "20 sec", restSeconds: 0),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March and wiggle!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap, jump, giggle!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin. Maybe giggle! Stop if dizzy.", sets: 1, reps: "2 spins", restSeconds: 10),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop and wiggle!", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up. Stretch and smile!", sets: 1, reps: "12 sec", restSeconds: 10),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Ocean Friends",
                summary: "Move like crabs and fish!",
                exercises: [
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Walk like a crab! Hands behind you.", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap like a seagull!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like a starfish!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March on the beach!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a fish jumping!", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up to the sun!", sets: 1, reps: "12 sec", restSeconds: 10),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Balance Fun",
                summary: "Stand on one foot. Walk in a line. You can do it!",
                exercises: [
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Count to 5! Switch.", sets: 1, reps: "5 sec each foot", restSeconds: 10),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk. One foot in front of the other!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Steady!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and land softly!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Sit and stand", equipment: .bodyweight, instructions: "Sit down. Stand up. Again!", sets: 1, reps: "5", restSeconds: 10),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up. Balance!", sets: 1, reps: "10 sec", restSeconds: 10),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Super Short Burst",
                summary: "Quick! Five minutes of fun.",
                exercises: [
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop! Go!", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap, jump!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up!", sets: 1, reps: "10 sec", restSeconds: 10),
                ],
                estimatedMinutes: 4,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Good Morning Moves",
                summary: "Wake up your body. Good morning!",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up. Stretch. Good morning!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Wake up those legs!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Arm circles", equipment: .bodyweight, instructions: "Circle your arms. Small circles!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop. You're awake!", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. Morning!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "A few star jumps. Energy!", sets: 1, reps: "5", restSeconds: 15),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Bedtime Stretch",
                summary: "Calm moves before bed. Sweet dreams!",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up slowly. Breathe.", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Gentle flap. Relax.", sets: 1, reps: "25 sec", restSeconds: 0),
                    Exercise(name: "Hug yourself", equipment: .bodyweight, instructions: "Give yourself a cozy hug.", sets: 1, reps: "10 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March very slowly. Shh.", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "Blow bubbles", equipment: .bodyweight, instructions: "Breathe in. Blow out slowly. Calm.", sets: 1, reps: "3 breaths", restSeconds: 0),
                ],
                estimatedMinutes: 4,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Farm Fun",
                summary: "Move like farm animals!",
                exercises: [
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a bunny in the garden!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap like a chicken!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk like a bear. Roar!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Frog jump", equipment: .bodyweight, instructions: "Jump like a frog!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March to the barn!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up like the sun!", sets: 1, reps: "12 sec", restSeconds: 10),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Space Adventure",
                summary: "Blast off and float like in space!",
                exercises: [
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like a star!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin like you're in space. Stop if dizzy!", sets: 1, reps: "2 spins", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach for the stars!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March like a space walk!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop in low gravity!", sets: 1, reps: "10 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. Blast off!", sets: 1, reps: "6", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Rainbow Moves",
                summary: "Colorful, happy moves. Every color!",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up to the rainbow!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump like a star!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March under the rainbow!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your wings. Fly!", sets: 1, reps: "15 sec", restSeconds: 0),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump. So fun!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop like a happy bunny!", sets: 1, reps: "10 sec", restSeconds: 15),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Quiet Ninja",
                summary: "Tiptoe and move quietly. Shh!",
                exercises: [
                    Exercise(name: "Tiptoe walk", equipment: .bodyweight, instructions: "Walk on tiptoes. Quiet!", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March quietly. Shh!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Balance! Switch.", sets: 1, reps: "5 sec each foot", restSeconds: 10),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet. Quiet like a ninja!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up. Steady!", sets: 1, reps: "10 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and land softly!", sets: 1, reps: "5", restSeconds: 15),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Happy Dance",
                summary: "Dance and smile. You're awesome!",
                exercises: [
                    Exercise(name: "Dance!", equipment: .bodyweight, instructions: "Play a song. Dance!", sets: 1, reps: "45 sec", restSeconds: 0),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump to the music!", sets: 1, reps: "8", restSeconds: 0),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March to the beat!", sets: 1, reps: "25 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Star jumps. Fun!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Reach up. Dance with your arms!", sets: 1, reps: "20 sec", restSeconds: 10),
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Dance however you want. You're awesome!", sets: 1, reps: "45 sec", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Strong Kids",
                summary: "Bear walk, crab walk. You're strong!",
                exercises: [
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet. You're strong!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Crab walk", equipment: .bodyweight, instructions: "Hands behind you. Walk like a crab!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Strong legs!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Frog jump", equipment: .bodyweight, instructions: "Squat and jump. Strong!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up. Strong arms!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump. You're strong!", sets: 1, reps: "5", restSeconds: 15),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Copy Cat",
                summary: "Copy the moves. Can you do it?",
                exercises: [
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "Copy: march!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Copy: star jump!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Copy: hop!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Copy: reach!", sets: 1, reps: "12 sec", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Copy: clap and jump!", sets: 1, reps: "6", restSeconds: 0),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Copy: flap!", sets: 1, reps: "15 sec", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Indoor Play",
                summary: "No outside? Play inside!",
                exercises: [
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Dance in the living room!", sets: 1, reps: "1 min", restSeconds: 0),
                    Exercise(name: "Bunny hops", equipment: .bodyweight, instructions: "Hop around the room!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March around the couch!", sets: 1, reps: "25 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Star jumps. Fun!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Crawl like a bear!", sets: 1, reps: "12 sec", restSeconds: 15),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap and jump!", sets: 1, reps: "6", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
            Workout(
                name: "Stretch & Smile",
                summary: "Stretch your body. Smile!",
                exercises: [
                    Exercise(name: "Reach up high", equipment: .bodyweight, instructions: "Reach up. Stretch. Smile!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Touch your toes. Gentle!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, feet together. Flap your knees!", sets: 1, reps: "25 sec", restSeconds: 0),
                    Exercise(name: "Arm circles", equipment: .bodyweight, instructions: "Circle your arms. Small circles!", sets: 1, reps: "15 sec", restSeconds: 10),
                    Exercise(name: "March in place", equipment: .bodyweight, instructions: "March. Nice and easy!", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Blow bubbles", equipment: .bodyweight, instructions: "Breathe in. Blow out. Smile!", sets: 1, reps: "3 breaths", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5,
                targetExerciseCount: 5
            ),
        ]
    }
}
