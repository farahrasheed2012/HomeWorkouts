# HomeStrength

A simple iOS app for at-home strength and cardio workouts using dumbbells, resistance bands, home gym, treadmill, exercise bike, and yoga mat. Supports multiple user profiles (Mom, Middle School Daughter, 7-year-old, 5-year-old, Group Fitness Classes) with age-appropriate routines, tracking, and a random workout generator.

## Core Features

### User profiles and workouts
- **User selection** at app startup (Mom, Middle School Daughter, 7-Year-Old, 5-Year-Old, Group Fitness Classes).
- **Pre-built routines** per profile: strength (Mom), volleyball (Middle School Daughter), fun activities (7- and 5-year-old), bodyweight class routines (Group Fitness).
- **Workout tracking** and progress per user (workouts completed, streaks, strength/vertical jump/kid badges).
- **Timer/stopwatch** for rest between sets, with **audio and haptic** when time is ending so you don’t need to watch the screen.
- **Exercise library** with descriptions, form tips, targets (e.g. coordination, balance, strength), safety notes, and placeholder images.
- **Metrics dashboard**: workouts per week, streaks, strength progress (weight over time), vertical jump (volleyball), kid badges and achievements.

### Random Workout Generator
- **Dynamic routine generator** that creates custom workout routines based on user inputs.
- **Input parameters:**
  - Available equipment (dumbbells, resistance bands, bodyweight only, yoga mat, etc.)
  - Workout duration (15, 20, 30, 45 minutes, etc.)
  - Fitness level/intensity preference (low-key, intermediate, high-intensity)
  - Muscle groups to focus on (optional: full-body, upper body, lower body, core, cardio, etc.)
- **Generator** pulls from the exercise library and creates **unique routines each time**.
- **Output includes:**
  - Complete workout with exercises, reps/sets, rest periods, and timing
  - Exercise descriptions and form tips for each movement
  - Modifications for different fitness levels (scaled by intensity)
  - Total time estimate for the workout
  - Option to **save generated routines** for later use
- **Works for all profiles** with age/skill-appropriate exercises.
- **Younger daughters:** Simplified inputs (just duration and energy level) with fun, playful routines generated automatically.

### Group Fitness Classes (instructor profile)
- Library of **full bodyweight class routines** (30–45 min) with warm-up, main blocks, cool-down.
- **Class formats:** full-body, upper body, lower body (pelvic floor safe), core rebuilding (postpartum), cardio/HIIT, low-impact.
- **Per exercise:** low-key / intermediate / pro options, timing cues, instructor callouts, BPM suggestions, space requirements, scaling notes.
- **Full-session class timer** with audio at 1 min and at 0.
- **Log classes led** (date, participants, notes); view history.

## Requirements

- Xcode 14+
- iOS 16+

## How to open and run

1. Open the project: double-click **`HomeStrength/HomeStrength.xcodeproj`** (inside the inner `HomeStrength` folder), or in Terminal:
   ```bash
   open HomeStrength/HomeStrength.xcodeproj
   ```
2. Select the **HomeStrength** scheme and a simulator or device.
3. Press **Run** (⌘R).

## Suggested weekly schedule (beginner-friendly)

- **Monday:** Full Body A (dumbbells + bands)
- **Wednesday:** Full Body B (home gym + dumbbells)
- **Friday:** Full Body A again, or Upper Body
- **1–2× per week:** Cardio (treadmill and/or exercise bike) on rest days or after a shorter strength session

Start with the prescribed sets/reps and 60s rest; adjust weight and reps as you get stronger. Add or swap workouts as you like.
