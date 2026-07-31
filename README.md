# Tiny Think — Memory Challenge

Premium Flutter sequence-memory game for children and families.

## Stack

- Flutter + Dart
- Riverpod state management
- Hive local persistence
- Google Mobile Ads (adaptive banner on Home only)
- Audioplayers + HapticFeedback

## Architecture

```
lib/
  controllers/   # Riverpod notifiers
  core/          # constants, theme, utils
  game/          # GameEngine (no widgets)
  models/
  repositories/
  screens/
  services/      # audio, timer, ads, hive
  widgets/
```

Game logic lives in `GameEngine` — widgets never own timers or sequence rules.

## Run

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Grid rule

`gridDimension = ceil(sqrt(squareCount))` with invisible filler cells so every active tile stays 1:1 square.

## Ads

Test AdMob unit IDs are configured. Replace with production IDs in `AppConstants` and platform manifests before release.
