# Guía de edición — Cómo unir las 2 mitades del video (Lab 03)

> Grupo: Camilo Aguirre (CA) y Juan David Rangel (JD) — Curso AYSR
> Para el video del Lab 03 (nslookup): el video se grabó en 2 tomas (mitad 1 + mitad 2).
> Esta guía explica cómo juntarlas en un solo archivo, en el orden correcto y dentro
> del tiempo máximo del lab.

---

## 1. Preparación: nombres y verificación

Cada mitad quedó guardada como un archivo separado. Verificar que existan los 2 antes de editar:

| Video | Mitad 1 (archivo) | Mitad 2 (archivo) | Orden en el timeline |
|---|---|---|---|
| Video — nslookup Lab 03 (≤ 5:00) | `video1-mitad1.mp4` (CA, 0:00–2:30) | `video1-mitad2.mp4` (JD, 2:30–5:00) | mitad 1 → mitad 2 |

**Referencia del guion:** `GUION-VIDEO-NSLOOKUP-LAB03.md` (bloques A–G; las salidas reales
están en `evidencias/video-nslookup-BDE.txt` y `video-nslookup-FGC.txt`).

**Antes de importar:**
- [ ] Ambas mitades tienen la **misma resolución** y los **mismos fps**
      (recomendado 1080p / 30 fps). Si una difiere, volver a exportar la que falla.
- [ ] Cada mitad tiene silencio al inicio y al final (se recorta en la edición).
- [ ] Los nombres coinciden con la tabla para no invertir el orden.

---

## 2. Editor recomendado: Clipchamp

**Clipchamp** (editor de video gratuito de Microsoft, ya viene instalado en Windows 11;
alternativa: CapCut en el celular).

Pasos en Clipchamp:

1. **Crear un proyecto nuevo** (ej. "Video nslookup Lab 03").
2. **Importar** las dos mitades (botón Import media → seleccionar los `.mp4`).
3. **Arrastrar al timeline en orden:** primero la mitad 1, después la mitad 2,
   pegadas una detrás de la otra (sin espacio entre ellas).
4. **Recortar silencios:** seleccionar cada clip y recortar los 1–2 segundos de silencio
   del inicio y del final de cada mitad.
5. **Incrustar la foto del Bloque C:** en el bloque C de la mitad 1 (≈ 1:20–2:30) debe
   aparecer la captura real de la escuela (`evidencias/foto-7c-escuela.png`), sobreimpresa
   mientras CA explica — NO se grabó en vivo. Ajustar su duración a la explicación.
6. **Transición opcional:** agregar un fundido (fade) de **0,5 segundos** en el punto de
   unión entre mitad 1 y mitad 2, para que el cambio de persona no se sienta brusco.
7. **Portada (texto):** agregar un texto al inicio con el título del video y los nombres
   (clientes: Camilo Aguirre y Juan David Rangel — Curso AYSR).
8. **Audio:** dejar el diálogo al 100%; no poner música por encima de las voces. Si se usa
   música, solo como fondo muy bajito.
9. **Exportar:** resolución **1080p**, formato **MP4**, calidad alta.

> Al final queda 1 archivo final: `video-nslookup-lab03.mp4`.

---

## 3. Duración objetivo

| Video | Mitad 1 + Mitad 2 | Límite del lab | Resultado esperado |
|---|---|---|---|
| nslookup Lab 03 | CA 2:30 + JD 2:30 | **5:00 máx.** | ≈ 4:50–5:00 |

- Si el video final queda **justo en el límite o lo pasa**, recortar el silencio restante,
  acelerar la toma más larga un 1–5% en el editor, o quitar la frase menos importante de
  la mitad más extensa.
- Si queda **muy corto** (más de 30 s bajo el límite), no hay problema: el lab pide un
  máximo, no un mínimo exacto.

---

## 4. Checklist final

Antes de entregar, marcar:

- [ ] Las dos mitades están en el orden correcto (mitad 1 → mitad 2, sin invertir quién habla).
- [ ] Sin espacios muertos: los silencios iniciales y finales fueron recortados.
- [ ] La foto del Bloque C (escuela, NXDOMAIN) aparece sobreimpresa en el momento correcto.
- [ ] El cambio entre mitad 1 y mitad 2 es fluido (fundido opcional de 0,5 s aplicado).
- [ ] Cada mitad se escucha completa, sin partes cortadas por el empalme.
- [ ] El audio del diálogo es claro y no hay música que lo tape.
- [ ] La portada muestra el título del video y los nombres (CA y JD).
- [ ] La duración total respeta el límite del lab (5:00 máx).
- [ ] El video se reproduce de corrido de principio a fin sin saltos ni congelamientos.
- [ ] Se exportó en 1080p MP4 y se guardó con el nombre final del video.