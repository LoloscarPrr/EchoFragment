# EchoFragment — Fase 1.2 (primer cambio visual REAL)

Se conservan los tres dibujos originales del Portador del Eco que aparecen en su hoja canónica: personaje de perfil, guardia y tajo. Los archivos WebP mantienen transparencia y un punto de apoyo fijo: `(0, 49)` en coordenadas del jugador.

## Qué cambia
- La espada deja de dibujarse como un monito geométrico: se visualizan fotogramas originales en reposo, guardia y tajo.
- El `CanonicalProtagonistVisual` se utiliza únicamente cuando está equipada la espada.
- Al equipar otro arma se restaura `ProtagonistProxyVisual`, para no confundir la ilustración con arco o báculo.
- Se suprime el arco dibujado de `P0CombatEffects` durante el tajo con sprite, porque el efecto rojo viene incluido en la ilustración original.
- La sincronización del golpe y de la física no cambia: conserva los 18 ticks, la ventana activa y el daño.

## Limitación conocida
Todavía son tres ilustraciones estáticas procedentes del concept art, **no** la animación completa de 16 dibujos independientes. La primera integración sirve para comprobar visibilidad, silueta y tamaño en Android. Los cambios de pose pueden verse bruscos; se corregirán al producir animaciones finales. Algunos restos de suelo de la lámina conceptual pueden seguir apareciendo en los recortes.

## Pruebas
Validación con Godot 4.3 headless en CI; compilación Android en GitHub Actions. No borrar datos ni desinstalar versiones previas sin comprobar firma y versionado del APK.