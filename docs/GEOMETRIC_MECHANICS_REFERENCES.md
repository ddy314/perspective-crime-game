# Geometry research notes — possible mechanics for Perspective Crime

These are peer-reviewed research inspirations, not proofs that a particular Godot implementation will work. The game should adapt manageable mathematical ideas, not attempt to port research-grade solvers wholesale.

## 1. Reconfigurable Hinged Kirigami Tessellations — SIGGRAPH Asia 2025

Aviv Segall, Jing Ren, Marcel Padilla, Olga Sorkine-Hornung. Project: https://segaviv.github.io/kirigami_tessellations/

The work studies rigid polygonal faces connected by hinges, deployable tilings and inverse-design transformations. Under the paper's assumptions, uniform deployability is characterized by deployment-friendly vertices; the page describes balance of incident cut-edge vectors and a single opening angle for a family of configurations.

**Game translation:** a controllable fold slider driven by drag rotates a chain of architectural slabs about physical pivots. The connectivity graph of walkable edges updates when a pair of tile boundaries meet. A paper street unfolds into an unexpected bridge, courtyard or spiral staircase. Curate authored positions and collision-safe motion instead of running unconstrained inverse design.

## 2. Meschers: Geometry Processing of Impossible Objects — SIGGRAPH 2025

Ana Dodik et al., ACM Transactions on Graphics 2025. DOI: https://doi.org/10.1145/3731422
Project: https://scenerepresentations.org/publications/meschers/

Represents impossible objects with a mathematical model rooted in discrete exterior calculus, as an alternative to cutting/twisting conventional 3D meshes.

**Game translation:** separate each locally walkable path from the **global adjacency** between its endpoints. The player can create a view-valid seam to connect local sheets even though no globally ordinary Euclidean embedding exists. Use a small, explicitly modeled directed transition graph, stable rendered contact points and screen-continuous traversal. Do not claim to have implemented the paper's mescher representation unless actually done.

## 3. Anomalous Mirror Reflections Created by Symmetries — 2025

Kokichi Sugihara, Journal of Information Processing 33, 974–980 (2025). DOI: https://doi.org/10.2197/ipsjjip.33.974
Landing page: https://www.jstage.jst.go.jp/article/ipsjjip/33/0/33_974/_article/-char/en

Studies the geometry of objects with unexpectedly different silhouettes in a mirror or alternative viewpoint, including reversal and translation illusions.

**Game translation:** rotate a seemingly ordinary block or mirrored facade until it displays a different silhouette that becomes a door, staircase, aperture or signal. The clue is visible in shape, not in stage text. The silhouette mechanism should actually depend on rendered geometry and camera transforms.

## 4. Rigidity Control of General Origami Structures — 2026

Rongxuan Li and Gary P. T. Choi, Communications Physics 9, 217 (2026). DOI: https://doi.org/10.1038/s42005-026-02640-5

Studies how enforcing or relaxing face-planarity constraints affects the degrees of freedom in general origami structures, with rigidity-related behavior governed by geometry and topology.

**Game translation:** an interactive pin or brace toggles which paper-building faces can move. One geometric assembly can have multiple permissible deformation patterns depending on where it is constrained. Communicate this via handles, color and motion, not technical text.

## Design cautions

- **Do not merely add four unrelated mechanics.** Give each one a story role and build one concluding puzzle that composes two of them.
- **Do not turn mathematical correctness into player burden.** For authored scenes use prevalidated parametric transforms, snapping, an explicit graph and a few projection checks.
- **Real agency requires input and feedback.** A tap-to-automatically-complete-stage button does not become an intricate puzzle because the screen has a theorem-inspired shape.
- **Preserve creative autonomy.** The chapter motif and player-control goals are fixed by direction; exact characters, visual metaphors and puzzle solutions may change to improve the game.