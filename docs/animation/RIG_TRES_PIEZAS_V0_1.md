# EchoFragment — Portador 3 piezas articuladas (v0.1)

## Integración técnica realizada
La escena `res://scenes/experiments/RigTresPiezasPreview.tscn` crea de forma aislada una jerarquía `Skeleton2D` > `Bone2D` de cadera, torso, cuello y casco. Los tres Sprite2D conservan pivotes en píxeles para reutilizar las imágenes originales. Pose de prueba en bucle: `idle_ready`, inclinación de torso al correr y anticipación de ataque. **No son animaciones de carrera ni de espada terminadas**.

### Recursos binarios pendientes de GitHub
Para abrir el visor **con arte**, el directorio `res://assets/player/portador_rig2d/` debe contener estos tres PNG (no basta el JSON):
- `portador_head_helmet.png` — copiar desde `portador_head_helmet_v0_1.png`
- `portador_torso_upper.png` — copiar desde `portador_torso_upper_v0_1.png`
- `portador_pelvis_waist.png` — copiar desde `portador_pelvis_waist_v0_1.png`

**IMPORTANTE:** estos tres PNG todavía **no se han añadido como binarios a la rama GitHub**. Los scripts detectan si faltan y muestran aviso en vez de romper la escena. El montaje de vista previa JPG/PNG es una composición visual, no sustituye los tres archivos originales.

### Pivotes y escalas de trabajo
| Pieza | Pivote en fuente | Escala Sprite2D | Hueso |
|---|---|---|---|
| Casco | (550, 760) | 0.36 | `Hips/Torso/Neck/Helmet` |
| Torso | (515, 735) | 0.58 | `Hips/Torso` |
| Pelvis | (512, 287) | 0.60 | `Hips` |

- `Torso.position = (0,-82)` respecto a Hips.
- `Neck.position = (0,-241)` respecto a Torso.
- Escala del visor: `0.67`; ancla de escena `(640,420)` para 1280×720.

### Cómo probar
Abrir `scenes/experiments/RigTresPiezasPreview.tscn` en Godot 4.3 y ejecutar escena. Si aparece “FALTAN PNG”, copiar primero los tres archivos con esos nombres en las rutas indicadas.

### Criterios antes de integrar al jugador
- Corregir perspectiva/escala y el solape entre la coraza y el cinturón con rotaciones grandes.
- Separar tela de cuello, porque actualmente está pintada sobre casco y torso.
- Completar brazos, antebrazos, manos, muslos, piernas y capa posterior en PNG propios.
- Mantener `Player.gd`, tiempos del Tajo del Eco, físicas y controles de Android intactos hasta validar el rig completo.

**Estado:** montaje visual de tres piezas conseguido; adaptador Godot creado en rama experimental; pendiente instalar los PNG en GitHub, validación visual dentro de Godot y APK.