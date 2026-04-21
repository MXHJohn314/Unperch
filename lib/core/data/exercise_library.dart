import 'package:unperch/core/enums/enums.dart';
import 'package:unperch/core/models/exercise.dart';

/// Bundled exercise library for Unperch.
///
/// All exercises are curated to be office-appropriate:
/// - Short (2-5 minutes) and performable beside a desk
/// - Quiet and non-disruptive to coworkers (no jumping, minimal impact)
/// - Doable in office attire
/// - No dangerous lifts, no spotter required
///
/// Distribution is intentionally weighted toward `light` and `moderate`
/// intensities, with only a handful of `vigorous` options for users who
/// want a harder push on a break.
const List<Exercise> kExerciseLibrary = [
  // ---------------------------------------------------------------
  // BODYWEIGHT — UPPER (neck, shoulders, arms, chest, upper back)
  // ---------------------------------------------------------------
  Exercise(
    id: 'bodyweight_neck_rolls',
    name: 'Neck Rolls',
    description:
        'Slowly roll your head in a full circle, 5 times each direction. '
        'Keep shoulders relaxed and breathe evenly.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Time to unperch! Do 10 slow neck rolls — five each direction. '
        'Take it easy.',
  ),
  Exercise(
    id: 'bodyweight_shoulder_rolls',
    name: 'Shoulder Rolls',
    description:
        'Roll your shoulders backward 10 times, then forward 10 times. '
        'Make the circles as large and slow as you can.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 45,
    ttsScript:
        'Let us loosen those shoulders. Ten slow rolls back, then ten '
        'forward. Big circles.',
  ),
  Exercise(
    id: 'bodyweight_chin_tucks',
    name: 'Chin Tucks',
    description:
        'Gently draw your chin straight back, making a double chin. '
        'Hold 3 seconds, release. Repeat 10 times.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Counter that screen slouch. Ten chin tucks, holding each for '
        'three seconds.',
  ),
  Exercise(
    id: 'bodyweight_wall_angels',
    name: 'Wall Angels',
    description:
        'Stand against a wall, arms in a goalpost position. Slide arms '
        'up and down while keeping them in contact with the wall. 10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 90,
    ttsScript:
        'Find a clear wall and do ten slow wall angels. Keep those '
        'elbows pressed back.',
  ),
  Exercise(
    id: 'bodyweight_desk_pushup',
    name: 'Desk Pushups',
    description:
        'Place hands on the edge of a sturdy desk, walk feet back, and '
        'do 12 controlled pushups. Body stays in a straight line.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Time for twelve desk pushups. Hands on the desk, feet back, '
        'and down you go.',
  ),
  Exercise(
    id: 'bodyweight_wall_pushup',
    name: 'Wall Pushups',
    description:
        'Stand arm\'s length from a wall, hands at shoulder height. '
        'Lower chest toward wall, then press back. 15 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Quick unperch — fifteen wall pushups. Nice and slow, feel the '
        'chest engage.',
  ),
  Exercise(
    id: 'bodyweight_incline_pushup',
    name: 'Incline Pushups',
    description:
        'Hands on a chair seat or low shelf, do 10 pushups with a '
        'controlled tempo. Keep core tight.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten incline pushups on a chair. Lower slow, press strong.',
  ),
  Exercise(
    id: 'bodyweight_tricep_desk_dip',
    name: 'Desk Tricep Dips',
    description:
        'Sit on the edge of a sturdy desk, hands beside hips, slide off '
        'and lower until elbows are at 90 degrees. 10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 75,
    ttsScript:
        'Ten tricep dips off the edge of a sturdy desk. Keep the elbows '
        'tracking back.',
  ),
  Exercise(
    id: 'bodyweight_arm_circles',
    name: 'Arm Circles',
    description:
        'Arms straight out to the sides. Do 20 small circles forward, '
        'then 20 backward.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Twenty small arm circles forward, twenty back. Shake out those '
        'typing arms.',
  ),
  Exercise(
    id: 'bodyweight_scapular_squeeze',
    name: 'Scapular Squeezes',
    description:
        'Pinch your shoulder blades together as if holding a pencil '
        'between them. Hold 5 seconds. Repeat 10 times.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Ten scapular squeezes. Pinch the shoulder blades, hold five '
        'seconds, release.',
  ),
  Exercise(
    id: 'bodyweight_doorway_chest_stretch',
    name: 'Doorway Chest Stretch',
    description:
        'Place forearms on either side of a doorway, step through '
        'gently. Hold 30 seconds, switch stance, repeat.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Find a doorway. Open up that chest for thirty seconds on each '
        'side. Breathe.',
  ),
  Exercise(
    id: 'bodyweight_wrist_circles',
    name: 'Wrist Circles and Stretches',
    description:
        'Extend arms, make 10 wrist circles each direction. Then gently '
        'pull fingers back for 20 seconds per hand.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Give those keyboard wrists some love. Ten circles each way, '
        'then stretch each hand.',
  ),

  // ---------------------------------------------------------------
  // BODYWEIGHT — CORE
  // ---------------------------------------------------------------
  Exercise(
    id: 'bodyweight_standing_knee_raise',
    name: 'Standing Knee Raises',
    description:
        'Stand tall, raise one knee to hip height, lower with control. '
        'Alternate for 20 total reps.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Twenty standing knee raises, alternating legs. Keep the core '
        'engaged.',
  ),
  Exercise(
    id: 'bodyweight_standing_oblique_crunch',
    name: 'Standing Oblique Crunches',
    description:
        'Hands behind head, bring right elbow to right knee by '
        'side-bending. 10 each side.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Ten standing oblique crunches per side. Elbow meets knee.',
  ),
  Exercise(
    id: 'bodyweight_plank',
    name: 'Forearm Plank',
    description:
        'Hold a forearm plank with a straight line from head to heels. '
        'Target 45 seconds.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 75,
    ttsScript:
        'Forty-five-second forearm plank. Straight line, steady breathing.',
  ),
  Exercise(
    id: 'bodyweight_side_plank',
    name: 'Side Plank',
    description:
        'Hold a side plank on each side for 30 seconds. Stack feet and '
        'lift hips high.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Thirty-second side plank on each side. Hips up, shoulders '
        'stacked.',
  ),
  Exercise(
    id: 'bodyweight_deadbug',
    name: 'Dead Bugs',
    description:
        'On your back, extend opposite arm and leg slowly, return, '
        'switch sides. 10 reps per side.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 90,
    ttsScript:
        'Ten dead bugs per side. Opposite arm and leg, slow and '
        'controlled.',
  ),
  Exercise(
    id: 'bodyweight_bird_dog',
    name: 'Bird Dogs',
    description:
        'On hands and knees, extend opposite arm and leg, hold briefly, '
        'return. 10 per side.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 90,
    ttsScript:
        'Ten bird dogs per side. Reach long, keep the hips level.',
  ),
  Exercise(
    id: 'bodyweight_standing_march',
    name: 'Standing Marches',
    description:
        'March in place slowly, lifting knees high. Engage core. '
        '40 steps total.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Forty slow high-knee marches. Nice and quiet — your coworkers '
        'will thank you.',
  ),
  Exercise(
    id: 'bodyweight_seated_torso_twist',
    name: 'Seated Torso Twists',
    description:
        'Sit tall, hands across chest. Rotate slowly side to side for '
        '20 reps total.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Twenty seated torso twists. Sit tall, rotate from the ribs.',
  ),

  // ---------------------------------------------------------------
  // BODYWEIGHT — LOWER
  // ---------------------------------------------------------------
  Exercise(
    id: 'bodyweight_bodyweight_squat',
    name: 'Bodyweight Squats',
    description:
        'Feet shoulder-width, lower hips back and down until thighs '
        'are parallel to floor. 15 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Fifteen bodyweight squats. Hips back, chest proud.',
  ),
  Exercise(
    id: 'bodyweight_chair_squat',
    name: 'Chair Squats',
    description:
        'Stand in front of your chair, lower until you just tap the '
        'seat, stand back up. 12 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Twelve chair squats. Tap the seat, stand tall, repeat.',
  ),
  Exercise(
    id: 'bodyweight_wall_sit',
    name: 'Wall Sit',
    description:
        'Lean against a wall with knees at 90 degrees. Hold 45 seconds.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 60,
    ttsScript:
        'Wall sit time. Forty-five seconds, thighs parallel, breathe '
        'through it.',
  ),
  Exercise(
    id: 'bodyweight_calf_raise',
    name: 'Calf Raises',
    description:
        'Stand on both feet, rise onto toes, lower with control. '
        '20 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Twenty slow calf raises. Top of the rep, squeeze the calves.',
  ),
  Exercise(
    id: 'bodyweight_reverse_lunge',
    name: 'Reverse Lunges',
    description:
        'Step one leg back into a lunge, return, alternate. '
        '10 reps per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten reverse lunges per leg. Step back, sink, drive up.',
  ),
  Exercise(
    id: 'bodyweight_glute_bridge',
    name: 'Glute Bridges',
    description:
        'On your back, knees bent, drive hips to ceiling. Squeeze '
        'glutes hard at top. 15 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Fifteen glute bridges. Squeeze those glutes at the top of '
        'every rep.',
  ),
  Exercise(
    id: 'bodyweight_single_leg_glute_bridge',
    name: 'Single-Leg Glute Bridges',
    description:
        'Glute bridge with one leg extended. 8 reps per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Eight single-leg glute bridges per side. Keep the hips level.',
  ),
  Exercise(
    id: 'bodyweight_standing_hip_circles',
    name: 'Standing Hip Circles',
    description:
        'Balance on one leg, draw 10 circles with the other knee. '
        'Switch sides.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Ten hip circles per leg. Loosen up those locked-in hips.',
  ),

  // ---------------------------------------------------------------
  // BODYWEIGHT — FULL BODY
  // ---------------------------------------------------------------
  Exercise(
    id: 'bodyweight_squat_to_reach',
    name: 'Squat to Overhead Reach',
    description:
        'Squat down, then stand and reach both arms overhead. '
        '12 reps.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Twelve squats to overhead reach. Squat, stand, reach for the '
        'ceiling.',
  ),
  Exercise(
    id: 'bodyweight_inchworm',
    name: 'Inchworms',
    description:
        'From standing, hinge forward, walk hands out to plank, walk '
        'them back, stand. 8 reps.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Eight slow inchworms. Walk out to a plank, walk back, stand '
        'tall.',
  ),
  Exercise(
    id: 'bodyweight_worlds_greatest_stretch',
    name: 'World\'s Greatest Stretch',
    description:
        'Lunge, place hand beside front foot, rotate opposite arm to '
        'ceiling. 5 reps per side.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 120,
    ttsScript:
        'Five World\'s Greatest Stretches per side. Lunge, rotate, '
        'open up.',
  ),

  // ---------------------------------------------------------------
  // KETTLEBELL
  // ---------------------------------------------------------------
  Exercise(
    id: 'kettlebell_deadlift',
    name: 'Kettlebell Deadlift',
    description:
        'Kettlebell between feet, hinge at hips, grip and stand tall. '
        '10 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten kettlebell deadlifts. Hinge, grip, drive the hips through.',
  ),
  Exercise(
    id: 'kettlebell_suitcase_deadlift',
    name: 'Kettlebell Suitcase Deadlift',
    description:
        'Kettlebell at one side, hinge and stand while keeping torso '
        'level. 8 reps per side.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Eight suitcase deadlifts per side. Resist the tilt — keep '
        'those shoulders level.',
  ),
  Exercise(
    id: 'kettlebell_goblet_squat',
    name: 'Kettlebell Goblet Squat',
    description:
        'Hold kettlebell at chest by the horns, squat to parallel. '
        '12 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Twelve goblet squats. Kettlebell at the chest, sink low, '
        'stand strong.',
  ),
  Exercise(
    id: 'kettlebell_halo',
    name: 'Kettlebell Halos',
    description:
        'Hold kettlebell by the horns, circle it around your head. '
        '5 reps each direction.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Five kettlebell halos each direction. Smooth and slow around '
        'the head.',
  ),
  Exercise(
    id: 'kettlebell_single_arm_row',
    name: 'Kettlebell Single-Arm Row',
    description:
        'Hinge forward with support, row kettlebell to hip. '
        '10 reps per side.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Ten kettlebell rows per side. Pull to the hip, squeeze the '
        'back.',
  ),
  Exercise(
    id: 'kettlebell_strict_press',
    name: 'Kettlebell Strict Press',
    description:
        'Kettlebell in rack position, press overhead. 8 reps per side.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Eight strict presses per arm. Press straight up, lock it out.',
  ),
  Exercise(
    id: 'kettlebell_farmer_hold',
    name: 'Kettlebell Farmer Hold',
    description:
        'Hold a kettlebell in each hand (or one), stand tall. '
        'Hold 45 seconds.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 60,
    ttsScript:
        'Forty-five-second farmer hold. Tall posture, crushing grip.',
  ),
  Exercise(
    id: 'kettlebell_suitcase_carry',
    name: 'Kettlebell Suitcase Carry',
    description:
        'Carry one kettlebell at your side, walking in place or short '
        'path. 30 seconds per side.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Thirty-second suitcase carry per side. Stay tall, resist '
        'leaning.',
  ),
  Exercise(
    id: 'kettlebell_russian_swing',
    name: 'Kettlebell Russian Swing',
    description:
        'Hinge-driven swing to chest height. Quiet hip pop. 15 reps.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.vigorous,
    durationSeconds: 90,
    ttsScript:
        'Fifteen Russian kettlebell swings. Drive with the hips, eye '
        'level only.',
  ),
  Exercise(
    id: 'kettlebell_dead_clean',
    name: 'Kettlebell Dead Clean',
    description:
        'From the floor, clean kettlebell to rack position, reset each '
        'rep. 6 per side.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Six dead cleans per side. Reset every rep, nice and controlled.',
  ),
  Exercise(
    id: 'kettlebell_bottoms_up_hold',
    name: 'Kettlebell Bottoms-Up Hold',
    description:
        'Grip kettlebell handle with bell up, hold steady in rack. '
        '20 seconds per side.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Twenty-second bottoms-up hold each side. Grip hard, bell up.',
  ),
  Exercise(
    id: 'kettlebell_around_the_world',
    name: 'Kettlebell Around-the-World',
    description:
        'Pass kettlebell around your waist in a circle. 5 reps each '
        'direction.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.kettlebell,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Five around-the-worlds each direction. Smooth hand-offs, tight '
        'core.',
  ),

  // ---------------------------------------------------------------
  // DUMBBELL
  // ---------------------------------------------------------------
  Exercise(
    id: 'dumbbell_bicep_curl',
    name: 'Dumbbell Bicep Curls',
    description:
        'Curl both dumbbells with strict form. 12 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 75,
    ttsScript:
        'Twelve strict bicep curls. No swinging — make them work.',
  ),
  Exercise(
    id: 'dumbbell_hammer_curl',
    name: 'Dumbbell Hammer Curls',
    description:
        'Neutral grip curl, palms facing each other. 12 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 75,
    ttsScript:
        'Twelve hammer curls. Palms facing in — hit those forearms.',
  ),
  Exercise(
    id: 'dumbbell_overhead_press',
    name: 'Dumbbell Overhead Press',
    description:
        'Press both dumbbells overhead from shoulder height. '
        '10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten overhead presses. Press up, squeeze, control the descent.',
  ),
  Exercise(
    id: 'dumbbell_lateral_raise',
    name: 'Dumbbell Lateral Raises',
    description:
        'Raise dumbbells out to the sides to shoulder height. '
        '12 slow reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Twelve lateral raises. Lead with the elbows, slow on the way '
        'down.',
  ),
  Exercise(
    id: 'dumbbell_front_raise',
    name: 'Dumbbell Front Raises',
    description:
        'Raise dumbbells straight in front to shoulder height. '
        '10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Ten front raises. Slow up, slow down.',
  ),
  Exercise(
    id: 'dumbbell_bent_over_row',
    name: 'Dumbbell Bent-Over Row',
    description:
        'Hinge forward flat-backed, row dumbbells to ribs. 10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten bent-over rows. Hinge flat, row to the ribs, squeeze the '
        'back.',
  ),
  Exercise(
    id: 'dumbbell_goblet_squat',
    name: 'Dumbbell Goblet Squat',
    description:
        'Hold one dumbbell vertical at chest, squat to parallel. '
        '12 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Twelve dumbbell goblet squats. Chest tall, sink to parallel.',
  ),
  Exercise(
    id: 'dumbbell_romanian_deadlift',
    name: 'Dumbbell Romanian Deadlift',
    description:
        'Dumbbells in front of thighs, hinge at hips with slight knee '
        'bend, return. 10 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten Romanian deadlifts. Soft knees, hinge until you feel the '
        'hamstrings.',
  ),
  Exercise(
    id: 'dumbbell_reverse_lunge',
    name: 'Dumbbell Reverse Lunge',
    description:
        'Hold dumbbells at sides, step one leg back into a lunge. '
        '8 per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Eight dumbbell reverse lunges per leg. Sink the back knee '
        'toward the floor.',
  ),
  Exercise(
    id: 'dumbbell_tricep_kickback',
    name: 'Dumbbell Tricep Kickbacks',
    description:
        'Hinge forward, pin elbows to ribs, extend arms straight back. '
        '12 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Twelve tricep kickbacks. Elbows pinned, extend and squeeze.',
  ),
  Exercise(
    id: 'dumbbell_farmer_walk',
    name: 'Dumbbell Farmer Walk',
    description:
        'Hold heavy dumbbells at sides, walk in place or short path '
        'for 45 seconds.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.dumbbell,
    intensity: IntensityTier.moderate,
    durationSeconds: 75,
    ttsScript:
        'Forty-five seconds of farmer walking. Tall posture, strong '
        'grip.',
  ),

  // ---------------------------------------------------------------
  // RESISTANCE BAND
  // ---------------------------------------------------------------
  Exercise(
    id: 'resistanceband_pull_apart',
    name: 'Band Pull-Aparts',
    description:
        'Hold band at shoulder height, pull apart until arms are wide. '
        '15 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Fifteen band pull-aparts. Squeeze the shoulder blades together.',
  ),
  Exercise(
    id: 'resistanceband_overhead_pull_apart',
    name: 'Overhead Band Pull-Aparts',
    description:
        'Raise band overhead and pull apart to shoulder level. '
        '10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Ten overhead band pull-aparts. Go slow, keep elbows straight.',
  ),
  Exercise(
    id: 'resistanceband_row',
    name: 'Seated Band Row',
    description:
        'Anchor band around feet or desk leg, sit tall, row elbows '
        'back. 15 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Fifteen seated band rows. Pull to the ribs, drive the elbows '
        'back.',
  ),
  Exercise(
    id: 'resistanceband_bicep_curl',
    name: 'Band Bicep Curls',
    description:
        'Stand on center of band, curl handles up. 15 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Fifteen band curls. Control the tension on the way down.',
  ),
  Exercise(
    id: 'resistanceband_tricep_press_down',
    name: 'Band Tricep Press-Downs',
    description:
        'Anchor band above head, press hands down to thighs. '
        '15 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Fifteen band press-downs. Pin those elbows to your sides.',
  ),
  Exercise(
    id: 'resistanceband_lateral_walk',
    name: 'Band Lateral Walks',
    description:
        'Loop band above knees, sink into a quarter squat, step side '
        'to side. 20 total steps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Twenty lateral band walks. Stay low, push the band apart.',
  ),
  Exercise(
    id: 'resistanceband_glute_bridge',
    name: 'Banded Glute Bridges',
    description:
        'Loop band above knees, push knees outward while bridging. '
        '15 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Fifteen banded glute bridges. Drive the knees out, squeeze up '
        'top.',
  ),
  Exercise(
    id: 'resistanceband_standing_clamshell',
    name: 'Standing Banded Clamshells',
    description:
        'Loop band above knees, rotate one knee out while standing. '
        '12 per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 90,
    ttsScript:
        'Twelve standing clamshells per side. Keep the hips square.',
  ),
  Exercise(
    id: 'resistanceband_pallof_press',
    name: 'Band Pallof Press',
    description:
        'Anchor band at chest height, stand sideways, press out and '
        'resist rotation. 10 per side.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Ten Pallof presses per side. Resist the twist, stay square.',
  ),
  Exercise(
    id: 'resistanceband_face_pull',
    name: 'Band Face Pulls',
    description:
        'Anchor band at eye level, pull handles toward your face, '
        'elbows high. 15 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Fifteen face pulls. Elbows high, pull to the temples.',
  ),

  // ---------------------------------------------------------------
  // WEIGHTED VEST
  // ---------------------------------------------------------------
  Exercise(
    id: 'weightedvest_march',
    name: 'Weighted Vest March',
    description:
        'Slip on the vest and march in place with high knees for '
        '90 seconds.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.moderate,
    durationSeconds: 120,
    ttsScript:
        'Ninety seconds of marching in your weighted vest. Steady, '
        'strong strides.',
  ),
  Exercise(
    id: 'weightedvest_squat',
    name: 'Weighted Vest Squats',
    description:
        'Wear vest, perform bodyweight squats. 12 reps.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Twelve vest squats. The weight just makes them better.',
  ),
  Exercise(
    id: 'weightedvest_pushup',
    name: 'Weighted Vest Incline Pushups',
    description:
        'Wear vest, do incline pushups on a desk or chair. 10 reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Ten vest pushups on an incline. Control the drop.',
  ),
  Exercise(
    id: 'weightedvest_wall_sit',
    name: 'Weighted Vest Wall Sit',
    description:
        'Wear vest, hold a 90-degree wall sit for 45 seconds.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.vigorous,
    durationSeconds: 60,
    ttsScript:
        'Forty-five-second vest wall sit. You have got this.',
  ),
  Exercise(
    id: 'weightedvest_standing_calf_raise',
    name: 'Weighted Vest Calf Raises',
    description:
        'Wear vest, perform 20 slow calf raises.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Twenty slow calf raises in the vest. Squeeze at the top.',
  ),
  Exercise(
    id: 'weightedvest_glute_bridge',
    name: 'Weighted Vest Glute Bridges',
    description:
        'Wear vest on chest/hips, perform 15 glute bridges.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.moderate,
    durationSeconds: 90,
    ttsScript:
        'Fifteen vest glute bridges. Big squeeze up top.',
  ),
  Exercise(
    id: 'weightedvest_standing_desk_wear',
    name: 'Weighted Vest Standing Desk Session',
    description:
        'Simply wear the vest while working at a standing desk for '
        '3 minutes.',
    bodyRegion: BodyRegion.full,
    equipment: EquipmentTag.weightedVest,
    intensity: IntensityTier.light,
    durationSeconds: 180,
    ttsScript:
        'Slip on your weighted vest and keep working at the standing '
        'desk for three minutes. Easy gains.',
  ),

  // ---------------------------------------------------------------
  // TREADMILL (under-desk variations)
  // ---------------------------------------------------------------
  Exercise(
    id: 'treadmill_easy_walk',
    name: 'Easy Walking Interval',
    description:
        'Set treadmill to a comfortable 2 mph pace and walk for '
        '3 minutes.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.treadmill,
    intensity: IntensityTier.light,
    durationSeconds: 180,
    ttsScript:
        'Three easy minutes on the treadmill — two miles per hour. '
        'Just keep moving.',
  ),
  Exercise(
    id: 'treadmill_brisk_walk',
    name: 'Brisk Walking Interval',
    description:
        'Pick up to 3 mph for 3 minutes while working.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.treadmill,
    intensity: IntensityTier.moderate,
    durationSeconds: 180,
    ttsScript:
        'Let us bump it to three miles per hour for three minutes. '
        'Brisk and focused.',
  ),
  Exercise(
    id: 'treadmill_pace_ladder',
    name: 'Pace Ladder',
    description:
        'Walk 1 min at 2 mph, 1 min at 2.5 mph, 1 min at 3 mph.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.treadmill,
    intensity: IntensityTier.moderate,
    durationSeconds: 180,
    ttsScript:
        'Three-minute pace ladder — two, two-point-five, then three '
        'miles per hour.',
  ),
  Exercise(
    id: 'treadmill_backward_walk',
    name: 'Slow Backward Walk',
    description:
        'At 1 mph or slower, hold a rail and walk backward for '
        '90 seconds. Great for knees.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.treadmill,
    intensity: IntensityTier.light,
    durationSeconds: 120,
    ttsScript:
        'Ninety seconds of slow backward walking. Hold the rail and '
        'feel those quads wake up.',
  ),
  Exercise(
    id: 'treadmill_stand_and_reset',
    name: 'Treadmill Pause and Stretch',
    description:
        'Step off the treadmill, do 10 deep breaths and a calf '
        'stretch on each side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.treadmill,
    intensity: IntensityTier.light,
    durationSeconds: 90,
    ttsScript:
        'Step off the treadmill for a minute. Deep breaths and a calf '
        'stretch each side.',
  ),
  Exercise(
    id: 'treadmill_slow_meeting_walk',
    name: 'Meeting-Friendly Stroll',
    description:
        'Ultra-quiet 1.5 mph walk for 5 minutes — perfect during audio '
        'meetings.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.treadmill,
    intensity: IntensityTier.light,
    durationSeconds: 300,
    ttsScript:
        'Five minutes of easy strolling at one-point-five miles per '
        'hour. Meeting-friendly.',
  ),

  // ---------------------------------------------------------------
  // PURE STRETCHES (low intensity, mixed equipment tags)
  // ---------------------------------------------------------------
  Exercise(
    id: 'stretch_upper_trap',
    name: 'Upper Trap Stretch',
    description:
        'Gently pull head to one side with same-side hand. Hold 30 '
        'seconds per side.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Thirty seconds of upper trap stretch on each side. Gentle — '
        'do not force it.',
  ),
  Exercise(
    id: 'stretch_levator_scapulae',
    name: 'Levator Scapulae Stretch',
    description:
        'Turn chin toward armpit, gently pull head down. 30 seconds '
        'per side.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Levator stretch — chin to armpit, thirty seconds per side. '
        'Breathe into it.',
  ),
  Exercise(
    id: 'stretch_seated_spinal_twist',
    name: 'Seated Spinal Twist',
    description:
        'Sit tall, cross one leg, rotate torso toward crossed leg. '
        '30 seconds per side.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Seated spinal twist, thirty seconds per side. Sit tall, '
        'rotate gently.',
  ),
  Exercise(
    id: 'stretch_hip_flexor',
    name: 'Kneeling Hip Flexor Stretch',
    description:
        'Kneel on one knee, drive hips forward to feel front-hip '
        'stretch. 30 seconds per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Kneeling hip flexor stretch, thirty seconds per side. Your '
        'hips will thank you.',
  ),
  Exercise(
    id: 'stretch_figure_four',
    name: 'Seated Figure-Four Stretch',
    description:
        'Ankle on opposite knee, hinge forward gently. 30 seconds '
        'per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Figure-four stretch, thirty seconds per side. Open those '
        'glutes up.',
  ),
  Exercise(
    id: 'stretch_standing_hamstring',
    name: 'Standing Hamstring Stretch',
    description:
        'Heel on chair seat, gently hinge forward. 30 seconds per side.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Hamstring stretch with your heel on a chair. Thirty seconds '
        'per side.',
  ),
  Exercise(
    id: 'stretch_cat_cow',
    name: 'Cat-Cow',
    description:
        'On hands and knees, alternate arching and rounding the spine. '
        '10 slow reps.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Ten slow cat-cows. Inhale to cow, exhale to cat.',
  ),
  Exercise(
    id: 'stretch_band_shoulder_dislocate',
    name: 'Band Shoulder Pass-Throughs',
    description:
        'Hold band wide, slowly raise it overhead and behind your back. '
        '8 slow reps.',
    bodyRegion: BodyRegion.upper,
    equipment: EquipmentTag.resistanceBand,
    intensity: IntensityTier.light,
    durationSeconds: 75,
    ttsScript:
        'Eight band pass-throughs. Keep the arms straight, go as wide '
        'as you need.',
  ),

  // ---------------------------------------------------------------
  // EXTRA LOW-IMPACT / SKIP-FRIENDLY OPTIONS
  // (Designed as kind alternatives for tired or recovering days)
  // ---------------------------------------------------------------
  Exercise(
    id: 'bodyweight_deep_breathing',
    name: 'Box Breathing',
    description:
        'Inhale 4, hold 4, exhale 4, hold 4. Repeat 8 cycles.',
    bodyRegion: BodyRegion.none,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 120,
    ttsScript:
        'Eight rounds of box breathing — inhale four, hold four, exhale '
        'four, hold four. Reset.',
  ),
  Exercise(
    id: 'bodyweight_eye_rest',
    name: '20-20-20 Eye Break',
    description:
        'Look at something 20 feet away for 20 seconds. Do this three '
        'times.',
    bodyRegion: BodyRegion.none,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'Eye break. Look twenty feet away for twenty seconds, three '
        'times. Unperch those eyes.',
  ),
  Exercise(
    id: 'bodyweight_posture_reset',
    name: 'Posture Reset',
    description:
        'Stand tall, roll shoulders back, draw belly in, hold tall '
        'posture for 60 seconds.',
    bodyRegion: BodyRegion.core,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 60,
    ttsScript:
        'One-minute posture reset. Shoulders back, crown tall, belly '
        'gently braced.',
  ),
  Exercise(
    id: 'bodyweight_slow_stairs',
    name: 'One Flight of Stairs',
    description:
        'Walk up one flight of stairs and back down at a relaxed pace.',
    bodyRegion: BodyRegion.lower,
    equipment: EquipmentTag.bodyweight,
    intensity: IntensityTier.light,
    durationSeconds: 120,
    ttsScript:
        'Head to the nearest stairs — up one flight and back. Easy '
        'pace, fresh legs.',
  ),
];
