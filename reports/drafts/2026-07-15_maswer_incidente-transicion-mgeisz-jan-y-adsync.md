# Reporte especial — Transición de cuenta MGeisz→Jan Paschold e incidencia de sync (AAD Connect)

- **Fecha del reporte:** 2026-07-15
- **Cliente / entorno:** Maswer (AD híbrido `intern.maswer.com` → tenant `maswerag.onmicrosoft.com`)
- **Sede afectada:** Calden (OU=KAS)
- **Técnico:** Sebastian (IT-Support-Germany) — único IT interno de Maswer
- **Ticket origen:** "New employee in Calden" — Vincenzo Valle (portal), 13-jul-2026
- **Clasificación:** Accounts and Access · P2 · derivó en alerta de seguridad (Defender for Cloud)
- **Estado:** ✅ **RESUELTO** (cliente notificado) — queda 1 acción externa: aviso a conet.de por la alerta Defender

---

## 1. Resumen ejecutivo
Un ticket rutinario de "empleado nuevo reemplaza a otro" destapó **tres problemas
encadenados**:

1. **Higiene de identidad:** la cuenta de un empleado dado de baja (Michael Geisz,
   baja 31-may-2026) siguió **activa 6 semanas** y fue **usada por otra persona**
   (Jan-Lukas Paschold, alta 01-jul-2026) con las credenciales del anterior.
2. **Sync parado:** el motor de Azure AD Connect en `MEUAZAC011` llevaba **sin
   sincronizar desde el 14-jul 14:06**, por lo que el cambio de cuenta no llegaba a M365.
3. **Alerta de seguridad:** al reiniciar el servicio ADSync para recuperar el sync,
   Microsoft Defender for Cloud disparó una alerta *"Potential Entra Connect Sync
   tampering"* (Medium) — **verdadero positivo de una acción benigna**.

La transición de la cuenta se ejecutó correctamente y **propagó a M365** (verificado).
El MFA se reseteó según lo pedido y Vincenzo fue notificado. **Caso resuelto.** Única
acción externa restante: notificar la alerta Defender a conet.de como benigna (ver §6).

---

## 2. Cronología
| Fecha/hora | Evento |
|---|---|
| 31-may-2026 | Michael Geisz deja la empresa. **Su cuenta AD no se deshabilita.** |
| 01-jul-2026 | Jan-Lukas Paschold empieza y trabaja **con la cuenta completa de Michael** (login + correo). |
| 13-jul-2026 12:00 | Vincenzo abre ticket: pide "renombrar" la cuenta y resetear 2FA. |
| 14-jul-2026 | Triage + validaciones + ejecución del traspaso en AD on-prem (rename `MGeisz`→`JPaschold`, direcciones, **contraseña conservada** por decisión). Verificado en AD. |
| 14-jul-2026 14:06 | **Último sync correcto** de AAD Connect. A partir de aquí, el scheduler deja de correr (VM probablemente apagada/atascada). |
| 15-jul-2026 ~08:45 | Se detecta que M365 sigue mostrando "Michael Geisz" → el cambio no propagó. |
| 15-jul-2026 ~09:25 (07:25 UTC) | Diagnóstico: scheduler congelado (`NextSyncCycleStartTimeInUTC` en 7/14). Se ejecuta `Restart-Service ADSync` + `Start-ADSyncSyncCycle`. |
| 15-jul-2026 07:25 UTC | Defender for Cloud dispara *"Entra Connect Sync tampering"* en `meuazac011` por el reinicio. |

---

## 3. Qué se hizo
**Decisión:** en vez de reutilizar sucio (compartir credenciales) o crear cuenta nueva
y migrar, se optó por **traspaso controlado de la cuenta** a Jan, con validación previa.

**Validaciones previas (solo lectura):**
- Sufijo UPN `maswer.com` válido; `JPaschold`/`Jan.Paschold` libres.
- Cuenta real tras el buzón: sam `MGeisz`, no "Michael.Geisz" (login ≠ correo).
- Estado: `Enabled=True`, sin grupos privilegiados; con grupos de usuario normales.

**Ejecución en AD on-prem (con backup previo y rollback preparado):**
- Renombrado de identidad: `MGeisz`→`JPaschold`, UPN `JPaschold@maswer.com`, nombre
  "Jan-Lukas Paschold".
- Direcciones: principal `Jan.Paschold@maswer.com`; **`michael.geisz@maswer.com`
  conservada como alias** (continuidad de correo).
- **Contraseña sin cambios** (decisión del técnico: Jan ya la usa).
- Sin reset de MFA (pendiente de decidir).

**Recuperación del sync:** reinicio del servicio ADSync en `MEUAZAC011` y ciclo Delta.

---

## 4. Incidencias detectadas
1. **Cuenta de baja activa y compartida** (Michael → Jan) durante ~6 semanas.
2. **AAD Connect sin sincronizar** desde 14-jul 14:06 pese a `SyncCycleEnabled=True`,
   `StagingMode=False`, servicio `Running` — scheduler congelado.
3. **Consola sin elevar** en la fase de validación devolvía atributos en blanco
   (`Enabled`, `memberOf`…) → llevó a una conclusión errónea temporal ("sin grupos").
   Se corrigió al usar consola elevada.
4. **Alerta Defender** por el reinicio del servicio (benigna, pero requiere atribución).
5. **Incidencia ajena:** error de writeback `permission-issue` en `CN=Oliver Orth`
   (otro usuario), visible en el Export a `intern.maswer.com`.

---

## 5. Causa raíz
- **Proceso de baja inexistente/incompleto:** no se deshabilitó a Michael al irse, y se
  entregó su cuenta a Jan como atajo. Todo lo demás deriva de ahí.
- **Falta de monitorización del sync:** un scheduler parado 18 h pasó inadvertido hasta
  que un cambio no propagó. Probable apagado nocturno de la VM `MEUAZAC011` sin reanudar.
- **Falta de aviso previo a seguridad** ante mantenimiento en servidor de identidad.

---

## 6. Estado actual / pendientes
- [x] Delta sync completado y **M365 muestra a Jan-Lukas Paschold** con principal
      `Jan.Paschold@maswer.com` y `michael.geisz@maswer.com` como alias. **Verificado.**
- [x] **MFA reseteado** ("Requerir volver a registrar la autenticación multifactor" →
      borra Authenticator SM-A226B y SM-X210 + Revoke sessions). Jan re-registra su propio
      Authenticator en el primer login (policy lo permite: Authenticator y TAP habilitados).
- [x] **Vincenzo notificado:** Jan entra con `JPaschold@maswer.com` + su contraseña, en red;
      correo con continuidad y 2FA reseteado según lo pedido.
- [ ] **(Externo) Resolver la alerta Defender como benigna** con conet.de / Kevin Putz
      (correo redactado, pendiente de enviar).
- [ ] **(Aparte)** Derivar el error de writeback de `Oliver Orth` (permisos) a quien
      administra el sync.

---

## 7. Qué se debe mejorar
1. **Proceso formal de baja (offboarding):** deshabilitar la cuenta el último día,
   resetear contraseña, revocar sesiones/MFA, y **nunca** entregar la identidad de un
   saliente a un nuevo empleado. Un checklist de baja habría evitado todo el caso.
2. **Revisar el resto de cuentas de bajas** aún habilitadas (búsqueda de cuentas sin
   login reciente en las OUs de usuarios).
3. **Monitorizar la salud de AAD Connect:** alerta si no hay sync en >60 min. Revisar si
   `MEUAZAC011` tiene **auto-shutdown** en Azure y, si es servidor de identidad crítico,
   quitarlo o coordinarlo.
4. **Coordinar mantenimiento de servidores de identidad con seguridad/conet.de:** un
   reinicio de ADSync **siempre** disparará la detección de Defender. Pre-avisar para que
   se cierre como actividad planificada, no como incidente.
5. **Operar siempre con consola elevada** en tareas de AD para evitar lecturas parciales
   que induzcan a error.
6. **Validar antes de ejecutar** (como se hizo aquí): evitó renombrar por un `sam`
   equivocado y confirmó prerequisitos. Mantener esta práctica como estándar.
7. **Documentar puntos de administración compartida** (qué gestiona conet.de vs IT
   interno) para saber a quién notificar cada tipo de alerta.

---

## Nota de proceso (autocrítica del soporte)
Al recomendar el reinicio de ADSync se indicó que era "seguro y rutinario" — cierto para
usuarios y datos, pero **no se advirtió que dispararía una alerta de seguridad** en un
servidor de identidad monitorizado. En adelante, todo mantenimiento sobre AAD Connect /
DCs debe incluir el aviso de "esto generará alerta de Defender" y la notificación previa.
