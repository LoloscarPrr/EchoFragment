# EchoFragment — Portador del Eco articulado (prototipo 0.1)

## Objetivo
Probar animación **2D por huesos** para el protagonista aprobado con **casco**, armadura negra y capa carmesí, sin multiplicar dibujos completos ni recortar un ataque en dieciséis cuadros.

**Estado:** experimento aislado en `feature/portador-rig2d-prototype`; no modifica `main`, `Main.tscn`, `Player.gd`, el daño, los controles táctiles ni las hitboxes.

## Qué contiene
- `scripts/player/PortadorRig2DPrototype.gd`: jerarquía Godot `Skeleton2D/Bone2D` con partes independientes. Esqueleto compuesto por cadera, torso, cuello/casco, dos brazos articulados, dos piernas articuladas, capa con punta articulada y espada.
- `scenes/experiments/Rig2DPreview.tscn` y `scripts/player/Rig2DPreview.gd`: visor independiente, alterna reposo, movimiento, ataque y esquiva.
- `tests/rig2d_prototype_test.gd`: prueba de carga, articulaciones y espejo horizontal.

**Importante:** el dibujo de esta prueba utiliza polígonos **provisionales**. Es un prototipo mecánico para validar pivotes y movilidad. **No es el personaje artístico final** ni simula que una sola imagen recortada en partes esconda las superficies que faltan detrás de las articulaciones.

## Abrir en Godot 4.3
1. Abrir el repositorio de esta rama.
2. Ejecutar `res://scenes/experiments/Rig2DPreview.tscn` (F6).
3. Observar reposo, movimiento, ataque y esquiva. Es un bucle a cámara lenta para evaluar articulaciones.
4. Ejecutar la prueba headless: `godot --headless --path . --script res://tests/rig2d_prototype_test.gd`.

## Futura sustitución por arte aprobado
El arte original está concebido como un personaje íntegro y no como un conjunto de piezas. **No basta con separar por recortes**: hay que pintar el material oculto debajo de hombros, codos, cuello, rodillas y la unión de la capa; generar piezas limpias en PNG RGBA sin sombras de escenario.

Piezas sugeridas (con pivote identificado en metadatos):
- casco/cabeza, cuello, torso/coraza, pelvis/faldones;
- hombro y antebrazo izquierdo, hombro y antebrazo derecho, guantes;
- muslo y espinillera izquierda, muslo y espinillera derecha, botas;
- capa trasera, tira de capa secundaria, punta flexible;
- espada, guarda, efecto de energía en capa independiente.

Para cada imagen exportada: **transparencia real, margen de seguridad mínimo 12 %, pivote documentado y área de movimiento medida en Godot**. No se deben introducir números `256×256` sin comprobar la silueta final: el lienzo depende del tamaño real de cada pieza y del rango de movimiento.

## Integración en el combate actual
`Player.gd` ya utiliza `CharacterAnimationController` y la línea de tiempo `TajoDelEcoTimeline` (18 ticks). Una vez validado y vestido el rig:
- conectar `set_pose(state, progress, facing)` al estado de animación, o bien añadir un adaptador que traduzca los estados actuales;
- no modificar `_process_animation_combat`, `_attack_sword`, `CombatHitbox`, el joystick ni la física;
- mantener la opción anterior `CanonicalProtagonistVisual` como fallback;
- separar el destello carmesí del PNG del cuerpo para animarlo y escalarlo de forma independiente.

El prototipo **no se integra aún en Main** para evitar regressiones en APK/Android. Tras aprobar el movimiento se implementará detrás de un selector de render de prueba.

## Control de calidad antes de llamar a un recurso «final»
1. Verificar casco, capa, pies y hoja completos en cualquier pose extrema.
2. Evitar huecos visibles en articulaciones cuando rotan.
3. Probar orientación derecha e izquierda.
4. Mantener una línea de suelo común sin alterar colisiones.
5. Evitar cambios de aspecto o escala entre armas.
6. Probar multitáctil y APK de Android, sin desinstalar versiones previas.
