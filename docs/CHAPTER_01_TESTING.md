# Chapter I testing record

## Automated, verified

- Godot 4.6.3.stable.official.7d41c59c4, Linux cloud workspace.
- `tests/chapter_playthrough.gd`: 77 checks, zero failures.
- Every district begins independently, solves via actual transform-derived graph,
  rejects disconnected traversal, and advances without prior district state.
- Click/drag discrimination, Escape cancellation, geometry lock while traversing,
  occupied facade protection, interrupted reset, opening/ending and replay.
- Projection checks use the live orthographic Camera3D. The seam endpoints are
  separated by 5 world units and coincide within 0.01 screen pixels when aligned.
- Final coupled-street bypass is rejected unless the first street is held at its
  valid angle while the second moves. The brass brace enables that configuration.

## Graphical, verified

- Actual Linux cloud desktop, Godot 4.6.3 Compatibility renderer, Mesa llvmpipe.
- All three districts manually completed using pointer drags and landing clicks.
- Geometry manipulation during walking is rejected; after arrival it resumes.
- District transitions, final comic, replay, reset after manipulation, help,
  Escape dismissal, and optional hint panel exercised.
- A real GUI hit-test bug was found: the final district's brass pin intercepted
  the central landing. Fixed so the pin consumes clicks only when the messenger
  is already at that landing. The exact central landing click was graphically
  retested and now walks normally; automated regression covers it too.
- Original generated comics and paper-cloud backdrop visually inspected in game.
  Lighting and framing refined after screenshots; final ivory shading is cream
  rather than clipped white.
- ALSA is unavailable on this test desktop. Audible output is not verified; the
  engine uses its dummy audio driver. This is not a hardware GPU benchmark.

## Not claimed

Windows runtime testing, touch-device testing, blind-player observations and
measured first-time duration remain unverified. The PR stays draft.

## Known design limits

Three small connected districts form the full implemented beginning-to-ending
flow. This version has not demonstrated the brief's aspirational 12–20 minute
first-time duration or near-release finish. The rotating streets are rigid hinges,
not a general kirigami solver. The slide is a projection-based facade, not a real
mirror-reflection simulation. No arbitrary mesh topology is reconstructed.

## Captured walkthrough and exports

- `tests/chapter_capture.gd` drives the ordinary pointer router with staged drags
  and destination clicks; it does not assign solved transforms or actor positions.
  This is a reproducible rendered demonstration, not a blind human playtest.
- Recorded opening through ending: 1,314 frames, **43.8 seconds, 1280×800,
  30 fps**. AVI converted to H.264/AAC MP4 without altering gameplay frames.
  Screenshots in `docs/screenshots/chapter/` are genuine viewport captures,
  JPEG-compressed only.
- Linux and Windows x86_64 exports produced with SHA-512-verified official Godot
  4.6.3 templates. Both ZIP CRCs and every packaged-file manifest hash passed.
- Extracted Linux export headless startup exits 0. An abrupt `--quit-after`
  startup probe reports Godot's audio playback resource-in-use shutdown warning;
  the full regression suite stops audio and waits before quitting and has no
  warning. This diagnostic is not concealed as an error-free smoke test.
- Windows package is unsigned and has **not** been run on Windows.
- Extracted **standalone Linux release** also graphically smoke-tested: opening
  comic, Enter, final artwork, first hinge drag, and click-to-walk arrival at B
  verified. This is distinct from the full three-district editor-project test.
