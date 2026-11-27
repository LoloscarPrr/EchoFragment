# EchoFragment — Arco de un solo botón (v0.5.4 experimental)

**Rama base:** feature/portador-weapon-visual-v053 (escenario y otras armas conservados).

## Mecánica definitiva del arco

Solo existe el botón principal **ARCO**:

- Pulsación corta, enemigo cercano: primer combo de **puñetazos**, luego **patada** con retroceso, luego **flechazo**.
- Pulsación corta, sin enemigo cercano: dispara directamente.
- Mantener el mismo botón al menos 0,25 segundos: carga la flecha. Al soltar, dispara con bonificación según el tiempo de carga.

No existe un botón secundario para el arco. El joystick, salto y esquiva conservan multitouch.

## Arte seleccionado del usuario

Los **dos atlas** de 3 × 3 contienen nueve cuadros por atlas, celdas de 448 × 448 y pivote aproximado (224,400). Deben copiarse en estas rutas **antes** de exportar la APK visual:

- `assets/player/portador_bow_v054/combo.png`
- `assets/player/portador_bow_v054/charged.png`

El componente `BowApprovedFrames.gd` los carga automáticamente. Si todavía no están en la rama, se usa temporalmente el atlas del Portador anterior. **No confundir un APK compilado sin estos archivos con la integración artística terminada.**

## Animación

`combo.png`: reposo, avance, preparación de puñetazos, impacto, segundo puñetazo, patada, recuperación, apuntado y disparo.

`charged.png`: reposo, preparar, apuntar, inicio de carga, concentración, tensar, carga alta, máxima y liberación.

## Pendiente

Las dos ilustraciones tienen cuadros clave. Falta ampliar la interpolación entre poses, revisar que el brazo y el arco mantengan consistencia, y validar el arte en dispositivo. No realizar merge a `main` ni publicar APK final antes de importar los archivos y probarlos.
