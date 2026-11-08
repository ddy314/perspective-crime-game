# The Folded Observatory

*A Perspective Crime miniature. Some distances exist only until you change your view.*

A complete, original, offline geometric-illusion puzzle in Godot 4. Turn a floating observatory, join the silhouettes of disconnected paths, and guide its tiny astronomer through three celestial shrines. A quiet beginning, animated journey, and replayable ending form one short, coherent level.

## Play

Use a packaged Linux or Windows build, or install **Godot 4.6.3** and open `project.godot`, then press **F5**. From a clean clone:

```sh
godot --headless --path . --editor --import --quit
godot --path .
```

No account, network connection, paid dependency, or AI service is used during play. The project uses Compatibility/OpenGL rendering. Build packages include the engine and do not require a Godot installation. See [build instructions](docs/BUILD.md).

- Click **Begin the journey**, or press **Space / Enter**.
- **Q / E**, **Left / Right**, **A / D**, the on-screen arrows, or a horizontal drag turn the observatory between four views.
- Watch the **two gold endpoint rings**. When they overlap, click the glowing destination or **Walk the fold**, or press **Space / Enter**.
- **H / Need a nudge?** offers a contextual hint. **R / Restart** resets the journey, including an interrupted walk or turn.
- **M / Sound** mutes or unmutes. **?** opens instructions; **Esc** closes them.
- **Walk again** or **Space / Enter** after the ending starts a fresh journey.

This is a contemplative miniature, not a free-roaming platformer. The astronomer walks constrained architectural routes; there is no WASD free movement, jumping, combat, failure penalty, or random puzzle generation. Each shrine asks you to discover one view of the same sculpture. A first visit takes a few minutes; a known solution is much shorter.

<details><summary>Solution</summary>

From a fresh journey, turn right to Noon and walk. Turn right to Dusk and walk. Turn right twice to Dawn and walk. Wait for each turn and traversal to finish. The hint button explains the next step without resetting progress.

</details>

## The spatial idea

The paths are genuinely disconnected in 3D. Each pair of endpoints differs by a vector parallel to one orthographic viewing ray. At that view, their projections coincide even though they are separated in height and depth. `Camera3D.unproject_position()` measures the current screen-space gap; the game does **not** unlock traversal by looking up the selected view number. Offscreen, out-of-frustum, and behind-camera endpoints are rejected.

The small gold circles are intentionally drawn above the architecture so that the puzzle remains legible when a tower obscures an endpoint. Occlusion is a presentation choice, not a raycast test. Once aligned, the camera is locked during traversal. The character moves continuously along the real paths and then along the projection-null depth segment: its world position changes while its screen position stays fixed. This is an intentional impossible-space topology transition, **not** a constructed physical bridge or rigid-body platforming simulation. Changing the view reveals the impossible connection.

The revised project brief explicitly replaces the old two-island physics-bridge prototype. The previous bridge controls and claims no longer apply.

## Art and sound

The celestial painted backdrop was made with the available image-generation model specifically for this game, then curated and integrated behind original 3D architecture. All architecture, ornaments, character, lighting, UI, and animation are procedural. A quiet original synthesized pad, turning tone, footfalls, alignment chimes, and ending cadence accompany the journey. DejaVu Serif is redistributed with its license. See [asset provenance and generation prompt](assets/CREDITS.md).

## Verification

Engine: **Godot 4.6.3 stable, 7d41c59c4**. Automated checks:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/playthrough.gd
```

The test suite covers actual projected gaps, invalid views, offscreen/behind-camera rejection, continuous projection-null traversal, repeated activation protection, input dispatch, help modal, muted/reset states, interrupted animation reset, all three shrines, ending, and a second playthrough. See [playtest and delivery notes](docs/VERIFICATION.md) for the final measured results, graphical evidence, and platform limitations.

## Capturing the actual game

```sh
godot --path . -- --demo --capture-dir=/absolute/path/captures --quit-after-demo
```

The deterministic demo uses the same rotation and journey methods as play, rather than forcing the completion state. `F12` saves a real viewport screenshot when `--capture-dir` is set. Godot's `--write-movie /absolute/path/demo.avi --fixed-fps 30` can record the rendered demo and game audio; it is not a substitute for manually testing the controls.

No self-merge, deployment, telemetry, or runtime model integration is included.
