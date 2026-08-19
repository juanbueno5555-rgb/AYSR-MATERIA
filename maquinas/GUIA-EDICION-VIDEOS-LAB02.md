# Guía de edición — Cómo unir las 2 mitades de cada video (Lab 02)

> Grupo: Camilo Aguirre (CA) y Juan David Rangel (JD) — Curso AYSR
> Para los 3 videos del Lab 02: cada video se grabó en 2 tomas (mitad 1 + mitad 2).
> Esta guía explica cómo juntarlas en un solo archivo, en el orden correcto y dentro
> de los tiempos máximos del lab.

---

## 1. Preparación: nombres y verificación

Cada mitad quedó guardada como un archivo separado. Verificar que existan los 6 antes de editar:

| Video | Mitad 1 (archivo) | Mitad 2 (archivo) | Orden en el timeline |
|---|---|---|---|
| Video 1 — Packet Tracer (≤ 5:00) | `video1-mitad1.mp4` (JD, 0:00–2:30) | `video1-mitad2.mp4` (CA, 2:30–5:00) | mitad 1 → mitad 2 |
| Video 2 — Wireshark interfaz (≤ 5:00) | `video2-mitad1.mp4` (CA, 0:00–2:30) | `video2-mitad2.mp4` (JD, 2:30–5:00) | mitad 1 → mitad 2 |
| Video 3 — Wireshark hallazgos (≤ 7:00) | `video3-mitad1.mp4` (JD, 0:00–3:30) | `video3-mitad2.mp4` (CA, 3:30–7:00) | mitad 1 → mitad 2 |

**Antes de importar:**
- [ ] Ambas mitades del mismo video tienen la **misma resolución** y los **mismos fps**
      (recomendado 1080p / 30 fps). Si una difiere, volver a exportar la que falla.
- [ ] Cada mitad tiene silencio al inicio y al final (se recorta en la edición).
- [ ] Los nombres coinciden con la tabla para no invertir el orden.

---

## 2. Editor recomendado: Clipchamp

**Clipchamp** (editor de video gratuito de Microsoft, ya viene instalado en Windows 11;
alternativa: CapCut en el celular).

Pasos en Clipchamp:

1. **Crear un proyecto nuevo** por video (ej. "Video 1 — Packet Tracer").
2. **Importar** las dos mitades (botón Import media → seleccionar los `.mp4`).
3. **Arrastrar al timeline en orden:** primero la mitad 1, después la mitad 2,
   pegadas una detrás de la otra (sin espacio entre ellas).
4. **Recortar silencios:** seleccionar cada clip y recortar los 1–2 segundos de silencio
   del inicio y del final de cada mitad.
5. **Transición opcional:** agregar un fundido (fade) de **0,5 segundos** en el punto de
   unión entre mitad 1 y mitad 2, para que el cambio de persona no se sienta brusco.
6. **Portada (texto):** agregar un texto al inicio con el título del video y los nombres
   (clientes: Camilo Aguirre y Juan David Rangel — Curso AYSR).
7. **Audio:** dejar el diálogo al 100%; no poner música por encima de las voces. Si se usa
   música, solo como fondo muy bajito.
8. **Exportar:** resolución **1080p**, formato **MP4**, calidad alta.

> Cada video se edita y exporta por separado. Al final quedan 3 archivos finales:
> `video1-packet-tracer.mp4`, `video2-wireshark-interfaz.mp4` y
> `video3-wireshark-hallazgos.mp4`.

---

## 3. Duración objetivo por video

| Video | Mitad 1 + Mitad 2 | Límite del lab | Resultado esperado |
|---|---|---|---|
| Video 1 — Packet Tracer | JD 2:30 + CA 2:30 | **5:00 máx.** | ≈ 4:50–5:00 |
| Video 2 — Wireshark interfaz | CA 2:30 + JD 2:30 | **5:00 máx.** | ≈ 4:50–5:00 |
| Video 3 — Wireshark hallazgos | JD 3:30 + CA 3:30 | **7:00 máx.** | ≈ 6:50–7:00 |

- Si el video final queda **justo en el límite o lo pasa**, recortar el silencio restante,
  acelerar la toma más larga un 1–5% en el editor, o quitar la frase menos importante de
  la mitad más extensa.
- Si queda **muy corto** (más de 30 s bajo el límite), no hay problema: el lab pide un
  máximo, no un mínimo exacto.

---

## 4. Checklist final por video

Antes de entregar, marcar por cada uno de los 3 videos:

- [ ] Las dos mitades están en el orden correcto (mitad 1 → mitad 2, sin invertir quién habla).
- [ ] Sin espacios muertos: los silencios iniciales y finales fueron recortados.
- [ ] El cambio entre mitad 1 y mitad 2 es fluido (fundido opcional de 0,5 s aplicado).
- [ ] Cada mitad se escucha completa, sin partes cortadas por el empalme.
- [ ] El audio del diálogo es claro y no hay música que lo tape.
- [ ] La portada muestra el título del video y los nombres (CA y JD).
- [ ] La duración total respeta el límite del lab (5:00 / 5:00 / 7:00).
- [ ] El video se reproduce de corrido de principio a fin sin saltos ni congelamientos.
- [ ] Se exportó en 1080p MP4 y se guardó con el nombre final del video.