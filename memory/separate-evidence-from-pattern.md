---
name: separate-evidence-from-pattern
description: "En la triage, separar lo observado de lo inferido por patrón y de lo recordado sin verificar — nombrar la alternativa benigna y el artefacto que resuelve la duda"
metadata:
  type: feedback
---

Al diagnosticar, mantener tres niveles visiblemente separados: (1) lo que es **observable** en
el material aportado, (2) lo que es **inferencia** a partir de un patrón conocido, (3) lo que
afirmo **de conocimiento general sin verificar**.

El desafío de Sebastian en un ticket de correo sospechoso ("¿y de dónde sacas esa conclusión?")
dejó ver que había fundido los tres en un veredicto plano — "es un intento de fraude" — cuando
la única evidencia dura era una incoherencia interna del mensaje (una petición de oferta por un
servicio que no encaja con el cargo del remitente) más que el destinatario no reconociera la
relación. Ni cabeceras, ni cuerpo del mensaje, y la identidad de la empresa remitente estaba
recordada de memoria, no comprobada.

**Why:** una etiqueta segura que la evidencia no sostiene se copia tal cual a la respuesta al
cliente y al registro del ticket. Además esconde la explicación alternativa — aquí, prospección
B2B mal dirigida, que produce exactamente el mismo observable. Afirmar de más no hace la
respuesta más útil, porque la recomendación operativa era idéntica bajo las dos lecturas; solo
la hace equivocada si la lectura benigna resulta ser la buena.

**How to apply:**
- Etiquetar explícitamente lo no verificado ("recordado, no comprobado").
- Nombrar la alternativa benigna cuando de verdad encaje con la misma evidencia.
- Decir **qué único artefacto** resuelve la ambigüedad (aquí: el `.msg` original — un
  `Reply-To` en dominio ajeno o un fallo de DMARC lo zanjan).
- Y señalar que la acción recomendada se sostiene en ambos casos — eso es lo que hace seguro
  actuar antes de tener certeza.

Aplica al bloque DIAGNOSIS y por partida doble a la respuesta al cliente, que no puede llevar un
veredicto más firme que el análisis interno. El mismo fallo, contra un ingeniero con consola
delante, está en [[defer-to-direct-console-evidence]]; el mismo fallo inventando datos de
producto, en [[maswer-m365-copilot-licensing]]. Relacionado:
[[steps-grounded-in-documented-infra]], [[reply-tone-direct-not-nice]].
