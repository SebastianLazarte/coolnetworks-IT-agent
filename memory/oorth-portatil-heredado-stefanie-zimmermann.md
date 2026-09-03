---
name: oorth-portatil-heredado-stefanie-zimmermann
description: El portátil de Stefanie Zimmermann (RRHH, Maswer DE) se llama OORTH — es el equipo heredado de Oliver Orth, nunca reconstruido ni renombrado; HP 255 G8 con 8 GB, 58 CVEs abiertas; el 3-sep-2026 se solicita sustitución vía Vincenzo Valle y Maurizio Carroccia.
metadata:
  type: project
---

Ticket "Laptop Probleme" (2-sep-2026, Stefanie Zimmermann, RRHH Maswer DE): el portátil se cuelga desde hace meses con cualquier aplicación, Teams incluido.

## Lo verificado en consola (3-sep-2026)

- Nombre del equipo: **`OORTH`** — es el portátil del **anterior IT, Oliver Orth**, reasignado sin reinstalar ni renombrar ([[oliver-left-maswer-no-handover]]).
- **HP 255 G8 Notebook PC**, Windows 11 25H2 build 26200.9106, dominio `intern.maswer.com`.
- Registrado en Intune el **2024-05-14**; conforme; activo.
- Primary user: Stefanie Zimmermann. **Único usuario con logons en 30 días: `szimmermann`** — ninguna cuenta `*OOrth` inicia sesión ahí.
- **Sin alertas ni incidentes** en Defender. `No known risks`.
- **58 vulnerabilidades abiertas: 7 Critical, 15 High, 18 Medium, 18 Low.**

## Reportado por la usuaria (no verificado en consola)

Task Manager: 6,9 GB en uso de 8 GB, **3,2 GB en pool no paginado**, 454 MB disponibles. Lento ya desde el arranque. Cifras que ella transcribió a ChatGPT, sin captura.

Un pool no paginado de 3,2 GB es memoria de **kernel**, no falta de RAM: apunta a fuga de un driver. Sospechoso principal: el **adaptador virtual del cliente SSL VPN de Sophos** (driver de red heredado de la época del equipo). Ojo: ese Sophos es el **cliente VPN**, no un antivirus — el AV es Defender y no hay doble motor.

## Decisión

**3-sep-2026:** no se persigue el driver. El equipo es insuficiente para el puesto y arrastra dos años sin reconstruir → **se solicita sustitución**, a hablar con **Vincenzo Valle** y **Maurizio Carroccia** ([[maswer-calden-contacts]]). Ticket en *Waiting on third party*; a la usuaria se le ha dicho en inglés que siga trabajando con el actual mientras tanto.

**Why:** un portátil de admin heredado, con las herramientas y drivers de su dueño anterior y sin parchear, no se arregla afinando un tag de pool. La prueba de diagnóstico ya hecha justifica la sustitución sin que parezca una decisión por inercia.

**How to apply:**
- Al sustituirlo, **renombrar dentro de la reinstalación**, nunca suelto: el dominio es híbrido y renombrar implica rejoin.
- Revisar si hay **más equipos con nombre de persona** en el inventario: cada uno es otro equipo heredado sin reconstruir.
- Método de diagnóstico usado y sus límites → [[maswer-diagnostico-endpoint-sin-live-response]].
