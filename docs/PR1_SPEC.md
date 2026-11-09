> **Historical brief:** This was the scope for the original one-level release-quality miniature. After playtesting, the next assignment is the larger [Chapter I: A Letter to Nowhere](CHAPTER_01_LETTER_TO_NOWHERE.md). It supersedes any narrow one-puzzle or interaction requirements below. Retain this for revision history, not as the current implementation ceiling.

# Perspective Crime — revised delivery brief

**This brief replaces the former “first playable perspective bridge” specification.** The original requirements for two fixed islands, 26-pixel anchor tolerance, Shift+E activation, one particular bridge body, and predetermined path are withdrawn.

## Target

Create an **original, near-release-quality single-level geometric puzzle game**, taking inspiration from the spatial elegance, optical trickery and polish of *Monument Valley*. The author is free to choose the actual level, architecture, rules, visual language and puzzle.

Make thoughtful use of geometric knowledge to construct the puzzle and spatial illusions. Choose mechanisms that can be communicated through player experience rather than requiring an explanation of the code. Strong visual design and the feeling of discovery are as important as mathematical validity.

One extraordinary level is preferred over five ordinary ones. It is acceptable—and encouraged—to spend serious effort polishing a single scene until it feels like a small finished game.

## Creative autonomy

You may replace the existing graybox and redesign the entire interaction. Do not treat the starter camera, bridges, keyboard controls, stage name, level narrative or mechanism as constraints. You do not need to ask for a story/level specification; choose and develop it yourself.

**Call the image-generation tools/models available in your own environment to produce original artwork.** Use them purposefully for textures, illustrations, decorative surfaces, background art, UI or visual exploration. Integrate the selected assets with 3D geometry and lighting into one coherent art direction.

## Delivery bar

The result should be complete enough to show publicly as a game rather than as a prototype:
- A cohesive playable experience from opening to conclusion, with clear onboarding and a memorable geometric puzzle.
- Art direction, scene composition, purposeful camera behavior, polish in motion/interaction and useful sound/visual feedback.
- Responsive controls, natural success/failure handling, reliable reset/replay, and sensible UX without placeholder/debug presentation.
- Clean-clone run instructions and a readily playable export/build when feasible, with the exact platforms genuinely tested.
- Real screenshots and a short gameplay video or equivalent visual evidence, plus concise PR notes.

These are *outcomes*, not requirements to implement specific screens or controls. You choose the technical solution and may add features or dependencies that demonstrably improve the finished game.

Keep work in the existing draft PR #1 (or a clearly linked replacement PR if major restructuring requires it). Do not mark as release-ready based solely on headless tests; actually inspect/play the rendered game. No self-merge.
