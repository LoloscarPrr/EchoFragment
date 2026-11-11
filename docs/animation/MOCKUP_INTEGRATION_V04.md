# EchoFragment — First mockup integration pass

The approved references are “Portador del Eco en ruinas góticas” and “Tablero maestro de EchoFragment”.

## Implemented
- A clean environment plate derived from the approved reference: gothic ruins, crimson moon, distant castle, amber torchlight and stone bridge. No painted actors or interface.
- The plate is rendered by RuinasDelEcoBackdrop behind real gameplay actors, with nearest texture filtering. Its walkway is aligned with the floor collider at y=640.
- Three alternating mirrored tiles cover the current level; this is a first environment pass, not independently scrolling parallax layers.
- Existing live health/stamina/XP/boss bars use a dark, crimson/blue gothic skin.
- Existing action buttons use circular backgrounds and a spaced action cluster. Labels remain until finished icons are authored; no nonfunctional guard/minimap buttons were added.
- The earlier rig-rest, pixel filtering and jump-pose fixes are retained.

## Validation
Godot 4.3 import, rig texture/hierarchy tests, player bridge, attack timing and mockup integration test. Runtime capture: ruinas_mockup_runtime_v04.png.

## Remaining visual work
The existing 22-part protagonist still differs from the approved knight. The background does not resolve that mismatch. Next passes: protagonist proportions/art, layered parallax, finished action icons and enemy art. No claim of completed final art or Android device performance.
