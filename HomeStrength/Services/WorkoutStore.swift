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
    
    /// Library of exercises to choose from when designing a workout. Filter by equipment.
    static let exerciseLibrary: [Exercise] = buildExerciseLibrary()
    
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
    
    /// Workouts for the given profile, optionally filtered by equipment.
    func workouts(for profileType: UserProfileType, using equipment: Set<Equipment> = []) -> [Workout] {
        var list = workouts.filter { $0.profileType == profileType }
        if !equipment.isEmpty {
            list = list.filter { workout in
                workout.exercises.allSatisfy { equipment.contains($0.equipment) }
            }
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
    
    static func exercises(using equipment: Set<Equipment>) -> [Exercise] {
        if equipment.isEmpty { return exerciseLibrary }
        return exerciseLibrary.filter { equipment.contains($0.equipment) }
    }
    
    static func buildExerciseLibrary() -> [Exercise] {
        [
            Exercise(name: "Goblet Squat", equipment: .dumbbells, instructions: "Hold one dumbbell at chest. Squat down, keep chest up.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Row", equipment: .dumbbells, instructions: "Support on bench or chair. Row to hip.", sets: 3, reps: "10 each"),
            Exercise(name: "Dumbbell Floor Press", equipment: .dumbbells, instructions: "On back, press dumbbells up from floor.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
            Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
            Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs.", sets: 3, reps: "8 each"),
            Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
            Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
            Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
            Exercise(name: "Leg Press", equipment: .homeGym, instructions: "Feet shoulder-width. Push through heels.", sets: 3, reps: "10–12"),
            Exercise(name: "Chest Press", equipment: .homeGym, sets: 3, reps: "10"),
            Exercise(name: "Glute Bridge", equipment: .bodyweight, instructions: "Feet flat, lift hips. Optional: band above knees.", sets: 3, reps: "12"),
            Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
            Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
            Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min warm-up walk, then 15–20 min jog or brisk walk.", sets: 1, reps: "20–25 min"),
            Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Steady pace 15–20 min, or intervals.", sets: 1, reps: "15–20 min"),
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
                ],
                estimatedMinutes: 35,
                profileType: .mom
            ),
            Workout(
                name: "Full Body B",
                summary: "Home gym + dumbbells. Presses and legs.",
                exercises: [
                    Exercise(name: "Leg Press", equipment: .homeGym, instructions: "Feet shoulder-width. Push through heels.", sets: 3, reps: "10–12"),
                    Exercise(name: "Chest Press", equipment: .homeGym, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Romanian Deadlift", equipment: .dumbbells, instructions: "Slight bend in knees, hinge at hips.", sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, instructions: "One dumbbell overhead or use band.", sets: 3, reps: "10"),
                    Exercise(name: "Plank", equipment: .bodyweight, sets: 3, reps: "30 sec"),
                ],
                estimatedMinutes: 40,
                profileType: .mom
            ),
            Workout(
                name: "Upper Body",
                summary: "Dumbbells, bands, and home gym.",
                exercises: [
                    Exercise(name: "Chest Press", equipment: .homeGym, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Row", equipment: .dumbbells, sets: 3, reps: "10 each"),
                    Exercise(name: "Dumbbell Shoulder Press", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Bicep Curl", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Tricep Extension", equipment: .dumbbells, sets: 3, reps: "10"),
                ],
                estimatedMinutes: 35,
                profileType: .mom
            ),
            Workout(
                name: "Lower Body",
                summary: "Legs with home gym, dumbbells, and bands.",
                exercises: [
                    Exercise(name: "Leg Press", equipment: .homeGym, sets: 3, reps: "10–12"),
                    Exercise(name: "Goblet Squat", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Dumbbell Lunge", equipment: .dumbbells, instructions: "Alternate legs.", sets: 3, reps: "8 each"),
                    Exercise(name: "Romanian Deadlift", equipment: .dumbbells, sets: 3, reps: "10"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                    Exercise(name: "Calf Raises", equipment: .bodyweight, sets: 3, reps: "15"),
                ],
                estimatedMinutes: 40,
                profileType: .mom
            ),
            Workout(
                name: "Cardio",
                summary: "Treadmill and exercise bike. Ease in, then push.",
                exercises: [
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min warm-up walk, then 15–20 min jog or brisk walk.", sets: 1, reps: "20–25 min"),
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Steady pace 15–20 min, or intervals.", sets: 1, reps: "15–20 min"),
                ],
                estimatedMinutes: 45,
                profileType: .mom
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
                ],
                estimatedMinutes: 35,
                profileType: .mom
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
                ],
                estimatedMinutes: 25,
                profileType: .mom
            ),
            Workout(
                name: "Resistance Bands Only",
                summary: "Full band workout. No dumbbells or other equipment.",
                exercises: [
                    Exercise(name: "Band Pull-Apart", equipment: .resistanceBands, instructions: "Hold band in front, pull apart squeezing shoulder blades.", sets: 3, reps: "15"),
                    Exercise(name: "Band Chest Stretch / Push", equipment: .resistanceBands, sets: 2, reps: "12"),
                    Exercise(name: "Band Glute Bridge", equipment: .resistanceBands, sets: 3, reps: "12"),
                ],
                estimatedMinutes: 20,
                profileType: .mom
            ),
            Workout(
                name: "Treadmill Session",
                summary: "Treadmill only. Walk or jog.",
                exercises: [
                    Exercise(name: "Treadmill Walk/Jog", equipment: .treadmill, instructions: "5 min warm-up walk, then 15–20 min jog or brisk walk.", sets: 1, reps: "20–25 min"),
                ],
                estimatedMinutes: 25,
                profileType: .mom
            ),
            Workout(
                name: "Exercise Bike Session",
                summary: "Exercise bike only. Steady or intervals.",
                exercises: [
                    Exercise(name: "Exercise Bike", equipment: .exerciseBike, instructions: "Steady pace 15–20 min, or intervals.", sets: 1, reps: "15–20 min"),
                ],
                estimatedMinutes: 20,
                profileType: .mom
            ),
            Workout(
                name: "Home Gym Only",
                summary: "Machines only. Legs and chest.",
                exercises: [
                    Exercise(name: "Leg Press", equipment: .homeGym, instructions: "Feet shoulder-width. Push through heels.", sets: 3, reps: "10–12"),
                    Exercise(name: "Chest Press", equipment: .homeGym, sets: 3, reps: "10"),
                ],
                estimatedMinutes: 25,
                profileType: .mom
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
                ],
                estimatedMinutes: 25,
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
                ],
                estimatedMinutes: 12,
                profileType: .child7
            ),
            Workout(
                name: "Dance & Stretch",
                summary: "Fun music moves and gentle stretching.",
                exercises: [
                    Exercise(name: "Free dance", equipment: .bodyweight, instructions: "Put on your favorite song and dance however you like!", sets: 1, reps: "2 min", restSeconds: 0),
                    Exercise(name: "Reach for the sky", equipment: .bodyweight, instructions: "Stand tall and reach your arms up high. Stretch side to side.", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Toe touches", equipment: .bodyweight, instructions: "Gently bend and try to touch your toes. No bouncing!", sets: 1, reps: "30 sec", restSeconds: 10),
                    Exercise(name: "Butterfly stretch", equipment: .bodyweight, instructions: "Sit, put feet together, and gently flap your knees like butterfly wings.", sets: 1, reps: "30 sec", restSeconds: 0),
                ],
                estimatedMinutes: 8,
                profileType: .child7
            ),
            Workout(
                name: "Balance & Coordination",
                summary: "Practice balance and have fun!",
                exercises: [
                    Exercise(name: "One-foot balance", equipment: .bodyweight, instructions: "Stand on one foot. Can you count to 10? Switch feet!", sets: 1, reps: "10 sec each foot", restSeconds: 10),
                    Exercise(name: "Heel-to-toe walk", equipment: .bodyweight, instructions: "Walk in a line, putting one foot right in front of the other.", sets: 1, reps: "20 sec", restSeconds: 15),
                    Exercise(name: "Star jumps", equipment: .bodyweight, instructions: "Jump and spread arms and legs out like a star. Land softly!", sets: 1, reps: "8", restSeconds: 15),
                ],
                estimatedMinutes: 10,
                profileType: .child7
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
                ],
                estimatedMinutes: 8,
                profileType: .child5
            ),
            Workout(
                name: "Animal Fun",
                summary: "Move like animals. So much fun!",
                exercises: [
                    Exercise(name: "Frog jump", equipment: .bodyweight, instructions: "Squat and give a little jump. You're a frog!", sets: 1, reps: "5", restSeconds: 15),
                    Exercise(name: "Bear walk", equipment: .bodyweight, instructions: "Walk on hands and feet like a bear. Roar!", sets: 1, reps: "15 sec", restSeconds: 15),
                    Exercise(name: "Flap like a bird", equipment: .bodyweight, instructions: "Flap your arms like wings. Fly around the room!", sets: 1, reps: "15 sec", restSeconds: 0),
                ],
                estimatedMinutes: 6,
                profileType: .child5
            ),
            Workout(
                name: "Dance Party",
                summary: "Dance to the music. You're awesome!",
                exercises: [
                    Exercise(name: "Dance!", equipment: .bodyweight, instructions: "Play a song and dance. Any way you want!", sets: 1, reps: "1 min", restSeconds: 0),
                    Exercise(name: "Spin slowly", equipment: .bodyweight, instructions: "Spin in a circle slowly. Stop if you feel dizzy!", sets: 1, reps: "3 spins", restSeconds: 10),
                    Exercise(name: "Clap and jump", equipment: .bodyweight, instructions: "Clap once, jump once. Clap, jump! Repeat.", sets: 1, reps: "8", restSeconds: 0),
                ],
                estimatedMinutes: 5,
                profileType: .child5
            ),
        ]
    }
}
