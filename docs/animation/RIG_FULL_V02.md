# EchoFragment — Prototipo articulado de cuerpo completo v0.2

## Resultado concreto (2026-10-26)
Se incorporaron `PortadorFullRigV02.gd` y `RigFullPreviewV02.tscn` en la rama `feature/portador-rig2d-prototype`. Son **recursos experimentales que no cambian el juego publicado ni Main.tscn**.

El sistema prepara **17 elementos animables** desde **nueve ilustraciones fuente independientes**: casco, torso, pelvis, dos brazos, dos piernas, capa y espada. El brazo tiene hombro/codo/mano independientes y la pierna tiene cadera/rodilla/pie independientes. `Sprite2D.region_rect` segmenta las ilustraciones completas del brazo y la pierna para el **test mecánico**. Los 17 PNG definitivos, completamente dibujados debajo de cada junta, aún están pendientes.

### Qué prueba el visor
- Reposo con respiración y oscilación de capa.
- Carrera alternando muslos, rodillas y brazos.
- Tajo con anticipación/giro de torso/gesto de codo/muñeca/espada/recuperación.
- Esquiva agachada y salto.
- Giro horizontal en ambos sentidos sin modificar la raíz física del jugador.

## Nueve archivos de entrada necesarios
Estos masters **sí están guardados en la biblioteca Canva conectada**; sus IDs y nombres se guardan en `full_rig_v02_manifest.json`. No se han incorporado como binarios a GitHub porque falló el entorno de archivos.

Exportar o copiar los originales en `res://assets/player/portador_rig2d/v02/` **con estos nombres exactos**:

| Archivo | Origen |
| --- | --- |
| `portador_head_helmet.png` | `portador_head_helmet_v0_1.png` |
| `portador_torso_upper.png` | `portador_torso_upper_v0_1.png` |
| `portador_pelvis_waist.png` | `portador_pelvis_waist_v0_1.png` |
| `portador_arm_R.png` | `brazo_de_caballero_con_grietas_carmesí.png` |
| `portador_arm_L.png` | `guantelete_carmesí_del_caballero_oscuro.png` |
| `portador_leg_R.png` | `pierna_acorazada_gótica_carmesí.png` |
| `portador_leg_L.png` | `pierna_acorazada_del_caballero_oscuro.png` |
| `portador_cape.png` | `capa_carmesí_desgarrada.png` |
| `portador_sword.png` | `espada_demoníaca_de_acero_y_fuego_carmesí.png` |

Abrir `scenes/experiments/RigFullPreviewV02.tscn` con Godot 4.3. La escena muestra un indicador explícito cuando faltan imágenes y **retiene el maniquí provisional** para que el proyecto no falle.

## Diferencia crucial entre progreso técnico y arte final
- **Listo:** rig y control de articulaciones, cargador de nueve fuentes, animaciones experimentales de brazos/piernas, visor y prueba automática de carga.
- **Aún no listo:** 17 imágenes finales sin costuras, pivotes medidos y retocados con todos los PNG en GitHub, vista visual validada con las texturas, integración al jugador de Android y APK.
- Las uniones del codo/rodilla pueden mostrar cortes rectos en poses extremas. Requieren ilustración de superficies interiores/solapes, no más cambios de tamaño de una misma imagen completa.
- El origen de los masters es arte aprobado existente, pero aún necesita consistencia de escala y perspectiva al pasar a vistas nuevas.
- No se altera `Player.gd`, `CanonicalProtagonistVisual.gd`, hitboxes, física, inventario, esquiva o la línea de tiempo del Tajo del Eco.

## Pruebas
`godot --headless --path . --editor --quit` y `godot --headless --path . --script res://tests/rig_full_v02_test.gd`.
La CI verifica sintaxis, visor, API de poses y ausencia de crash sin imágenes. **No prueba todavía las articulaciones texturizadas.**

## Siguiente tarea de arte
Pintar superficies ocultas de codos/rodillas, reemplazar segmentación rectangular por 12 PNG de extremidades independientes, conservar casco/torso/pelvis/capa/espada, y montar el pack real antes de integrar el rig con el controlador de combate.
