# AGENTS.md

## Creative direction (supersedes the original graybox task)

**Perspective Crime is a finished-feeling, original geometric illusion puzzle game, not a technical proof of concept.** Take *Monument Valley* as a reference for the ambition, elegance and playful impossible-space design—not as a source to copy levels, art, characters or assets.

The author owns the design. Invent the level concept, spatial geometry, transformations, perspective tricks, puzzle logic, pacing, camera, art direction and player experience. The previous two-island/anchor/bridge graybox is **optional scaffolding**, not a requirement. You may rebuild or discard it. No prescribed level narrative, layout, trigger keys, projection tolerance, bridge shape or camera scheme remains binding.

## What matters

- Make **one exceptionally polished, coherent, memorable playable level**. Spend substantial effort on its composition, mechanics, art, transitions and feel rather than producing many rough levels.
- Use real geometry, projection, topology, occlusion, moving architecture and/or other spatial mathematics as you see fit. The result should offer a genuine, understandable spatial surprise and a satisfying solution.
- **Actively use an available image-generation model to create original art assets** where useful: concept art, textures, environments, decorative illustrations or UI artwork. Curate and integrate them into the game; generated images alone are not a game. Combine them with procedural/vector/3D art as appropriate.
- Aim for near-release quality: consistent visual identity, intentional framing and lighting, refined controls and feedback, graceful onboarding, polished animation/transitions, suitable audio if useful, complete beginning-to-ending flow, restart/replay, and no placeholder/debug UI in the final experience. Decide how to realize these; they are quality expectations, not a fixed feature checklist.
- Favor an actual playable build, documentation sufficient to run it, and convincing screenshots or a gameplay video. Automated tests help but **do not substitute for visual inspection and human playtesting**.

## Engineering

Godot 4 is the existing engine; you can reorganize the project and write the architecture that best supports the experience. Keep it reproducible from a clean clone and practical to run on Linux and Windows. Produce a suitable playable export or packaged build when ready. State the engine version, tested environment, and any remaining platform limits accurately.

This is **not an LLM Agent product**. Image generation is a development tool for making visual assets, not a mandatory gameplay feature. Use assets you can legally distribute and record credits/licenses where relevant.

## Collaboration

Continue work through a PR to `main`. The existing draft PR #1 can be developed into the release-quality version; a substantial redesign is welcome. Do not stop at a working headless physics demo. Include a concise description, run instructions, visual evidence, and tested results; do not merge your own PR.

**The creative design and level content are your decision.** The benchmark is whether a stranger could open the game, understand it, enjoy it, and feel that it is a crafted finished work.
