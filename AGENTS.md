# AGENTS.md

## Project purpose

Perspective Crime is a compact, playful, **non-AI** 3D puzzle game. Prioritize an actual player-facing interaction over abstractions, research scaffolding, or speculative features.

## Technical baseline

- Godot 4.x (minimum target 4.3), GDScript; default project renderer: Compatibility.
- Run offline, from a clean clone, on **Linux and Windows**.
- Prefer procedural primitives and minimal scenes. Do not add external services, paid dependencies, telemetry, generated binaries, or large assets for the initial prototype.
- Keep `project.godot`, the main scene, and all required files committed; exclude Godot caches via `.gitignore`.
- Avoid extra CI workflows, hashes, redundant audit files, or elaborate contribution gates in this small project.

## Gameplay invariants

1. Project 3D anchors through the active `Camera3D` to compare screen-space positions.
2. Exclude anchors behind the camera or outside the viewport. Handle occlusion explicitly, with a consistent rule.
3. A successful alignment produces an actual traversable world-space bridge with a `StaticBody3D` and direct `CollisionShape3D` child.
4. The player travels via regular physics; never teleport the player to fake a crossing.
5. For the first prototype, restrict bridge endpoints to equal walkable height. Do not imply arbitrary perspective coincidence guarantees physically possible geometry.
6. The player must receive clear ready/not-ready feedback and be able to reset a softlocked attempt.

## First PR

Implement [docs/PR1_SPEC.md](docs/PR1_SPEC.md). Open a PR against `main`; include concise reproduction steps, visual proof (screenshot/GIF or a short clip), and what you actually tested. Use actual run results, not unverified claims.

## Style

Prefer explicit small GDScript components, readable world-space math, and a single end-to-end level. Game feel and clarity matter more than expansive architecture. Document genuine limitations directly.
