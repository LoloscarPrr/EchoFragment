# EchoFragment 0.30 — Valle Gris Renacido

**Estado:** planificación técnica iniciada, implementación visual pendiente.
**Base comprobada:** versión Android 0.21; conservar package ID, firma de desarrollo y el comportamiento de controles narrativos y joystick.
**Visión:** vertical slice de fantasía oscura, aventura narrativa de acción lateral, personajes legibles, impactos con peso y controles táctiles cómodos.

## Decisión principal
Dejar de añadir decoraciones sobre el renderer geométrico como vía principal de mejora gráfica. Sustituirlo gradualmente por **arte auténtico** (sprites transparentes, tiles/escenarios ilustrados y VFX) mientras los scripts de combate, colisión y narrativa mantienen la autoridad sobre gameplay. Mantener fallback procedural durante la transición.

## Prioridades de arte, en orden
1. **Protagonista — Portador del Eco.** Basado en la hoja conceptual existente: cabello negro, armadura oscura, dos faldones granate, espada a la derecha, marca roja en brazo izquierdo y broche roto. Producción original; la cadencia arcade es referencia de movimiento, no copia de personajes ni recursos ajenos.
2. **Movimiento y combate.** Piloto: idle, run, jump_start, jump_rise, jump_apex, jump_fall, land_light, attack_light y hit_light; agregar dodge y nuevas poses de combo en una segunda tanda. Animación por frames y tiempos en ticks; conservar root motion bajo control del script.
3. **Valle Gris — primer tramo.** Cielo pintado, montañas y arquitectura con parallax, camino/bosque/ruinas diferenciados, terreno y props coherentes, puntos de interés claros y contraste alrededor del jugador.
4. **Enemigos + jefe.** Siluetas únicas, anticipación de ataque, feedback al recibir daño, transformación del Caballero Fragmentado y lectura táctil en una pantalla de móvil.
5. **Interfaz y audio.** Paneles narrativos con botones claramente pulsables, HUD de vida/aguante más compacto, feedback de acciones y audio de pasos/salto/golpe/interacción, con controles de volumen.

## Producción y arquitectura
- Primero: una escena de referencia con proporciones, escala de píxel, paleta y reglas de legibilidad aprobadas.
- Carpetas sugeridas: `assets/characters/portador_eco/`, `assets/enemies/`, `assets/world/valle_gris/`, `assets/fx/`, `assets/ui/`, `assets/audio/`.
- Exportación de sprites: PNG RGBA con fondo transparente, frames de tamaño consistente y pivote documentado. Archivos fuente editables conservados aparte.
- Cargar SpriteFrames/AnimatedSprite2D o atlas equivalente con adaptador entre estado de simulación y animación. No hacer que la cantidad de frames decida el daño o la física.
- Cambiar un sistema visual a la vez y conservar la alternativa procedural hasta comprobar su nuevo reemplazo en el dispositivo.
- No prometer 143/543 dibujos como terminados por el solo hecho de tener el manifiesto: los fotogramas deben existir como archivos y estar integrados.
- El manifiesto `docs/animation/P0_PILOT_MANIFEST.json` sirve de base para estados, pero se contrastará con el diseño conceptual ampliado.

## Lotes internos (sin obligar a probar todas las APK)
| Etapa | Entrega verificable | Validación |
|---|---|---|
| 0.22–0.23 | Contrato de assets, pivotes, escala y loader con fallback | Godot headless + Android |
| 0.24–0.25 | Sprites originales completos para piloto de protagonista | Animaciones cubiertas, sin pop de raíz |
| 0.26–0.27 | Entorno Valle Gris con capas ilustradas y primer enemigo rediseñado | Sin errores visuales en cámaras/colisiones |
| 0.28 | Combat feel, jefe y VFX coherentes | Hitboxes y telegraphs alineados |
| 0.29 | HUD/narrativa y optimización Android | Sin bloqueo de menús o botones |
| **0.30** | **APK de hito con cambio visual obvio** | Build verde + prueba manual Xiaomi |

## Criterios de aceptación del hito 0.30
- Al comparar capturas del inicio con 0.21, protagonista y primer escenario ya no dependen visualmente de formas geométricas provisionales.
- Todas las acciones base muestran animaciones sin saltos evidentes de posicionamiento, especialmente correr y saltar horizontalmente.
- Joystick + salto, joystick + esquiva, joystick + ataque, y decisiones narrativas funcionan como en 0.21.
- Eventos, inventario, progresión, enemigo común y Caballero Fragmentado siguen jugables.
- `applicationId` invariable, `versionCode` creciente, firma de desarrollo compatible y APK Android correctamente generada.
- Revisión de rendimiento en dispositivo; la CI no equivale a garantía de FPS ni de interacción táctil real.
- Si el volumen de arte es superior al tiempo disponible, reducir **el tramo geográfico**, no reemplazar la calidad artística por geometría extra.

## No objetivos de este hito
- Mundo abierto completo, ciudad y fortaleza enteras, todos los arquetipos, cientos de animaciones terminadas o decenas de enemigos.
- Cambios destructivos a la jugabilidad existente o al repositorio de otros juegos.

## Regla de entrega
Las fases internas pueden pasar por CI sin pedirle al director creativo que instale cada APK. Solo se anuncia el hito listo cuando archivos, integración, Godot y Android realmente hayan sido comprobados.
