# Perspective Crime

**The Alibi:** a complete single-level, offline Godot 4 perspective puzzle.
Line up two glowing anchor tips, commit a real bridge, then walk across to the
mint-green exit. Everything is built from original procedural primitives.
No account, network, paid asset, plugin, or service is needed.

## Play

1. Install Godot **4.3 or newer** for Linux or Windows.
2. Clone this repository and import `project.godot`. Press **F5**.
   Alternatively, run `godot --path .` from the repository directory.
3. Hold **Shift**. Lower the camera with **Down**, then orbit with **Left/Right**
   until the cyan and amber tips overlap. The HUD reports the actual projected
   pixel gap and turns green when ready. Focus slows camera input for precision.
4. Keep holding Shift and press **E** to create the bridge.
5. Raise the camera with **Up**, then use **WASD** (camera-relative) to cross
   the bridge and enter the green exit. A visible LEVEL COMPLETE message appears.
6. **R** restarts the entire puzzle, including the camera. Walking off a ledge
   respawns the character on the start island without removing a committed bridge.

Other controls: **right mouse drag** orbits, **wheel** zooms, **Esc** releases
mouse capture. Losing application focus also releases capture. No jumping is
needed. Repeated E cannot duplicate a bridge; the bridge persists when the camera
moves and after completion. There is no teleport across the gap.

Solution hint: view almost horizontally along the line between the islands.
Either end of the line works. Hold Down to reach the camera's lower limit, then
rotate until the lights overlap. After building, use a higher, oblique view to walk.

## Projection and collision

`Camera3D.unproject_position()` measures anchor separation, with a **26 px**
tolerance at 720 px viewport height, scaled by the current viewport height.
Behind-camera and out-of-frustum/offscreen points are rejected. A ray from the
camera to each tip must miss all solid geometry, except the player. Glowing tips
and decorative pylons have no colliders, so one does not reject the other when
aligned. Thus opaque physical obstacles reject alignment, while decorative
anchor tips are deliberately allowed to overlap.

The two decks are level at y=0. Elevated marker tips share y=1.4. Their x/z
positions define the bridge endpoints; a 0.3-thick, 1.35-wide box extends 0.3 past
each endpoint into the islands. Its position, length, and yaw come from those
world-space endpoints. A StaticBody3D contains the matching BoxMesh and a direct
CollisionShape3D child. The CharacterBody3D crosses using `move_and_slide()` and
gravity. Only a fall or explicit restart resets the character position.

## Verification

Tested **Godot 4.6.3 stable (7d41c59c4), Debian GNU/Linux 13, headless**:

```
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/playthrough.gd
```

The physics integration test runs at a 1280x720 viewport and checks invalid E,
no hidden floor, fall recovery, real camera projection, solid obstruction,
behind-camera/offscreen rejection, duplicate prevention, actual grounded walking
across the bridge after changing the camera, visible win-state activation,
persistence, and two build/cross/reset cycles. Test movement uses the same player
physics code, with a deterministic direction input; it never teleports across.

**Not yet verified:** interactive desktop input/rendering, Windows execution,
and standalone exports. This environment has no working graphical display, so
there is no screenshot/recording claimed as visual proof. Linux headless tests
are not a substitute for a desktop playtest. The project uses only standard
Godot 4 APIs and is intended to run offline on both desktop platforms.

See [PR1_SPEC](docs/PR1_SPEC.md) for the original acceptance checklist.
