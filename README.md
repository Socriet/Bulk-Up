# Bulk Up 🏋️

A gamified fitness app built with Flutter that transforms your gym volume into XP for a digital creature companion.

## Concept

Every kilogram you lift becomes XP. As your total training volume grows, your digital creature **Bulkosaur** evolves through 10 levels — giving you a visual, motivating reason to keep showing up.

## Features (Planned)

| Week | Feature |
|------|---------|
| ✅ Week 1 | Project structure, SQLite database, 3-screen navigation skeleton |
| Week 2 | Workout logging UI + XP calculation logic |
| Week 3 | Creature evolution system + visual assets |
| Week 4 | Usability testing, polish, final documentation |

## Screens

1. **Home / Dashboard** — Creature display, level, XP progress bar, recent sessions
2. **Workout** — Log exercises (exercise, sets, reps, weight), live session stats
3. **History** — Expandable log of all past workout sessions

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Database:** SQLite via `sqflite`
- **UI Fonts:** Google Fonts (Rajdhani + Space Grotesk)

## XP Formula

```
Volume = Sets × Reps × Weight (kg)
XP = Volume ÷ 10  (rounded down)

Example: 3 sets × 10 reps × 100 kg = 3000 kg volume = 300 XP
```

## Level Thresholds

| Level | XP Required |
|-------|------------|
| 1 | 0 |
| 2 | 1,000 |
| 3 | 3,000 |
| 4 | 6,000 |
| 5 | 10,000 |
| 6 | 15,000 |
| 7 | 21,000 |
| 8 | 28,000 |
| 9 | 36,000 |
| 10 | 45,000 |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Clean before archiving
flutter clean
```

## Project Structure

```
lib/
├── main.dart                  # App entry point + navigation shell
├── database/
│   └── database_helper.dart   # SQLite schema + CRUD helpers
├── models/
│   ├── app_state.dart         # Provider state management
│   ├── creature.dart          # Creature data model
│   ├── workout_session.dart   # Session data model
│   └── exercise_set.dart      # Individual exercise set model
├── screens/
│   ├── home_screen.dart       # Dashboard + creature
│   ├── workout_screen.dart    # Active workout logging
│   └── history_screen.dart    # Past sessions
└── widgets/
    ├── app_theme.dart         # Colors, typography, ThemeData
    ├── creature_display.dart  # Creature card widget
    ├── xp_progress_bar.dart   # Level progress widget
    └── stat_card.dart         # Reusable stat tile
```
