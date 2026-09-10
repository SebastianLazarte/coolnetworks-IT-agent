---
name: dont-invent-portal-navigation
description: "No dictar rutas de menú ni URLs de portales de memoria — verificar en la doc o pedir captura; un deep link que redirige a Home es falta de permiso, no una URL mala"
metadata:
  type: feedback
---

Cuando Sebastian pide "el paso a paso" en un portal de Microsoft, **no recitar el árbol de menú
ni las URLs de memoria**. Los portales cambian de estructura y una ruta inventada le hace
perder minutos clic a clic. El 3-sep-2026 me corrigió dos veces en la misma sesión: *"Te estas
inventando no hay general"* y *"tu link me manda a home"*.

**Why:** él está delante de la consola. Cada ruta falsa que le doy la paga él en tiempo, y
erosiona la confianza en el resto del diagnóstico, que sí era bueno. Además hay una causa real
que se me escapó por no verificar: **un deep link de Settings redirige a Home cuando falta el
permiso**, o sea que el síntoma que él reportaba era **información de diagnóstico**, no un fallo
de la URL.

**How to apply:**
- Antes de dictar una ruta de portal: consultar la doc de Microsoft (WebSearch/WebFetch sobre
  `learn.microsoft.com`) o pedirle una captura de la columna. Las dos cosas son más rápidas que
  equivocarse.
- Dar el **nombre exacto de la opción** y el criterio de licencia/permiso que la habilita, no
  solo la secuencia de clics: la mitad de las veces la opción no está porque no está licenciada
  — mismo patrón que [[maswer-m365-copilot-licensing]] (E3/E5 vs Microsoft 365 Business) y que
  el mapa de consolas de [[maswer-diagnostico-endpoint-sin-live-response]].
- Si me corrige, corregir en una línea y seguir — sin justificaciones. Relacionado:
  [[defer-to-direct-console-evidence]], [[separate-evidence-from-pattern]].
