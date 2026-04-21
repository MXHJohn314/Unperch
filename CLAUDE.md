# CLAUDE.md

This file provides guidance to Claude Code when working with the Unperch repository.

## Project Overview

**Unperch** is a FOSS Android/iOS office-wellness companion app built with Flutter. It uses text-to-speech to prompt users to drink water, stretch, and do bodyweight/equipment exercises throughout their work shift. It also integrates with under-desk treadmills via BLE.

**License:** GPL-3.0  
**Package:** `com.mxhjohn314.unperch`  
**Min SDK:** Android 5.0 (API 21) / iOS 12  

---

## Build Commands

```bash
flutter run                        # Run on connected device/emulator
flutter build apk                  # Build Android APK
flutter build ios                  # Build iOS (requires Xcode)
flutter test                       # Run unit tests
flutter analyze                    # Lint / static analysis
flutter pub get                    # Install dependencies
```

---

## Architecture

**Flutter + BLoC (or Riverpod) + Drift (SQLite) + DataStore (shared_preferences)**

### Module Structure (planned)

```
lib/
  main.dart
  app.dart                          # Root widget, theme, routing
  core/
    enums/                          # All enum taxonomy (see Enum Design below)
    models/                         # Pure data classes
    services/
      tts/                          # TTS service abstraction
      notification/                 # Foreground service + alarm scheduling
      treadmill/                    # BLE treadmill integration (see Treadmill section)
    db/                             # Drift database + DAOs
    datastore/                      # SharedPreferences keys + DataStore wrapper
  features/
    onboarding/                     # First-run wizard
    overview/                       # Stats dashboard
    calendar/                       # Shift calendar + day drill-down
    exercises/                      # Exercise library + session UI
    settings/                       # Options screen (mirrors wizard, scrollable)
    equipment/                      # Equipment checklist
    treadmill/                      # Treadmill device screen
```

---

## Enum Design

Events/exercises are identified by a **product of enums** — a combination of values, each from a different enumeration. This allows filtering and type-safe composition without coupling. Inspired by the gesture-object pattern in the Griddle project.

Core enum axes (expand as needed):
- `ReminderType` — `water`, `stretch`, `exercise`, `treadmill`
- `BodyRegion` — `upper`, `core`, `lower`, `full`, `none`
- `EquipmentTag` — `bodyweight`, `kettlebell`, `dumbbell`, `resistanceBand`, `weightedVest`, `treadmill`
- `IntensityTier` — `light`, `moderate`, `vigorous`
- `SkipScope` — `thisInstance`, `today`, `untilDate`, `indefinitely`

---

## Skip / Postpone System

When a user skips an exercise:
1. App asks scope: `thisInstance | today | untilDate | indefinitely`
2. `untilDate` offers preset choices (tomorrow, this week, 2 weeks, 1 month, 3 months, 1 year) **and** a date picker
3. On expiry, app notifies the user that the exercise has been re-enabled
4. Skip records stored in Drift with `(exerciseId, scope, expiresAt?)` — filter at query time

---

## Treadmill Integration

All treadmill drivers follow a strict typed hierarchy:

```
TreadmillDevice (interface)
  └── AbstractTreadmillDevice (abstract class — shared BLE scaffolding)
        ├── WalkingPadDevice (abstract — WalkingPad make)
        │     ├── WalkingPadA1Device
        │     └── WalkingPadC2Device
        ├── LifeSpanDevice (abstract)
        │     └── LifeSpanTR1200DTDevice
        ├── IWalkDevice (abstract)
        ├── WalkolutionDevice (abstract)
        └── UrevoDevice (abstract)
```

`TreadmillDevice` exposes: `connect()`, `disconnect()`, `getSpeed()`, `setSpeed()`, `getSteps()`, `getCalories()`, `getDuration()`, `deviceInfo`.

Stats from treadmill feed into the Overview screen.

**BLE library:** `flutter_blue_plus`

---

## Onboarding Wizard (first run)

Steps:
1. Shift hours (start/end time picker)
2. Working days (day-of-week toggles)
3. Equipment checklist (bodyweight always on; optional: kettlebell, dumbbell, resistance band, weighted vest, under-desk treadmill)
4. Reminder intervals (water: every N min; exercise: every N min — user-set)
5. Injury/body-area exclusions (optional, multi-select `BodyRegion`)
6. TTS preferences (voice, speed, pitch)
7. Notification preferences

Settings screen mirrors wizard content in a scrollable form. "Run wizard again" button available in settings.

---

## Shift & Calendar

- Calendar view shows work days; tap a day to drill into Day View
- Day View: scrollable list of all reminders/exercises scheduled for that shift
- Edit shift: drag a bar across an 8-hour scale with 15-minute tick marks
- "Out of Office" toggle per day — suspends all reminders for that day (no label judgment)
- Clock-driven scheduling: assumes user is present and on time

---

## Overview / Stats Screen

Timeframes: Today | Last 30 Days | Last Year | All Time

Stats to display:
- Exercises completed vs. scheduled (compliance %)
- Water reminders acknowledged
- Active streak (consecutive shift-days with ≥ X% compliance — threshold TBD)
- Steps / treadmill time (if treadmill connected)
- Most-skipped exercise (insight)
- Exercises by body region (balance chart)

---

## Settings / Options

- Theme: Light / Dark / High Contrast
- TTS: voice selector, speed, pitch
- Notification sound + vibration pattern
- Reminder intervals (water, exercise)
- Vacation/OOO defaults
- Data export (JSON — wait until schema settles before implementing)
- "Run wizard again" button

---

## DataStore Keys (SharedPreferences)

All user preferences live under typed keys in a central `UnperchDataStore` wrapper. Keys:
- `shiftStartMinutes`, `shiftEndMinutes`, `workingDays`
- `waterIntervalMinutes`, `exerciseIntervalMinutes`
- `equippedItems` (Set<EquipmentTag>)
- `excludedBodyRegions` (Set<BodyRegion>)
- `ttsVoice`, `ttsSpeed`, `ttsPitch`
- `theme` (ThemeMode enum)
- `notificationSoundUri`, `vibrationPattern`
- `complianceStreakThreshold`
- `onboardingComplete`

---

## Background Service

- Android: `flutter_background_service` foreground service with persistent notification
- iOS: background task via `flutter_background_service` + local notifications
- Alarms/timers fire TTS + local notification at each reminder interval
- Service re-evaluates OOO flag and skip records before each prompt

---

## Exercise Library

Bundled, curated by region + equipment tag + intensity tier. User cannot add custom exercises in MVP. Research and curation is a separate agent task — do not implement placeholder data until the library agent delivers.

---

## Team / Agent Notes

| Role | Responsibility |
|---|---|
| Flutter architect | Project scaffold, routing, state pattern |
| Data modeler | Drift schema, DataStore, enum taxonomy |
| Treadmill BLE researcher | GATT profiles per brand, driver scaffolding |
| Exercise library curator | Bundled exercise list (Opus recommended) |
| Background service engineer | Foreground service, alarm scheduling, TTS |
| UI implementer | All screens per spec above |
