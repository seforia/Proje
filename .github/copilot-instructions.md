<!-- .github/copilot-instructions.md - Project-specific guidance for AI coding agents -->

Purpose
- Give concise, actionable context so an AI assistant can make focused, repo-appropriate code changes quickly.

Quick overview
- This repository contains two parallel prototypes:
  - A Unity 2D prototype under `Assets/Scripts/` (C#): core classes `LevelObject`, `GameManager`, `DragDropManager`, `SaveLoadManager`, and game-object subclasses (`SimpleBlock`, `BouncySpring`, `GoalTarget`).
  - A Flutter + Flame/Forge2D mobile prototype under `egitim_oyun_platformu/` (Dart). Key files: `lib/` (game code), `lib/services/` (e.g. `firebase_service.dart`, `gemini_service.dart`), and `pubspec.yaml` for dependencies.

Important patterns & conventions
- Serialization: Unity save format uses `LevelObjectSaveData` with fields: `type`, `position` (SerializableVector2 -> x,y), `rotation`, and optional `extraFloat`/`extraString`. Save/Load uses `SaveLoadManager` -> JSON via `JsonUtility`.
- Prefab mapping: `SaveLoadManager.prefabMap` and `DragDropManager.prefabs` map a `typeName` string to a prefab GameObject. Keep `typeName` consistent with `LevelObject.objectType`.
- Mode switching: `GameManager.SetMode(Mode.Edit|Mode.Play)` calls `EnterEditMode()` / `EnterPlayMode()` on all `LevelObject` instances to toggle physics (kinematic vs dynamic).
- Grid snapping: `DragDropManager` exposes `gridSize` used to round world positions when placing objects. Maintain that parameter when adding new drag behaviour.
- Unity class structure: subclasses of `LevelObject` override `ToSaveData()` and `FromSaveData()` to persist custom fields (e.g., `BouncySpring.springForce` stored in `extraFloat`).

Where to make changes
- Add new LevelObject kinds: create a new script in `Assets/Scripts/`, set `objectType` in `Reset()` and implement persistence by overriding `ToSaveData()`/`FromSaveData()`.
- Wire prefabs: after creating a prefab in Unity, add it to `SaveLoadManager.prefabMap` and `DragDropManager.prefabs` (matching `typeName`).
- Flutter services: `lib/services/firebase_service.dart` provides Firestore/Storage helpers; `lib/services/gemini_service.dart` demonstrates calling Gemini REST. Use `--dart-define` for `GEMINI_API_KEY` in dev runs.

Build / dev workflows (explicit commands)
- Unity: open project in Unity Editor. There is no automated Unity build script in this repo. For CI or builds, use Unity editor or Unity Hub to build target platform.
- Flutter (mobile prototype):
  - Install deps: `cd egitim_oyun_platformu && flutter pub get`
  - Initialize Firebase (interactive): install CLIs then run `firebase login` and `dart pub global activate flutterfire_cli` then `flutterfire configure`.
  - Run on device/emulator: `flutter run --dart-define=GEMINI_API_KEY="<KEY>"` (ensure `pubspec.yaml` contains required packages: `firebase_core`, `cloud_firestore`, `firebase_storage`, `http`, `flame`, `flame_forge2d`).

Integration & external services
- Firebase: code in `lib/services/firebase_service.dart` (save/load levels to `levels` collection and upload level files to Storage). Expect `flutterfire configure` to generate `lib/firebase_options.dart`.
- Gemini (Generative API): `lib/services/gemini_service.dart` sends REST calls to Google Generative Language. The repo uses `--dart-define=GEMINI_API_KEY` rather than hardcoding keys.

Files that explain core behavior (read before edits)
- `Assets/Scripts/LevelObject.cs` — base save/load shape and lifecycle methods.
- `Assets/Scripts/SaveLoadManager.cs` — JSON mapping and prefab lookup.
- `Assets/Scripts/DragDropManager.cs` — mouse/preview/placement, `gridSize` usage.
- `Assets/Scripts/GameManager.cs` — global mode switching and goal handling.
- `egitim_oyun_platformu/lib/services/firebase_service.dart` — Firestore / Storage usage.
- `egitim_oyun_platformu/lib/services/gemini_service.dart` — REST usage and expected ENV key pattern.

Editing rules for AI agents
- Preserve existing public APIs and serialized field names (e.g., `objectType`, `LevelObjectSaveData` fields) to keep save/load compatibility.
- When adding new serialized properties to Unity objects, implement both `ToSaveData()` and `FromSaveData()` and store extras into `extraFloat`/`extraString` (or extend `LevelObjectSaveData` consistently across repo).
- For prefab registration changes, update both `SaveLoadManager.prefabMap` and `DragDropManager.prefabs` (both lists are authoritative at runtime).
- For Flutter services, never embed secret keys in source; use `--dart-define` or a backend proxy. If a key is required for testing only, document it in the PR description.

Testing hints
- Unity scene tests: there are no automated Unity tests. Manual verification steps: create prefabs, assign to managers in scene, switch `GameManager` modes and verify physics toggles.
- Flutter: run `flutter analyze` and `flutter test` in `egitim_oyun_platformu/` after adding any new Dart files.

If you modify save formats
- Add a migration path: keep compatibility by reading both old and new keys. Update `SaveLoadManager.LoadFromJson()` to accept unknown/missing fields gracefully and log warnings rather than throwing.

When to ask maintainers
- If you need platform-specific Unity build scripts, large asset changes, or CI setup (this repo currently doesn't have Unity CI), ask for preferred Unity version and target platforms.

Feedback
- I added this file to the repo; tell me which parts are unclear or where you want more examples (e.g., concrete prefab wiring snippets or sample Flutter widget UI). 
