# PR #1 — First Playable Perspective Bridge

**Goal:** deliver one reproducible, complete puzzle in Godot 4, using the current starter scene.

## Deliverable

- Orbit/zoom camera with controllable input and reliable bounds.
- A visible player character with ordinary `CharacterBody3D` movement, gravity, jumping (if needed), and ground collision.
- Two separated islands and one goal marker; leaving the ground resets to a safe spawn.
- Two world-space anchor positions. Holding **Shift** reveals alignment state calculated from the current camera projection; if the anchors are offscreen, behind camera, or disallowed by the chosen occlusion rule, alignment must be invalid.
- Press **E** while valid to construct one walkable, level world-space bridge with a `StaticBody3D`, `BoxMesh`, and `CollisionShape3D`.
- The character can walk across the actual bridge and reach a visible WIN/LEVEL COMPLETE state.
- **R** resets state (bridge and player); no irreversible soft lock.
- Simple UI: input hints, alignment ready/not ready, and completed state.
- Concise README changes describing final controls and verified run steps.

## Math and physics expectations

- Use the real `Camera3D.unproject_position()` projection and pixel-distance tolerance; no camera-position hardcoded success switch.
- Restrict the first puzzle to approximately equal-height anchor decks. Calculate the bridge length/orientation from the world-space anchor endpoints and include small overlap into both platforms.
- Collision works even if the camera changes after commitment. The world-space bridge must persist until reset or deliberate replacement.
- Prevent lock when anchors are behind camera/outside frustum, and document visibility handling.
- Never teleport the character across the gap; walking/physics is the proof that the bridge is real.

## Verification requested

1. Run the clean clone on desktop with Godot 4.x (specify exact tested version and OS).
2. Before alignment, `E` creates nothing and the void is not passable.
3. On valid alignment, feedback turns ready; pressing `E` creates a visible, collidable bridge.
4. Move across and trigger completion with the bridge remaining in place.
5. Reset, repeat; invalid/offscreen/occluded alignment is rejected.
6. Check a Linux launch where available; otherwise state clearly that it was not tested.
7. Include a screenshot/GIF or short recording and a brief PR description.

## Scope

Make the *one* puzzle fun, legible and reliable. Do not implement all five levels, add ML/agents/online services, build a custom renderer, or create extensive CI. Feel free to adjust island placement and camera presets to make a convincing, solvable alignment experience.

Open a PR against `main` with this playable vertical slice. Do not merge it yourself.
