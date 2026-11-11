# Portador visual correction v0.4

The prior 22-piece drawing mixed source perspectives and scales. Its assembly did not match the approved knight.

The active sword visual now uses twelve complete transparent pixel poses matching the approved black/gold knight with crimson cape, closed helmet and red sword. This replaces the drawing layer only. It is a pose atlas, not an articulated skeleton. The old experimental rig remains in the repository as a separate experiment.

Poses: idle; four running poses; rise, apex and fall; attack startup, active and recovery; low dodge. All poses use the same source scale. Per-pose pivots preserve the planted foot line and facing reflection. The active attack drawing is selected on ticks 5–7, matching TajoDelEcoTimeline. Physics, input and hitbox code are retained.

Remaining animation limits: only four running drawings and three attack drawings; idle is static; landing and hit reactions reuse existing drawings. No claim of final arcade animation quality.

Validated using Godot 4.3: atlas alpha and regions, pose selection, mirroring, run cycle, attack phase timing, Main player bridge and mockup integration. Actual game captures were inspected for idle/run/attack/dodge.

Art direction prompt: twelve consistent whole-body poses of the approved side-facing Portador, black armor with gold edging, crimson cape, red sword, visible pixel clusters, transparent background, four columns by three rows. Created using built-in image generation; no retouching of the old body cutouts. Source atlas is stored losslessly as assets/player/portador_pixel_v04/poses.webp.
