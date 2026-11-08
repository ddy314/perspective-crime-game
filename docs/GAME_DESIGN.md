# Perspective Crime — Game Design

## Premise

The camera is not just an observer. A certain configuration of the camera can authorize a new connection between two otherwise separated pieces of architecture.

This is a **perspective-activated bridge** puzzle game, not a portal renderer, a generic impossible-geometry engine, or an AI experience.

## The core loop

1. Inspect two islands, a start platform and an exit platform.
2. Orbit the perspective camera until the pair of glowing anchor points nearly coincide **in the rendered 2D view**.
3. Hold **Shift** for focus. The camera overlay reports alignment and highlights a valid pair.
4. Press **E** while focused and valid to commit a bridge between the anchors.
5. The bridge becomes real geometry with collision. Move across it and reach the goal.
6. Press **R** to clear the link/restart the puzzle.

Use direct visible feedback, not hidden precision hunting. The first level should explain itself in under 30 seconds.

## Projection rule (first milestone)

Let `p_A`, `p_B` be global anchor positions and `C` the active perspective `Camera3D`.

```gdscript
if camera.is_position_behind(p_a) or camera.is_position_behind(p_b):
    return false
if not camera.is_position_in_frustum(p_a) or not camera.is_position_in_frustum(p_b):
    return false

var a_px: Vector2 = camera.unproject_position(p_a)
var b_px: Vector2 = camera.unproject_position(p_b)
var aligned := a_px.distance_to(b_px) <= 26.0
```

Use a tunable threshold near **26 px at a 1280 x 720 baseline**; optionally scale with viewport size. Camera rotation, not moving the platforms, should cause the alignment. Handle visibility/occlusion with a consistent raycast policy, and explain that policy in the PR.

If more than one pair is ever considered, require unique target selection and stable selection behavior. PR #1 only needs one explicit pair.

## Connection in world space

On `E`, create a `StaticBody3D` between the two anchors with a narrow visible `BoxMesh` plus matching `BoxShape3D`. Position and yaw it from the ground-plane vector `(p_b - p_a)`; the first puzzle uses equal-height anchors so the bridge deck stays level and traversable. Use bridge thickness, width and endpoint overlap sufficient for ordinary walking collision. Clear the previous bridge before installing a new one.

**Projection is only the activation condition.** Do not collapse world coordinates, teleport the character, mutate the physical level while traversing, or silently create an ill-posed sloping bridge.

## Level 01 — The Alibi

Two concrete blocks hover over an empty void. Neon anchor indicators sit near their facing edges. The gap is initially impassable. Rotating the camera aligns the indicators and enables one straight bridge; the player crosses to a visible exit zone. There should be a win state and a usable restart.

The graybox starter scene contains the islands and anchors only. The first contributor PR implements player/collision/interaction/finish.

## Possible later levels (not required in PR #1)

- **Wrong Witness:** visual distractor anchors; only one pair can lock.
- **Occluded Evidence:** line-of-sight deliberately blocks apparent alignment.
- **Vanishing Point:** angle and depth constrain alignability.
- **One Bridge Rule:** only one bridge can exist; a second crossing requires reconfiguration.

## Visual direction

Minimal surreal architecture, strong silhouettes, two distinct anchor colors, restrained UI. Prototype with built-in primitive meshes; defer sound, narrative, postprocessing and imported assets until after the main interaction feels good.

## Hackathon target

A small playable desktop/Web-exportable game, not a months-long generalized geometry engine. First stabilize desktop controls and physics, then validate an HTML5 export if the chosen Godot version and renderer support it.
