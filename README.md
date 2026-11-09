# Perspective Crime: A Letter to Nowhere

A playable Chapter I development build for Godot 4.6.3: an unaddressed letter,
three forward-moving districts, and a city whose streets can be rearranged.
The original **Folded Observatory** demo remains available at Git revision
`21fd43954a277ebbe157229f23f387424a636bd3` and `scenes/main.tscn`.

## Play

Open `project.godot` in Godot 4.6.3 and press F5, or run `godot --path .`.
The main scene is `scenes/chapter.tscn`.

- Click **Enter the city** after the opening comic.
- Drag the brass grips on teal streets to rotate actual architecture. Release
  to snap. Drag the brass grip inside a tall facade to slide it along its rail.
- Click a glowing landing to walk there along currently connected streets.
  Dark landings are disconnected. Dragging never counts as a click.
- In the final district, click the brass pin while standing on the central
  landing to hold one of the linked streets still.
- Top-left controls: restart district, help, sound, optional gentle hint.
  Keyboard: R restarts the current district; M toggles audio; Esc closes help
  and safely ends a captured gesture.
- District entrances save automatically. The next district never needs a
  completed district's apparatus. Replay after the closing comic starts over.

Runs offline; no runtime AI, telemetry, accounts, or third-party services.
Mouse and single-pointer touch events share a router. Touch hardware is untested.

## Chapter structure

1. **Folded streets:** three rigid rotating paper streets teach spatial
   reconfiguration and landing-by-landing movement.
2. **False facade:** hinged streets lead to a sliding architectural receiver.
   Actual orthographic projection, not a camera index, creates the impossible
   seam. The messenger crosses a continuous view-ray segment into another layer.
3. **Undeliverable tower:** two coupled streets cannot simultaneously connect
   until the messenger pins one at the central landing. Their geometry controls
   the visible barrier; the local projection seam completes the delivery.

Two original four-panel comics frame the journey. See `assets/CREDITS.md` for
asset provenance. The research references are design inspirations, **not** claims
of implementing the cited papers' general solvers.

## Architecture

- `input_router.gd`: pointer capture, click/drag threshold, touch mapping.
- `spatial_mechanism.gd`: rigid street rotation, facade slide, locks and occupancy.
- `walkable_graph.gd`: dynamic undirected graph and shortest valid routes.
- `projection_seam.gd`: live Camera3D visibility and screen alignment validation.
- `chapter_module.gd`: self-contained district geometry and connectivity.
- `narrative_panels.gd`: opening/closing comics.
- `chapter_hud.gd`: reachable destination and grip feedback, optional help.
- `game_flow.gd`: constrained walking, forward transitions, saves and replay.

Movement follows authored world-space routes with tweened positions. This is a
constrained puzzle, not a free-physics platformer. The impossible seam deliberately
changes depth along the camera ray. Decorative architecture does not occlude the
screen-space interaction indicators. Geometry cannot change during walking, and
an occupied receiving facade cannot be dragged away.

## Verification and limits

Godot 4.6.3 headless regression: **77 checks pass**. The test loads the actual
chapter scene, solves every district, checks live camera projection, validates
mandatory brace use, rejects disconnected destinations, and tests cancellation,
reset during walking, ending and replay.

```sh
godot --headless --path . --script tests/chapter_playthrough.gd -- --no-save
```

Use `--no-save` for isolated tests; it prevents reading or writing player progress.
A writable HOME/XDG data/config/cache directory is required by Godot itself.

This is a **development chapter**, not a claim of release readiness or a measured
12–20 minute experience. No blind-player study or accessibility audit is claimed.
Windows runtime verification, touch hardware, and hardware-GPU performance are
not yet established. Graphical evidence and packaging results are recorded in
`docs/CHAPTER_01_TESTING.md` as they are actually verified.

## Build

```sh
python3 tools/build.py --install-templates
```

Produces `ALetterToNowhere-linux-x86_64.zip` and
`ALetterToNowhere-windows-x86_64.zip` outside the repository. Official Godot 4.6.3
export templates are checksum-verified. Build manifests distinguish committed
source from an uncommitted working tree. See `docs/BUILD.md` for details.

Continue through Draft PR #1; no self-merge.
