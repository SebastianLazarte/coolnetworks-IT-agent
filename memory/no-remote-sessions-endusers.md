---
name: no-remote-sessions-endusers
description: "No proponer sesiones de control remoto sobre equipos de usuarios finales como vía de solución — no funcionan por la restricción de admin/UAC; ir por rutas server-side"
metadata:
  type: feedback
---

No sugerir sesiones de control remoto sobre las máquinas de usuarios finales de Maswer (ni que
las conduzcan ellos ni nosotros) como camino de resolución. No funcionan bien por la
restricción de elevación admin/UAC en los endpoints de usuario.

**Why:** Sebastian dijo que la opción remota "no funciona bien por lo de admin" y pidió
explícitamente que dejara de proponerla. Se creía que el origen era
[[oliver-left-maswer-no-handover]]: que no había derechos de admin local aplicables a la flota,
y que la herramienta remota tampoco estaba estandarizada
([[remote-access-teamviewer-fails-fallback-anydesk]]).

⚠️ **Corrección (09-sep-2026) — la causa era otra.** Sí hay admin local en la flota, y él ya lo
tenía: las GPO `LocalAdminRights_adm1/adm2` lo conceden desde hace años. Lo que rompía la
elevación era el **deny de logon interactivo de `adm1` sobre OU=Clients**, más la ausencia de
canal remoto (RPC bloqueado, WinRM cerrado en los puestos) → detalle en
[[maswer-local-admin-tiering-adm1-adm2]]. **La preferencia sigue vigente** — no proponer sesiones
remotas — pero por el canal, no por los permisos, y deja de aplicar en cuanto haya un agente
desatendido desplegado y se valide `Admin2_SLazarte` contra un cliente piloto.

**How to apply:**
- Cuando un arreglo necesitaría llegar al equipo de un usuario, ir por **rutas server-side /
  admin**: ACLs del file server, backups, AD, consolas de M365/Intune — no proponer sesión
  remota.
- Si hay que ejecutar código en el endpoint sí o sí, la única vía real es Intune → Scripts de
  plataforma, no una sesión interactiva → [[maswer-diagnostico-endpoint-sin-live-response]].
- Para *probar* algo que necesita acceso que él no tiene, el default es que se lo autoconceda y
  lo pruebe él → [[prefer-admin-self-test]] y [[test-token-refresh-without-logoff]].
