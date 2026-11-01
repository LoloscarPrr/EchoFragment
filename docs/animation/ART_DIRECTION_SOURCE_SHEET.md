# EchoFragment — Dirección de arte aprobada: lámina del Portador del Eco

**Decisión del usuario (2026-11-01):** descartar el aspecto geométrico del ensayo de casco, cuello, torso y pelvis en SVG. Retomar la lámina visual detallada `a_polished_high_detail_game_asset_design_sheet_fo.png`, producida en esta conversación, como **fuente oficial del estilo y los diseños de las 22 piezas**.

## Qué sí se conserva
- El diseño del personaje completo en el panel izquierdo de la lámina.
- Los 22 objetos de la cuadrícula central como **referencia visual y forma de partida**.
- Fantasía oscura, metal grafito con acabados metálicos, ojos carmesí, capa rasgada y espada oscura/roja.
- Montaje estático y anatómico aprobado antes de animar.

## Qué no se debe repetir
- No convertir el diseño en dibujos vectoriales simplificados (el usuario rechazó ese aspecto).
- No volver a cortar las ilustraciones de cuerpo completo por franjas horizontales.
- No tratar los minúsculos recortes de la lámina como assets definitivos: los cuadros de 1536×1024 ofrecen sprites de unos 40–135 píxeles.
- No agrandar los cuadros sin generar detalle real, ni prometer que tendrán calidad de alta resolución.
- No fusionar la rama experimental con `main` ni sustituir al personaje jugable hasta que se apruebe un montaje completo y la calidad de las piezas.

## Estrategia de extracción / recreación
1. Usar el **PNG original de la lámina**, no una captura del teléfono.
2. Generar un atlas preliminar **de 22 imágenes separadas, recortadas, con alfa**; corregir el fondo y texto residual del panel.
3. Dibujar/recrear después cada pieza a calidad jugable **desde ese diseño exacto**, conservando silueta, materiales, proporciones y extremos ocultos de articulación.
4. Validar un ensamblaje neutro de cuerpo completo con las nuevas piezas antes de producir Skeleton2D.
5. La participación del usuario recortando manualmente se admite para correcciones puntuales, pero no debe exigirse como paso obligatorio.

## Estado actual
Se ha comprobado que el PNG fuente original de la lámina está disponible en la conversación y se ha preparado un paquete local de recortes exploratorios para revisión. **No se considera arte terminado ni se importa a Godot aún.** El trabajo SVG anterior queda como experimento descartado a nivel visual.
