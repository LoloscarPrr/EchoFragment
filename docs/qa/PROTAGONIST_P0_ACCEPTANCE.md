# EchoFragment — Checklist de aprobación P0 del Portador del Eco

**Revisión inicial:** 2026-10-12 · **hito objetivo:** 0.30 · **alcance:** protagonista jugable P0, NO todo Valle Gris.
**Estado de aprobación:** ⛔ NO APROBADO — falta arte jugable real y su validación en Android.
**Fuente funcional estable:** v0.21 en `main`. **Rama de trabajo:** `feature/valle-gris-visual-030`.

## Cómo se usa
- `[x]`: comprobación documentada y con evidencia. `[ ]`: pendiente / sin evidencia. No marcar aprobada una función solo porque existe código.
- Tres pruebas obligatorias: **A** assets revisados, **C** Godot/CI y **M** gameplay en móvil.
- Un fallo de clase **BLOQUEANTE** prohíbe declarar el P0 aprobado. La última aprobación requiere revisión de dirección de arte y prueba en un móvil Android real.
- El documento registra la situación inicial; volver a evaluarlo tras integrar cada lote, adjuntando commit, capturas o video y run de CI.

## A — Arte canónico y producción (BLOQUEANTE)
- [ ] **A01** Hoja madre de frente, lateral derecha e izquierda (o reglas explícitas de espejo), 3/4, escala de juego y paleta revisada. Evidencia: lámina aprobada y archivos originales.
- [ ] **A02** Silueta legible al tamaño final en pantalla Android, sobre fondo oscuro y claro, sin confundir arma y extremidades. Evidencia: capturas 100% sin ampliación.
- [ ] **A03** Elementos invariantes presentes: cabello negro, armadura oscura, dos faldones granate, espada recta derecha, marca Eco brazo izquierdo y broche circular roto. Evidencia: comparación con hoja maestra.
- [ ] **A04** Sprites PNG RGBA realmente creados (sin fondo, con pivote consistente, tamaño de canvas documentado, espada sin clipping). Evidencia: archivos en `assets/characters/portador_eco/`.
- [ ] **A05** Recurso `SpriteFrames` válido en `assets/characters/portador_eco/portador_eco_frames.tres`, con secuencias reales (no una misma pose repetida). Evidencia: recursos cargan correctamente.

## B — Cobertura de animaciones P0 (BLOQUEANTE)
Para cada estado, exigir movimiento o pose diferenciada, frames ordenados, pivote constante y continuidad de transición. Referencia: `docs/animation/P0_PILOT_MANIFEST.json` (duraciones y dibujos planificados, NO arte terminado).

| ID | Estado | Dibujos piloto previstos | Resultado visual | Estado |
|---|---|---:|---|---|
| B01 | `idle_ready` | 10 | Bucle vivo, sin salto al reiniciar | [ ] |
| B02 | `run_forward` | 10 | Piernas/torso fluidos y suelo sin patinaje perceptible | [ ] |
| B03 | `jump_start` | 3 | Compresión corta sin retrasar físicamente el despegue | [ ] |
| B04 | `jump_rise` | 4 | Postura de ascenso, tela responde a gravedad | [ ] |
| B05 | `jump_apex` | 2 | Punto alto legible, sin congelar física | [ ] |
| B06 | `jump_fall` | 3 | Postura distinta a subida, prepara recepción | [ ] |
| B07 | `land_light` | 3 | Recepción con peso y transición inmediata permitida | [ ] |
| B08 | `attack_light` | 6 | Anticipación, impacto y recuperación; espada sigue hitbox | [ ] |
| B09 | `hit_light` | 4 | Retroceso perceptible sin distorsionar posición del personaje | [ ] |
| B10 | `dodge` | **por fijar** | Silueta distinguible de carrera; coincide con ventana real de esquiva | [ ] |

**Deuda identificada:** el manifiesto piloto actual solo incluye 9 estados: `dodge` no está definido en el manifiesto, `P0FrameLibrary.gd` ni `CharacterAnimationController.gd` como animación independiente. Hay que cerrar B10 antes de declarar P0 completo. Los 9 estados actuales suman 45 dibujos *planeados*, no PNG reales.

## C — Integración técnica y regresión (BLOQUEANTE)
- [x] **C01** El puente opcional `ProtagonistArtBridge.gd` existe y conserva fallback si falta `SpriteFrames`. Evidencia: commit `48e2cf59`; inspección del código.
- [x] **C02** Godot Check del código base del puente pasó. Evidencia: [CI de la rama](https://github.com/LoloscarPrr/EchoFragment/actions/runs/38165211050). **No prueba frames ausentes.**
- [ ] **C03** Recurso SpriteFrames definitivo importa sin errores ni warnings en Godot.
- [ ] **C04** Todas las animaciones P0 se reproducen sin nombres faltantes, offsets inconsistentes, cambio de escala, clipping o pose incorrecta al mirar hacia la izquierda.
- [ ] **C05** La visual no altera `CharacterBody2D`, `CollisionShape2D`, hitboxes, daños, velocidad, gravedad, aguante ni ventanas de invulnerabilidad.
- [ ] **C06** Golpes visuales sincronizados con el frame activo y el impacto real. Sin golpes dobles al repetir frames.
- [ ] **C07** Cambio de estados correcto: quieto → correr → saltar → caer → aterrizar; correr → atacar; daño → recuperación; dirección derecha ↔ izquierda.
- [ ] **C08** Android exporta una APK instalable sobre v0.21: package `com.echofragment.playtest` inalterado, firma compatible y `versionCode` incrementado.
- [ ] **C09** Godot Check y Android Playtest APK final pasan para *exactamente el mismo commit* que se entrega. Adjuntar enlaces a runs.

## D — Prueba real en teléfono (BLOQUEANTE)
- [x] **D01** Versión base 0.21: usuario confirmó que el joystick funciona. Evidencia: prueba reportada, NO equivale a aprobación de P0.
- [ ] **D02** Joystick + salto hacia delante y detrás; mantener eje horizontal durante toda la trayectoria.
- [ ] **D03** Joystick + ataque y joystick + esquiva, simultáneamente, sin toques perdidos.
- [ ] **D04** Abrir evento del viajero herido, seleccionar respuesta, mostrar resultado y continuar; botones táctiles disponibles.
- [ ] **D05** Inventario, habilidades, equipar, recibir daño, eliminar enemigo y combate contra Caballero Fragmentado sin regresión.
- [ ] **D06** Probar al menos 3 minutos de juego, cambio de orientación/dirección de movimiento y regreso a partida; sin crash, bloqueo de pantalla ni congelamientos notorios.
- [ ] **D07** Rendimiento documentado en teléfono (FPS aproximados y tirones observables), sin sostener un resultado inventado; referencia ideal 60 FPS, evaluar si requiere optimización.
- [ ] **D08** Captura de juego y video corto del protagonista ejecutando idle/run/jump/attack/dodge en tamaño real.

## E — Aprobación artística y entrega (BLOQUEANTE)
- [ ] **E01** Comparativa 0.21 versus nuevo P0 confirma mejora visible del protagonista; ya no se ve como placeholder.
- [ ] **E02** Se conserva el lenguaje de identidad del Eco (negro, granate, rojo), no copia gráfica de franquicias externas.
- [ ] **E03** Se entrega APK Android directa (no ZIP) tras verificar archivo real, versión y CI.
- [ ] **E04** Dirección de arte aprueba silueta y movimiento; usuario confirma experiencia en móvil.
- [ ] **E05** Registro de commit, evidencias, limitaciones y fallos restantes, y decisión final: APROBADO / REQUIERE CORRECCIÓN.

## Avance comprobado P0.1 — 12 de octubre de 2026
- **Arte piloto creado:** el archivo `assets/characters/portador_eco/portador_idle_run_atlas.png` existe realmente, se verificó su contenido binario mediante SHA de Git y contiene **5 poses** con transparencia en celdas de **88 × 94**: **2 de idle** y **3 de run**. Se trata de una primera extracción/limpieza del concepto, todavía no de sprites finales aprobados.
- **Integración:** `ProtagonistArtBridge.gd` crea automáticamente `SpriteFrames` desde el PNG para `idle_ready` y `run_forward`. `Player.gd` utiliza arte solo en esos estados; conserva el renderer procedural en salto, ataque, golpe y esquiva. La física y los controles no fueron modificados.
- **Validación técnica:** [Godot Check aprobado para commit `d9310f2`](https://github.com/LoloscarPrr/EchoFragment/actions/runs/38333258202).
- **Aún NO aprobado:** faltan más frames y limpieza fina de silueta, sprites finales de 8 estados adicionales, prueba visual en Android y build del hito; no marcar los checks A04/A05/B como completos.
- **Siguiente lote:** refinar las poses en movimiento y completar `jump_start`, `jump_rise`, `jump_apex`, `jump_fall` y `land_light` antes de entregar una nueva APK de evaluación.

## Diagnóstico actual resumido
| Elemento | Comprobación | Resultado |
|---|---|---|
| Jugabilidad móvil v0.21 | Confirmación del usuario | ✅ Base estable |
| Plan de 9 estados | Manifiesto JSON y `P0FrameLibrary` | ✅ Especificado, no dibujado |
| Estado visual de esquiva | Código actual | ❌ Sin animación independiente |
| Puente opcional de sprites | Código en rama 0.30 | ✅ Incorporado |
| Validación Godot del puente | Workflow | ✅ Verde |
| Sprites PNG piloto | Árbol Git de rama | ✅ 5 poses integradas para idle/run (aún provisionales) |
| Sprites PNG finales P0 | Revisión de arte y cobertura completa | ❌ No existen |
| `SpriteFrames` final | Árbol Git de rama | ❌ No existe |
| APK con protagonista rediseñado | Acciones de la rama | ⏳ No generada ni probada |
| **P0 aprobado** | A + B + C + D + E | **❌ NO** |

## Decisión de producción
**Siguiente tarea es producción real de arte, no otra ronda de planificación:** dibujar hoja madre y poses clave, crear el primer conjunto animado original (idle/run), integrar y verificarlo, luego completar salto/ataque/daño/esquiva. Mantener `main` en la última versión jugable hasta una integración sin regresiones.
