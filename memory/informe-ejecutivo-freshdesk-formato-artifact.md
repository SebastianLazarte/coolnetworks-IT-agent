---
name: informe-ejecutivo-freshdesk-formato-artifact
description: "Los informes ejecutivos de tickets de Freshdesk para dirección se entregan como Artifact de claude.ai en formato pirámide/MBB, no como .docx. El del trimestre jun-ago 2026 es la plantilla de referencia."
metadata:
  type: reference
---

**Artifact de referencia — "Soporte Maswer Alemania", trimestre jun–ago 2026:**
`https://claude.ai/code/artifact/aeb602b2-f0bc-47e0-88a6-0021cdade983`

Es el molde para los informes de actividad de service desk a dirección. Se entrega **como
Artifact publicado**, no por el pipeline `.docx` de `reports/CONTEXT.md` (ese sigue siendo para
los reportes de caso).

## Estructura del molde

1. **Header** — eyebrow (`Coolnetworks · Service Desk · Informe a dirección`), título + periodo,
   meta (alcance / fuente / fecha de corte).
2. **Respuesta de gobierno** — una frase que ya contiene la conclusión, con el dato clave en
   `<em>`; debajo 3 soportes numerados (01/02/03).
3. **SCR** — Situación · Complicación · Resolución, tres columnas.
4. **KPIs** — 4 tarjetas con nota al pie de desglose.
5. **Exhibits numerados** — cada uno con un titular que es una *afirmación*, no una etiqueta
   ("El servicio cerró más tickets de los que recibió", no "Volumen mensual").
6. **Palancas** — 3 recomendaciones con línea de impacto cuantificado.
7. **Footer** — fuente, fecha de extracción y **base de cálculo explícita** (ventana de fechas,
   si los tiempos son horas naturales, si se descuentan esperas de terceros).

Paleta azul sobria con tokens de tema claro/oscuro, tipografías Archivo + IBM Plex Sans/Mono.

## Cómo actualizarlo

Es propiedad del usuario y se republica **a la misma URL**: leerlo con `action: "read"`, editar
el HTML descargado y publicar pasando `url`. Nunca regenerar de cero —
[[edit-dont-regenerate-drafts]]. Tampoco cambiar el favicon (🎫) ni el título.

## Cuidado con la aritmética

La versión de jun–ago 2026 se publicó con cifras que no cuadran entre la tabla de detalle y los
gráficos agregados (total de cerrados, y el bucket "Accesos"). Antes de publicar cualquier
versión nueva: **cuadrar las filas de la tabla contra cada KPI y cada barra**, y comprobar que
la suma de familias es igual a la base declarada.
