# EchoFragment — Portador del Eco, Modular V1 / Sprint 01

**Estado: prototipo de geometría modular, sin aprobación artística.**  
Rama de trabajo: `feature/portador-modular-v1-clean` (creada desde `main`).

## Entregables reales
Se crearon desde cero como **dibujos vectoriales separados**, no como recortes de un personaje completo, estos cuatro componentes:

| Imagen independiente | Archivo vectorial original | Anclaje |
|---|---|---|
| Casco / cabeza cerrada | `svg_source/portador_head_helmet.svg` | Cuello |
| Protección de cuello | `svg_source/portador_neck_guard.svg` | Torso |
| Coraza / torso | `svg_source/portador_torso_upper.svg` | Cintura |
| Pelvis / faldones | `svg_source/portador_pelvis_waist.svg` | Cadera |

Los PNG correspondientes están en `assets/player/portador_modular_v1/png/`. Son **PNG RGBA individuales de alta resolución** con margen transparente real. Su tamaño y pivote medido en píxeles está en `assets/player/portador_modular_v1/manifest.json`; no se corrigieron escalas a ojo.

## Previsualización y QA
- `docs/animation/portador_modular_v1_core_neutral.png`: montaje real de los cuatro PNG transparentes.
- `docs/animation/portador_modular_v1_core_review.jpg`: control de pivotes sobre el mismo montaje.
- `docs/animation/portador_modular_v1_core_closeup.jpg`: vista cercana para inspección desde el teléfono.
- `scenes/experiments/PortadorModularCoreV1Preview.tscn`: escena Godot 4.3 estática con `Skeleton2D` y cuatro `Bone2D`.
- `tests/modular_core_v1_test.gd`: CI verifica los cuatro archivos originales, ausencia de `region_rect`, alta resolución, pivotes y carga de escena.

## Qué **no** está aprobado
- **Acabado artístico:** los trazos vectoriales actuales están demasiado geométricos respecto a la ilustración detallada aprobada. Son un **blockout coherente** para validar proporciones/pivotes, no sustituyen el diseño final.
- **Anatomía completa:** todavía faltan brazos, antebrazos, manos, muslos, piernas bajas y pies; no presentar esta prueba como personaje listo.
- **Capa y espada:** deben diseñarse como piezas enteramente independientes de torso y manos.
- **Movimientos:** no hay animaciones nuevas, porque el documento maestro impide avanzar si la pose neutral no cumple estándares visuales.
- **APK:** no se genera. La escena experimental no se integra al personaje jugable.

## Siguiente puerta de aprobación
Repintar las superficies de las **mismas piezas** con acabados de metal grafito desgastado, detalles finos, tela carmesí y bordes de fantasía oscura, manteniendo exactos sus límites anatómicos y puntos de anclaje. Volver a revisar el montaje. Solo después de aprobar el núcleo completo se amplía a los brazos y piernas.

**Importante:** `main` y el rig viejo `feature/portador-rig2d-prototype` no se modifican.
