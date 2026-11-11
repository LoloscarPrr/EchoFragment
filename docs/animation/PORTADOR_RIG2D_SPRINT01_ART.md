# EchoFragment — Sprint artístico 01: cinco piezas animables

**Destino:** `feature/portador-rig2d-prototype` — Godot 4.3. **Arte canónico:** Portador del Eco con casco cerrado, armadura grafito/negra, capa granate desgarrada, acero y pequeñas marcas carmesí.

**Resultado esperado:** **cinco PNG independientes realmente dibujados desde cero como piezas**. No aceptar composiciones con cinco elementos juntos, ni extracciones de una ilustración de cuerpo entero, ni fondos de cuadros falsamente transparentes.

## Reglas de exportación (todas las piezas)
- Entregar **un archivo por pieza** con **RGBA real**; alfa 0 alrededor de la silueta; sin cuadrícula, texto ni fondo.
- Dejar **12–15 % de margen transparente libre** alrededor de cada recorte. Ninguna extremidad, punta, decoración o proyección debe tocar el borde.
- Mantener **la misma escala visual, dirección de luz (arriba/izquierda), materiales y perspectiva lateral tres cuartos** entre las piezas.
- Dibujar la **parte que queda oculta bajo la articulación**: al girar el hombro, la cintura o el cuello no pueden aparecer huecos.
- No dibujar sangre ni tajos gigantes en los PNG base. La energía carmesí es un efecto independiente.
- **El lienzo de cada pieza puede tener un tamaño distinto.** Registrar su pivote como coordenada `x,y` medida sobre el PNG final; no inventar posiciones antes de dibujar.
- Comprobar en Godot una rotación de al menos **±25°** del hueso previsto, sin atravesar otras piezas ni descubrir fondos vacíos.

## Cinco piezas prioritarias

### 01 — `portador_torso_upper.png`
- **Dibujar:** coraza completa frontal y laterales, espalda mínima bajo hombros, cuello/abertura del casco, protección de costillas y solapas de unión.
- **NO incluir:** casco, brazos, antebrazos, manos, capa ni pelvis.
- **Pivote:** centro de la unión cintura/columna, bajo el pecho.
- **Hueso existente:** `Armature/Hips/Torso`.
- **Aceptación:** ambos hombros pueden girar sin que parezca que les falta armadura; no se corta la parte superior de la coraza.

### 02 — `portador_pelvis_waist.png`
- **Dibujar:** cinturón, hebilla, cadera completa, protectores de cintura y faldón central con espacio suficiente para insertar los muslos.
- **NO incluir:** torso, muslos, pantorrillas ni botas.
- **Pivote:** centro de la cadera.
- **Hueso existente:** `Armature/Hips` (sprite independiente de la coraza).
- **Aceptación:** cubrir la unión del torso y el comienzo de las dos piernas en guardia y carrera.

### 03 — `portador_head_helmet.png`
- **Dibujar:** casco gótico cerrado aprobado, visor oscuro, reflejo carmesí discreto, cubrenuca y base del cuello terminada.
- **NO incluir:** hombros, pelo visible, cuerpo ni capa.
- **Pivote:** base del casco, sobre la articulación del cuello.
- **Hueso existente:** `Armature/Hips/Torso/Neck/Helmet`.
- **Aceptación:** se ve completo al inclinarlo ±25°; el casco conserva la misma identidad en todas las animaciones.

### 04 — `portador_arm_R_upper.png`
- **Dibujar:** hombrera de espada, bíceps acorazado y material bajo la articulación del codo. Dejar solape interior bajo la coraza.
- **NO incluir:** antebrazo, guantelete completo, mano ni espada.
- **Pivote:** centro anatómico del hombro derecho.
- **Hueso existente:** `Armature/Hips/Torso/SwordUpperArm`.
- **Aceptación:** hombro y codo tienen extremo completo para que puedan moverse sin huecos.
- **Dependencia explícita:** el arma no podrá animarse correctamente hasta fabricar `arm_R_forearm` y `hand_R`. No soldar ambas al brazo superior.

### 05 — `portador_sword.png`
- **Dibujar:** espada completa de acero oscuro, guarda, empuñadura y pomo; brillo tenue de filo opcional, sin tajo separado.
- **NO incluir:** mano, brazo ni arco de ataque/partículas.
- **Pivote:** punto de agarre exacto en la empuñadura.
- **Hueso existente:** `Armature/Hips/Torso/SwordUpperArm/SwordForearm/Sword`. Más adelante se anclará visualmente a `hand_R`.
- **Aceptación:** punta intacta, margen libre 15 % también alrededor del extremo de la hoja, rotación completa sin recortes.

## Entrega y validación por cada PNG
1. Abrir PNG y verificar transparencia **real**, margen, silueta completa, sin otras piezas adheridas.
2. Registrar `pixel_width`, `pixel_height`, `pivot_px` y `overlap_px` en el manifiesto de assets.
3. Instalar como `Sprite2D` hijo del hueso; comprobar guardia, carrera y slash.
4. Aprobar el arte solo si rota correctamente **y** conserva el diseño canónico.

**Estado inicial real:** especificación y contrato de exportación listos; **los cinco dibujos definitivos no se han generado ni subido todavía**. El rig de Godot existente es una prueba técnica con polígonos y algunos recortes experimentales, no el set definitivo.
