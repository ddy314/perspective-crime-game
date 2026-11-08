# Perspective Crime

A small 3D perspective-puzzle game built with **Godot 4**. Two objects that appear to coincide on screen can become physically connected in the game world.

## Game idea

Orbit the camera until two distant anchor points line up in screen space. Enter focus mode and lock the alignment to materialize a walkable bridge in real 3D space. Cross the gap to reach the exit.

**Design principle:** screen-space alignment is the *condition* for creating a bridge; the bridge itself must have an ordinary world-space mesh and collision shape. No teleportation or simulated video-only connection.

## Repository status

This repository begins with a runnable graybox scene, two platforms, anchor markers, an orbit camera, and a short design/PR specification. **The perspective-link mechanic and player movement are not implemented yet**; they are the goals of the first contributor PR.

## Run locally

1. Install Godot 4.3 or newer (Godot 4.x).
2. Open/import `project.godot` in the Godot editor.
3. Run the project with **F5**.

On Linux with Godot in PATH, `godot --path .` starts the current main scene. No remote service or paid asset is required.

### Current graybox controls

- **Right mouse drag:** orbit the camera.
- **Mouse wheel:** zoom.
- Perspective focus, bridge placement, walking and level completion: planned for PR #1.

## First playable milestone

See [the first PR brief](docs/PR1_SPEC.md), [game design](docs/GAME_DESIGN.md), and [contributor instructions](AGENTS.md).

A successful first PR should make one gap-crossing puzzle playable end to end with visible alignment feedback, physical bridge collision, a controllable character, and a reset path. Keep it small enough to review in one PR.

## Project conventions

- Godot 4 / GDScript; desktop-first, Windows and Linux supported.
- Original primitive geometry and self-created or properly licensed assets.
- No LLM agents, APIs, accounts, backend, or telemetry.
- One simple playable mechanic is more valuable than a large unfinished feature list.

Status: **public game prototype / active development**.
