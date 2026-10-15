# EchoFragment — Fase 1.1: Tajo del Eco (sin cambios visuales)

## Resultado
Se añadió un **puente de temporización** entre el animatic de **16 poses de referencia** y el ataque de espada existente. No incorpora imágenes no transparentes al juego, no reemplaza al Portador del Eco y no reinterpreta la ilustración.

## Contrato técnico validable
- Godot 4.3 y simulación de 60 Hz.
- Duración del ataque: **18 ticks / 0,30 s** (se conserva la jugabilidad actual; NO se alarga a 0,67 s).
- Startup: ticks **0–4**.
- Ventana activa: ticks **5–7**.
- Daño: un solo `hitbox.strike()` al llegar como mínimo al **tick 5**, protegido por `_sword_hit_committed` en Player.gd.
- Recuperación: ticks **8–17**.
- El hitstop y los daños del combo permanecen intactos.
- `CharacterAnimationController.attack_reference_frame_index()` devuelve de 0 a 15 durante `attack_light`, y **-1** fuera de ese estado.
- `P0FrameLibrary` sigue representando el proxy actual. No confundir esos seis dibujos con los dieciséis del animatic.

## Mapeo por tick
```text
tick       00 01 02 03 04 | 05 06 07 | 08 09 10 11 12 13 14 15 16 17
pose-ref   00 01 02 03 04 | 06 08 10 | 11 12 13 14 15 15 15 15 15 15
fase       anticipación   |   activa|     recuperación
```

## Cambios restringidos
- Nuevo `scripts/player/TajoDelEcoTimeline.gd`: tiempos, fases y referencias.
- `CharacterAnimationController.gd`: expone el índice de pose de referencia sin modificar el dibujo actual.
- `Player.gd`: utiliza la constante del evento de ataque; no cambia cuándo golpea.
- Prueba automatizada para el mapping y la ventana de impacto; Godot Check la ejecuta en CI.

## Pendientes visuales aplazados
- Las referencias de la Fase 1.0 contienen fondos, cortes y variación de silueta; no son sprites transparentes finales.
- Dibujar 16 poses coherentes, con pies y pivote constantes, separación cuerpo/capa/espada y escala uniforme.
- Conectar `Sprite2D`/atlas final a `attack_reference_frame_index()` solo cuando el arte esté realmente listo.
- Validar dirección izquierda y derecha y ataque mientras corre o salta.
- Build APK y prueba Android **pendientes**. No se afirma que el archivo en PR sea una versión instalada.

## Prueba
```bash
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/tajo_del_eco_timeline_test.gd
```
