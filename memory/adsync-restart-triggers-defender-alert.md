---
name: adsync-restart-triggers-defender-alert
description: "Reiniciar el servicio ADSync en MEUAZAC011 dispara una alerta de Defender for Cloud 'Potential Entra Connect Sync tampering' — verdadero positivo benigno; avisar antes y notificar a conet después"
metadata:
  type: reference
---

Reiniciar el servicio **ADSync** (o pararlo) en el servidor de Azure AD Connect **MEUAZAC011**
dispara una alerta de **Microsoft Defender for Cloud**: *"Potential Entra Connect Sync
tampering"* (Medium). Es un **verdadero positivo de una acción benigna** — la detección vigila
esa acción porque los atacantes reinician/manipulan ADSync para volcar credenciales del
Connect.

Confirmado el 15-jul-2026: un `Restart-Service ADSync` (para recuperar el scheduler parado) a
las 07:25 UTC generó la alerta al minuto, sobre la VM `meuazac011`.

**How to apply:** cualquier mantenimiento sobre AAD Connect / servidores de identidad **avisa
antes** de que generará esta alerta. Tras hacerlo: documenta la acción (hora + cuenta) y
**notifica a conet.de** ([[conet-de-administers-maswer-infra]] — administran los servidores y
reciben las alertas de Defender) con la explicación benigna para que la cierren como actividad
planificada. **No la cierres en silencio.**

Nota relacionada: el scheduler de AAD Connect puede quedar **congelado** si la VM se apaga
(posible auto-shutdown en Azure); síntoma = `NextSyncCycleStartTimeInUTC` estancado en el
pasado aunque `SyncCycleEnabled=True` y servicio `Running`. Se recupera con
`Restart-Service ADSync` + `Start-ADSyncSyncCycle -PolicyType Delta`. Ver
[[maswer-aad-connect-server]].
