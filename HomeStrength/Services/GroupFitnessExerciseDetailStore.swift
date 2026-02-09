//
//  GroupFitnessExerciseDetailStore.swift
//  HomeStrength
//
//  Lookup for detailed steps, instructions, tips, and image placeholders by exercise name.
//  Used when a routine exercise doesn’t define its own steps/summary/tips (e.g. _ex-built routines).
//

import Foundation

/// Detail record for a group fitness exercise (steps, summary, tips, image).
struct GroupFitnessExerciseDetail {
    var steps: [String]
    var summary: String?
    var tips: [String]
    var imagePlaceholderName: String?
}

/// Central lookup of exercise details by name. Keys are normalized (trimmed, as used in routines).
enum GroupFitnessExerciseDetailStore {
    private static let details: [String: GroupFitnessExerciseDetail] = [
        "Squats": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip- to shoulder-width apart; toes can point slightly out.",
                "Send hips back and bend knees to lower into a squat (aim for thighs at least parallel to the floor).",
                "Keep knees in line with toes; chest up, core braced.",
                "Drive through the whole foot to stand back up; squeeze glutes at the top.",
                "Repeat for the work interval. Offer chair squat or hold the back of a chair for balance if needed."
            ],
            summary: "Lower into a squat by hinging at the hips and bending the knees, then stand back up. Scale with chair squat or full bodyweight squat; progress to jump squat or pulse at the bottom.",
            tips: ["Cue “knees over toes” and “chest up.”", "Exhale as you stand.", "Modify to chair squat anytime for safety or fatigue."],
            imagePlaceholderName: "GobletSquat"
        ),
        "Glute bridge": GroupFitnessExerciseDetail(
            steps: [
                "Lie on your back with knees bent, feet flat on the floor hip-width apart, arms by your sides.",
                "Press through the feet and squeeze the glutes to lift the hips toward the ceiling.",
                "Hold the top briefly (e.g. 1–2 seconds) without over-arching the lower back.",
                "Lower with control and repeat for the work interval.",
                "Progress: single-leg bridge, or small pulse or march at the top."
            ],
            summary: "Lie on your back, knees bent, and lift the hips by driving through the feet and squeezing the glutes. Great for pelvic floor and glute strength; scale range or add single-leg for progression.",
            tips: ["Squeeze glutes at top; avoid over-arching the lower back.", "Exhale as you lift for pelvic floor awareness.", "Pelvic floor safe when done with controlled range."],
            imagePlaceholderName: "GluteBridge"
        ),
        "Push-ups": GroupFitnessExerciseDetail(
            steps: [
                "Start in a high plank (hands under shoulders, body in a straight line) or from knees / wall / incline.",
                "Lower the chest toward the floor by bending the elbows (about 45° from body); keep core tight and hips level.",
                "Push back up to the start position.",
                "Repeat for the work interval.",
                "Options: wall push-up, hands on chair, knees down, or full push-up; progress to decline or narrow hands."
            ],
            summary: "Perform push-ups from plank (or scaled option). Lower chest toward the floor with control, then push back up. Scale to wall or chair; progress to full, decline, or narrow-hand push-ups.",
            tips: ["Keep core tight; don’t let hips sag or pike.", "Scale to wall or chair anytime.", "Not pelvic floor safe for everyone early postpartum—offer knee or wall option."],
            imagePlaceholderName: nil
        ),
        "Lunges": GroupFitnessExerciseDetail(
            steps: [
                "Stand tall; step one leg forward (or backward for reverse lunge) into a lunge.",
                "Lower until both knees are at about 90°; front knee over the ankle, back knee under the hip.",
                "Keep torso upright and core engaged.",
                "Push through the front foot to return to standing; alternate legs or complete one side then switch.",
                "Use a wall or chair for balance if needed; progress to walking lunge or add a pulse at the bottom."
            ],
            summary: "Step into a lunge (forward or reverse), lower with control so the front knee stays over the ankle, then push back to standing. Scale with support; progress to walking lunge or pulse.",
            tips: ["Front knee over ankle; avoid letting it cave in.", "Take your time; option for reverse lunge.", "Pelvic floor safe when range and intensity are appropriate."],
            imagePlaceholderName: "DumbbellLunge"
        ),
        "Plank": GroupFitnessExerciseDetail(
            steps: [
                "Start in a high plank (hands under shoulders) or forearm plank (elbows under shoulders); body in a straight line from head to heels.",
                "Engage the core and keep the hips level—no sagging or piking.",
                "Hold for the work interval (e.g. 15–45 seconds).",
                "Scale: from knees, or shorter holds with rest (e.g. 10 sec on / 10 sec off).",
                "Progress: shoulder taps, single-leg hold, or longer duration."
            ],
            summary: "Hold a high or forearm plank with a neutral spine and engaged core. Scale from knees or with shorter holds; progress with shoulder taps or longer holds.",
            tips: ["Neutral spine; stop if you feel coning or strain.", "Postpartum: skip or do from knees if core feels weak.", "Cue “squeeze belly to spine” and “level hips.”"],
            imagePlaceholderName: "Plank"
        ),
        "Calf raises": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip-width apart; hold a wall or chair for balance if needed.",
                "Rise onto the balls of the feet, lifting the heels as high as comfortable.",
                "Hold briefly at the top, then lower with control.",
                "Repeat for the work interval.",
                "Progress: single-leg calf raise or small pulse at the top."
            ],
            summary: "Rise onto the balls of the feet (calf raise), hold briefly, then lower with control. Use the wall for balance; progress to single-leg or pulse at the top.",
            tips: ["Control the way down to build strength.", "Pelvic floor safe.", "Option to hold wall or chair for balance."],
            imagePlaceholderName: "CalfRaises"
        ),
        "Leg lift (side)": GroupFitnessExerciseDetail(
            steps: [
                "Stand on one leg (or sit for a gentler option); keep hips square and core engaged.",
                "Lift the other leg out to the side (abduction), leading with the heel; avoid leaning the torso.",
                "Lower with control and repeat on the same side for the work interval, then switch legs if time.",
                "Scale: seated or small range; hold a chair for balance.",
                "Progress: add a small pulse or circle at the top."
            ],
            summary: "Lift one leg out to the side while standing (or seated), keeping hips square. Scale with chair or smaller range; progress with pulse or circles at the top.",
            tips: ["Keep hips square; don’t lean into the standing leg.", "Pelvic floor safe.", "Use chair for balance if needed."],
            imagePlaceholderName: nil
        ),
        "Dead bug": GroupFitnessExerciseDetail(
            steps: [
                "Lie on your back with arms toward the ceiling and knees bent at 90° (tabletop).",
                "Press the low back gently into the floor and keep it there throughout.",
                "Extend one arm overhead and the opposite leg toward the floor (or one limb at a time for an easier version).",
                "Return to the start position and alternate sides.",
                "If you see coning (doming of the belly), reduce range or move one limb at a time."
            ],
            summary: "On your back, alternate extending opposite arm and leg while keeping the low back pressed to the floor. Scale to one limb at a time; progress to full alternating or slower tempo.",
            tips: ["Low back pressed to floor the whole time.", "If you see coning, make the move smaller.", "Pelvic floor safe when done with controlled breathing and range."],
            imagePlaceholderName: nil
        ),
        "Bird dog": GroupFitnessExerciseDetail(
            steps: [
                "Start on hands and knees (tabletop); wrists under shoulders, knees under hips, neutral spine.",
                "Reach one arm forward and the opposite leg back, keeping the torso still.",
                "Hold for 2–3 seconds, then return to tabletop and switch sides.",
                "Repeat alternating for the work interval.",
                "Scale: one limb at a time; progress with a pulse or longer hold."
            ],
            summary: "From tabletop, extend one arm and the opposite leg, hold briefly, then switch. Keep the spine neutral; scale to one limb at a time; progress with pulse or longer hold.",
            tips: ["Keep spine neutral; avoid arching or rounding.", "Modify to tabletop only if needed.", "Pelvic floor safe."],
            imagePlaceholderName: nil
        ),
        "Superman": GroupFitnessExerciseDetail(
            steps: [
                "Lie face down with arms extended in front and legs straight.",
                "Lift the chest, arms, and legs off the floor (or arms only / legs only for a gentler version).",
                "Squeeze the lower back and glutes; avoid straining the neck.",
                "Hold for 2–3 seconds, then lower with control.",
                "Repeat for the work interval. Progress with longer hold or small pulse."
            ],
            summary: "Lying face down, lift arms and legs (or one at a time) off the floor and hold. Strengthens the lower back and posterior chain; scale to arms only or legs only.",
            tips: ["Keep the neck in line; don’t look up sharply.", "Great for lower back and glutes.", "Pelvic floor safe when done with controlled range."],
            imagePlaceholderName: nil
        ),
        "Single-leg balance": GroupFitnessExerciseDetail(
            steps: [
                "Stand on one leg; use a wall or chair for light touch if needed.",
                "Keep the standing leg slightly bent; core engaged, hips level.",
                "Hold for the work interval (e.g. 10–15 seconds per leg).",
                "Progress: longer hold, eyes closed (if safe), or reduce support."
            ],
            summary: "Balance on one leg for the work interval. Use the wall or a chair for support as needed; progress with longer hold or eyes closed.",
            tips: ["Fix eyes on one point to help balance.", "Pelvic floor safe.", "Progress by reducing hand support or closing eyes in a safe space."],
            imagePlaceholderName: nil
        ),
        "Single-leg stance": GroupFitnessExerciseDetail(
            steps: [
                "Stand on one leg; optional light touch on wall or chair.",
                "Keep standing knee soft; core engaged, hips level.",
                "Hold for the prescribed time (e.g. 10–15 seconds), then switch legs.",
                "Progress: longer hold or eyes closed in a safe environment."
            ],
            summary: "Hold a single-leg stance for the work interval. Use wall or chair for balance; progress with duration or eyes closed.",
            tips: ["Stability over speed.", "Pelvic floor safe.", "Use wall for 10 sec if needed, then try without."],
            imagePlaceholderName: nil
        ),
        "Wall push-up": GroupFitnessExerciseDetail(
            steps: [
                "Stand facing a wall; place hands on the wall at shoulder height (or higher for easier).",
                "Walk the feet back until the body is at an angle; keep a straight line from head to heels.",
                "Bend the elbows to bring the chest toward the wall, then push back to the start.",
                "Repeat for the work interval. Lower hand height or step feet further back to progress."
            ],
            summary: "Perform push-ups with hands on the wall. Adjust difficulty by hand height and how far the feet are from the wall. Pelvic floor friendly.",
            tips: ["Hands high = easier; lower hands or step back = harder.", "Pelvic floor safe.", "Keep core engaged and body in one line."],
            imagePlaceholderName: nil
        ),
        "March in place": GroupFitnessExerciseDetail(
            steps: [
                "Stand tall; lift one knee toward hip height while the opposite arm swings naturally.",
                "Lower the foot and alternate with the other leg in a steady march.",
                "Keep the core engaged and march for the work interval.",
                "Scale: slow march; progress to higher knees or add arm drive."
            ],
            summary: "March in place, driving the knees up and swinging the arms. Scale speed and height; progress to high knees or faster pace.",
            tips: ["Steady rhythm; breathe naturally.", "Pelvic floor safe.", "Add arm drive for more intensity."],
            imagePlaceholderName: nil
        ),
        "Arm raises": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip-width apart; arms at sides or in front.",
                "Raise arms to Y (diagonal), T (sides), or W (bent elbows, squeeze shoulder blades) as cued.",
                "Control the movement; optional 2-second hold at the top.",
                "Lower and repeat for the work interval. Scale: small range; progress to full YTW or hold longer."
            ],
            summary: "Perform Y, T, and/or W arm raises to work the shoulders and upper back. Scale with smaller range; progress with full YTW and holds.",
            tips: ["Squeeze shoulder blades on T and W.", "Pelvic floor safe.", "No weight needed; control is key."],
            imagePlaceholderName: nil
        ),
        "Arm raises & YTW": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip-width apart.",
                "Y: Raise arms at a 45° angle in front; hold briefly.",
                "T: Open arms to the sides at shoulder height; squeeze shoulder blades.",
                "W: Bend elbows, pull shoulder blades back and down; hold.",
                "Repeat the sequence for the work interval. Scale: Y and T only; progress to full YTW with hold or pulse."
            ],
            summary: "Perform Y, T, and W arm raises in sequence to strengthen the shoulders and upper back. Scale to Y and T only; progress with full range and holds.",
            tips: ["Squeeze shoulder blades on T and W.", "Pelvic floor safe.", "Keep shoulders down and back."],
            imagePlaceholderName: nil
        ),
        "High knees": GroupFitnessExerciseDetail(
            steps: [
                "Stand tall; drive one knee up toward hip height (or higher) while hopping or stepping on the other foot.",
                "Switch legs quickly in a running-in-place motion.",
                "Pump the arms naturally; land softly.",
                "Scale: march; progress to faster high knees or longer interval."
            ],
            summary: "Run in place driving the knees up (high knees). Scale to a march; progress to faster pace. Higher impact—offer march for low-impact option.",
            tips: ["Land softly; quick feet.", "Not always pelvic floor safe at high intensity—offer march.", "Pump arms for coordination and intensity."],
            imagePlaceholderName: nil
        ),
        "Step touch": GroupFitnessExerciseDetail(
            steps: [
                "Step one foot out to the side, then touch the other foot to it (step-touch).",
                "Continue side to side in a steady rhythm for the work interval.",
                "Add arm movements (e.g. overhead or side) to progress.",
                "Scale: small steps; progress to larger range or add arms."
            ],
            summary: "Step to the side and touch the other foot to it, then step the other way. Add arms for progression. Low impact.",
            tips: ["Keep it low impact by avoiding jumps.", "Pelvic floor safe.", "Add arms for more intensity."],
            imagePlaceholderName: nil
        ),
        "Rest": GroupFitnessExerciseDetail(
            steps: [
                "Use this block for active recovery: walk, light jog, or stand and breathe.",
                "Encourage participants to hydrate and prepare for the next exercise.",
                "No specific movement required; keep the class flow smooth."
            ],
            summary: "Active recovery interval: walk, light jog, or rest. Use for hydration and transition.",
            tips: ["Keep the group moving lightly if desired.", "Use to reset before the next round."],
            imagePlaceholderName: nil
        ),
        "Reach & twist": GroupFitnessExerciseDetail(
            steps: [
                "Stand (or sit) with feet hip-width apart; arms can be at sides or out to a T.",
                "Reach one arm up and across the body in a gentle twist, following with the eyes.",
                "Return to center and repeat to the other side.",
                "Repeat for the work interval. Scale: seated; progress to deeper twist or standing."
            ],
            summary: "Standing or seated, reach and twist gently to each side. Mobilizes the spine and sides; scale seated for safety.",
            tips: ["Move with the breath; don’t force the twist.", "Pelvic floor safe.", "Focus on length and rotation, not speed."],
            imagePlaceholderName: nil
        ),
        "Hip circles": GroupFitnessExerciseDetail(
            steps: [
                "Stand on one leg; lift the other knee and make a circle with that knee/hip (small or larger).",
                "Circle 5–8 one way, then reverse.",
                "Switch legs and repeat. Use a wall or chair for balance if needed.",
                "Scale: small circles; progress to full range or add hold at the top."
            ],
            summary: "Standing on one leg, circle the other hip/knee to mobilize the hip. Scale with small circles; progress with larger range.",
            tips: ["Keep the standing leg slightly bent.", "Pelvic floor safe.", "Use wall for balance."],
            imagePlaceholderName: nil
        ),
        "Calf stretch": GroupFitnessExerciseDetail(
            steps: [
                "Stand facing a wall; place hands on the wall. Step one leg back, heel on the floor.",
                "Keep the back leg straight (or slightly bent for a different stretch) and press the heel down.",
                "Hold for 20–30 seconds; switch legs.",
                "Repeat as needed during the interval."
            ],
            summary: "Stretch the calf with one leg back, heel down. Hold 20–30 seconds per side. Use for mobility or cool-down.",
            tips: ["Heel stays down; gentle lean into the wall.", "Pelvic floor safe.", "Bend the back knee slightly to stretch the soleus."],
            imagePlaceholderName: nil
        ),
        "Tricep dip (chair)": GroupFitnessExerciseDetail(
            steps: [
                "Sit on the edge of a sturdy chair; hands next to the hips, fingers forward.",
                "Slide off the chair so the body is supported by the hands and feet (feet flat for easier).",
                "Bend the elbows to lower the body, then push back up.",
                "Keep shoulders down; repeat for the work interval. Scale: feet flat, small range; progress to legs extended or feet elevated."
            ],
            summary: "Using a chair, support the body on the hands and perform tricep dips. Scale with feet flat and smaller range; progress with legs extended.",
            tips: ["Shoulders down and back.", "Pelvic floor safe when range is controlled.", "Reduce range if shoulders or wrists feel strain."],
            imagePlaceholderName: "TricepExtension"
        ),
        "Band pull-apart": GroupFitnessExerciseDetail(
            steps: [
                "Hold a resistance band in both hands in front of the chest; arms slightly bent.",
                "Pull the band apart by squeezing the shoulder blades; hands move toward the sides.",
                "Control the return; repeat for the work interval.",
                "Scale: light band, short range; progress to heavier band or pause at full extension."
            ],
            summary: "Hold a band in front and pull it apart by squeezing the shoulder blades. Strengthens the upper back and rear delts. Scale with band tension and range.",
            tips: ["Shoulders down and back throughout.", "Pelvic floor safe.", "Squeeze at the end of the pull."],
            imagePlaceholderName: "BandPullApart"
        ),
        "Tricep extension (bodyweight)": GroupFitnessExerciseDetail(
            steps: [
                "Option A: Hands on wall, body at an angle; bend elbows to bring forehead toward the wall, then push back.",
                "Option B: Chair dip (see Tricep dip (chair)); focus on elbow bend and extension.",
                "Keep elbows pointing back; control the movement.",
                "Repeat for the work interval. Scale: wall push; progress to chair dip or full dip."
            ],
            summary: "Tricep work using bodyweight: wall push or chair dip. Focus on elbow extension; scale to wall, progress to full dip.",
            tips: ["Elbows stay pointing back.", "Pelvic floor safe with controlled range.", "Avoid shoulder shrugging."],
            imagePlaceholderName: "TricepExtension"
        ),
        "Breathing": GroupFitnessExerciseDetail(
            steps: [
                "Have the group stand or sit comfortably with good posture.",
                "Inhale for 3–4 counts (nose or mouth), expand the belly and ribs.",
                "Exhale for 4–6 counts; allow the belly to soften.",
                "Repeat for the interval. Option: add a simple movement (e.g. arm float) on the breath."
            ],
            summary: "Guided breathing for recovery or centering. Inhale and exhale with a longer exhale; optional gentle movement.",
            tips: ["Longer exhale supports the nervous system.", "Pelvic floor safe.", "Use between intense blocks if needed."],
            imagePlaceholderName: nil
        ),
        "Burpee (modified)": GroupFitnessExerciseDetail(
            steps: [
                "Stand; lower into a squat and place hands on the floor (or on thighs for a gentler option).",
                "Step or jump the feet back to a plank (or from knees); optional chest lower.",
                "Step or jump the feet back to the hands, then stand (or add a small jump).",
                "Repeat for the work interval. Scale: no jump, step back/forward; progress to full burpee or jump at top."
            ],
            summary: "Modified burpee: squat, step or jump to plank, step or jump back, stand. Scale by stepping and omitting the jump; progress to full burpee.",
            tips: ["Step instead of jump to keep impact low.", "Not always pelvic floor safe at high intensity—offer step option.", "Keep core engaged in plank."],
            imagePlaceholderName: nil
        ),
        "Cat-cow": GroupFitnessExerciseDetail(
            steps: [
                "Start on hands and knees (tabletop); wrists under shoulders, knees under hips.",
                "Cow: drop the belly, lift the chest and tailbone; inhale.",
                "Cat: round the spine, tuck the tailbone; exhale.",
                "Flow between cat and cow for the work interval; move with the breath."
            ],
            summary: "On hands and knees, alternate between cow (spine arched) and cat (spine rounded). Mobilizes the spine; move with the breath.",
            tips: ["Move slowly with the breath.", "Pelvic floor safe.", "Great for warm-up or recovery."],
            imagePlaceholderName: nil
        ),
        "Fast feet": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip-width apart; stay on the balls of the feet.",
                "Run in place with very short, quick steps (fast feet).",
                "Keep the core engaged and arms pumping; stay light on the feet.",
                "Continue for the work interval. Scale: slower pace; progress to faster or add a directional change."
            ],
            summary: "Quick, small steps in place (fast feet). Stay light and quick; scale speed as needed.",
            tips: ["Stay on balls of feet; quick turnover.", "Higher impact—offer march for low impact.", "Pump arms for coordination."],
            imagePlaceholderName: nil
        ),
        "Heel slide": GroupFitnessExerciseDetail(
            steps: [
                "Lie on your back; knees bent, feet flat. Option: one leg extended, one bent.",
                "Slide one heel along the floor to extend the leg (or straighten the knee), then slide back.",
                "Keep the low back gently pressed to the floor; move slowly.",
                "Alternate legs or repeat one side for the work interval. Pelvic floor friendly."
            ],
            summary: "Lying on your back, slide one heel along the floor to extend and return. Gentle core and hip mobility; pelvic floor safe.",
            tips: ["Keep low back on the floor.", "Pelvic floor safe.", "Exhale as you extend if that feels better."],
            imagePlaceholderName: nil
        ),
        "Jumping jacks": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet together, arms at sides.",
                "Jump (or step) feet out while raising arms overhead; then jump (or step) back to the start.",
                "Repeat for the work interval. Scale: step jacks or half jacks; progress to full jumping jacks."
            ],
            summary: "Jump or step the feet out while raising the arms, then return. Scale with step jacks; progress to full speed.",
            tips: ["Land softly; scale to step jacks for low impact.", "Not always pelvic floor safe at high impact.", "Keep a steady rhythm."],
            imagePlaceholderName: nil
        ),
        "Lateral shuffles": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip-width apart; stay in a slight athletic stance.",
                "Shuffle quickly to the right for a few steps, then to the left.",
                "Stay low and light on the feet; keep the core engaged.",
                "Repeat for the work interval. Scale: slower shuffles; progress to faster or add a touch at the end."
            ],
            summary: "Shuffle side to side in an athletic stance. Agility and cardio; scale speed and distance.",
            tips: ["Stay low; push off the outside foot.", "Can be higher impact—reduce speed to scale.", "Good for warm-up or HIIT."],
            imagePlaceholderName: nil
        ),
        "Pelvic tilts": GroupFitnessExerciseDetail(
            steps: [
                "Lie on your back with knees bent, feet flat; or stand with back against a wall.",
                "Gently tilt the pelvis so the low back presses toward the floor (or wall); hold briefly.",
                "Release and repeat. Focus on subtle movement, not a big arch.",
                "Repeat for the work interval. Excellent for pelvic floor awareness."
            ],
            summary: "Lying or standing, gently tilt the pelvis to press the low back down. Builds pelvic floor and core awareness; very safe.",
            tips: ["Small, controlled movement.", "Pelvic floor safe and supportive.", "Exhale as you tilt."],
            imagePlaceholderName: nil
        ),
        "Reach for the sky": GroupFitnessExerciseDetail(
            steps: [
                "Stand with feet hip-width apart; arms can start at sides or on hips.",
                "Reach one arm up toward the ceiling (or both), lengthening the side body.",
                "Lower and repeat with the other arm (or both). Option: add a gentle side bend.",
                "Repeat for the work interval. Use in warm-up or recovery."
            ],
            summary: "Reach one or both arms overhead to lengthen the body. Gentle stretch and mobility; scale with range.",
            tips: ["Breathe into the stretch.", "Pelvic floor safe.", "Keep shoulders down."],
            imagePlaceholderName: nil
        ),
        "Seated leg lift": GroupFitnessExerciseDetail(
            steps: [
                "Sit tall on a chair or on the floor; legs can be bent or one extended.",
                "Lift one leg (or both) with control; keep the core engaged.",
                "Lower with control and repeat. Option: hold for a few seconds at the top.",
                "Repeat for the work interval. Scale: smaller lift; progress to higher or longer hold."
            ],
            summary: "Seated, lift one or both legs with control. Strengthens hip flexors and core; scale with height and duration.",
            tips: ["Sit tall; avoid rounding the back.", "Pelvic floor safe.", "Use chair for support if needed."],
            imagePlaceholderName: nil
        ),
        "Skater jumps": GroupFitnessExerciseDetail(
            steps: [
                "Stand on one leg; jump or step to the side, landing on the other leg (like a skater).",
                "Swing the arms for balance and power; land with a soft knee.",
                "Jump or step back to the other side; repeat for the work interval.",
                "Scale: step instead of jump; progress to bigger jumps or faster pace."
            ],
            summary: "Lateral jump or step from one leg to the other (skater style). Scale with step; progress to jump and speed.",
            tips: ["Land softly; absorb with the knee.", "Higher impact—offer step for low impact.", "Arm swing helps balance."],
            imagePlaceholderName: nil
        ),
        "Supine march": GroupFitnessExerciseDetail(
            steps: [
                "Lie on your back with knees bent, feet flat; low back gently pressed to the floor.",
                "March in place by lifting one knee toward the chest, then the other, in a controlled rhythm.",
                "Keep the core engaged and avoid letting the back arch.",
                "Continue for the work interval. Pelvic floor safe when controlled."
            ],
            summary: "Lying on your back, march by lifting one knee at a time. Core and hip flexor work; pelvic floor friendly.",
            tips: ["Low back stays on the floor.", "Pelvic floor safe.", "Exhale as you lift the knee if that helps."],
            imagePlaceholderName: nil
        ),
        "Tabletop hold": GroupFitnessExerciseDetail(
            steps: [
                "Come to hands and knees (tabletop); wrists under shoulders, knees under hips.",
                "Keep a neutral spine; engage the core and hold the position.",
                "Hold for the work interval (e.g. 20–45 seconds). Option: add a slight weight shift or breath focus.",
                "Scale: shorten the hold; progress to longer or add a limb lift."
            ],
            summary: "Hold a tabletop position (hands and knees) with a neutral spine. Core stability; scale with hold duration.",
            tips: ["Neutral spine; don’t sag or round.", "Pelvic floor safe.", "Great prep for bird dog or plank."],
            imagePlaceholderName: nil
        ),
        "Mountain climbers / knee drive": GroupFitnessExerciseDetail(
            steps: [
                "Start in a high plank; hands under shoulders, body in a straight line.",
                "Drive one knee toward the chest (or toward the same-side elbow), then return and switch legs.",
                "Keep the hips level and core engaged; move at a controlled or faster pace.",
                "Repeat for the work interval. Scale: slow knee drive from plank or from knees; progress to faster mountain climbers."
            ],
            summary: "From plank, drive the knees toward the chest in alternation. Cardio and core; scale from knees or slower tempo.",
            tips: ["Hips level; avoid piking.", "Not always pelvic floor safe at high intensity—offer knee drive from knees.", "Keep shoulders over wrists."],
            imagePlaceholderName: nil
        ),
        "Wall push-up or arm raises": GroupFitnessExerciseDetail(
            steps: [
                "Offer two options: (1) Wall push-up: hands on wall, perform push-ups. (2) Arm raises: Y, T, or W raises standing.",
                "Participants choose based on preference or limitation.",
                "Cue form for the chosen option and repeat for the work interval."
            ],
            summary: "Either wall push-ups or standing arm raises (Y/T/W). Choose one for the interval; both are pelvic floor friendly.",
            tips: ["Let participants choose the option that fits.", "Pelvic floor safe.", "Cue one option at a time if needed."],
            imagePlaceholderName: nil
        ),
    ]
    
    /// Returns detail for an exercise name, or nil if not found. Tries exact match, then fallback (e.g. "Squat (modified)" -> "Squats", "Rest / walk" -> "Rest").
    static func detail(for exerciseName: String) -> GroupFitnessExerciseDetail? {
        let key = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let d = details[key] { return d }
        let beforeSlash = key.split(separator: "/").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? key
        if beforeSlash != key, let d = details[beforeSlash] { return d }
        let beforeParen = key.split(separator: "(").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? key
        if beforeParen != key, let d = details[beforeParen] { return d }
        if key.hasSuffix(" (modified)") {
            let base = String(key.dropLast(" (modified)".count))
            if let d = details[base] { return d }
        }
        let aliases: [String: String] = [
            "Glute bridge (hold)": "Glute bridge", "Glute bridge with breath": "Glute bridge",
            "Jump squat / squat": "Squats", "Squat (modified)": "Squats", "Speed squats": "Squats",
            "Superman (modified)": "Superman", "Standing leg lift (side)": "Leg lift (side)",
            "Rest / walk": "Rest", "High knees / march": "High knees",
            "Wall push-up or arm raises": "Wall push-up", "Mountain climbers / knee drive": "Plank"
        ]
        if let base = aliases[key], let d = details[base] { return d }
        return nil
    }
    
    /// Returns effective steps for display: use exercise's steps if non-empty, else lookup by name.
    static func steps(for exercise: ScaledExerciseView) -> [String] {
        if !exercise.steps.isEmpty { return exercise.steps }
        return detail(for: exercise.name)?.steps ?? []
    }
    
    /// Returns effective summary: exercise's summary, else lookup by name.
    static func summary(for exercise: ScaledExerciseView) -> String? {
        if let s = exercise.summary, !s.isEmpty { return s }
        return detail(for: exercise.name)?.summary
    }
    
    /// Returns effective tips: exercise's tips if non-empty, else lookup by name.
    static func tips(for exercise: ScaledExerciseView) -> [String] {
        if !exercise.tips.isEmpty { return exercise.tips }
        return detail(for: exercise.name)?.tips ?? []
    }
    
    /// Returns effective image name: exercise's imagePlaceholderName, else lookup by name.
    static func imagePlaceholderName(for exercise: ScaledExerciseView) -> String? {
        if let name = exercise.imagePlaceholderName, !name.isEmpty { return name }
        return detail(for: exercise.name)?.imagePlaceholderName
    }
}
