# Skullset

A simple native iOS tracker for Greyskull LP, phrakture's variant. No program choices, no clutter.

- **Workout A:** Overhead Press 3×5+, Chin-ups 3×5+, Squat 3×5+
- **Workout B:** Bench Press 3×5+, Barbell Row 3×5+, Deadlift 1×5+

Workouts alternate A and B. The last set of each lift is as many reps as possible.

## Progression

- All reps done: add 1 kg / 2.5 lb (upper body) or 2.5 kg / 5 lb (lower body).
- 10 or more reps on the last set: add double.
- Reps missed: deload 10%.
- Chin-ups track reps only.

Weights are rounded so you can load them with the plates you choose in Settings.

## Features

Rest timer with notification, plate calculator, history, progress charts, kg/lb, and Apple Health (reads bodyweight, saves workouts).

## Build

Needs Xcode 27 and [XcodeGen](https://github.com/yonaskolb/XcodeGen). The project targets iOS 27.

```sh
xcodegen generate
open Skullset.xcodeproj
```

To run on a device, set your signing team. HealthKit needs it.

## Licence

MIT. See [LICENSE](LICENSE).
