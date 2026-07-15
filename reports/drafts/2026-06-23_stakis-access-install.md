# Reporte del caso — Acceso e instalación de STAkis

- **Cliente:** Maswer AG (dominio **MASWER**, confirmado en la captura del UAC)
- **Solicitante:** Vincenzo Valle (Maswer) — confirmado
- **Usuario final:** Vincenzo Valle ("install it on my laptop") — portátil HP del dominio MASWER
- **Otros implicados:** **Oliver Orth ya no trabaja en Maswer** — no es vía de escalado ([[oliver-left-maswer-no-handover]]).
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks) — ahora responsable del IT de Maswer
- **Fecha de apertura:** 23-jun-2026
- **Estado actual:** ABIERTO — bloqueado en la elevación (UAC). Oliver descartado; pendiente determinar qué cuenta admin controla el propio técnico / vía conet.de

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Software / Aplicaciones (3rd-party — STAkis Profi / STAHLGRUBER) |
| Prioridad | P3 - Media (un usuario, sin impacto operativo — puede seguir con otras tareas) |
| Grupo | N1 - Soporte general |
| SLA inicial | Respuesta en 4 h · resolución objetivo 2 días hábiles |
| Escalado | No escalado. Oliver descartado (dejó Maswer). Vía: cuenta admin que controle el propio técnico o, si no la tiene, **conet.de**. |

---

## Solicitud recibida

> "Hello IT Team,
> Can you please give me access to stakis and install it on my laptop?
> Best regards!"

Petición de **acceso + instalación de STAkis** en el portátil del solicitante.

**Lagunas detectadas en intake (regla: no inventar información):**
1. **Nº de cliente STAHLGRUBER sin confirmar** — solicitante identificado (Vincenzo Valle), pero falta el nº de cliente al que va ligado el acceso a STAkis.
2. **"Acceso" e "instalar" son dos cosas distintas** — acceso = la licencia/credenciales STAHLGRUBER del cliente; instalar = el binario + permisos de administrador local para elevar.
3. **Reinstalación o alta nueva sin confirmar** — no se sabe si ya usaba STAkis en un equipo anterior (afecta a la reutilización de licencia).

---

## Diagnóstico inicial

- "stakis" = **STAkis Profi**, software de gestión de talleres y comercio de repuestos de STAHLGRUBER.
- **Binario ya disponible en la red de Maswer:** el ejecutable es `KWB_STAKIS_NET_CLIENT.EXE` y la captura muestra `Dateiursprung: Netzwerklaufwerk` (origen: unidad de red). Por tanto **no falta instalador ni licencia del proveedor** — el cliente STAkis ya está provisionado en el recurso de red.
- **Único bloqueo = elevación.** El UAC exige cuenta de administrador local porque el editor es desconocido (`Herausgeber: Unbekannt`). Al probar `MASWER\localadmin` falla con: *"Anmeldung fehlgeschlagen: Der Benutzer besitzt nicht den benötigten Anmeldetyp auf diesem Computer"* → **Windows error 1385 (`ERROR_LOGON_TYPE_NOT_GRANTED`)**. No es contraseña incorrecta: esa cuenta no es admin local en este equipo o tiene denegado el tipo de inicio de sesión por directiva.
- **Dependencia:** se necesita la cuenta admin local correcta de Maswer. **Oliver ya no está** y la transición fue incompleta ([[oliver-left-maswer-no-handover]]), así que la vía ya no es pedírsela a él: o la tiene el propio técnico, o se provisiona vía **conet.de** ([[conet-de-administers-maswer-infra]]).
- **Caso distinto** del 05-jun-2026 (reinstalación de STAkis para Joaquín): aquel es otro usuario. Este es de **Vincenzo Valle**. No fusionar; sirven de referencia mutua sobre la vía de instalación de STAkis.

---

## Pasos para el técnico

1. **Determinar qué cuenta admin controla el técnico** sobre el dominio MASWER (cuenta admin de dominio propia, Domain Admin, o acceso al AD). `MASWER\localadmin` ya descartada — error 1385.
2. **Si hay cuenta admin de dominio que funcione:** elevar el UAC con ella (normalmente sí está en el grupo Administradores local, donde `localadmin` falló) y ejecutar `KWB_STAKIS_NET_CLIENT.EXE` desde la unidad de red.
3. **Si NO hay cuenta admin disponible** (agujero de la transición): provisionarla vía **conet.de**, que administra la infra de Maswer — pedir una cuenta admin de dominio operativa o que añadan la cuenta del técnico al grupo Administradores local del equipo (vía GPO/Restricted Groups).
4. **Verificar** que STAkis arranca e inicia sesión, **confirmar a Vincenzo** y cerrar.

---

## Customer reply (EN — el ticket llegó en inglés)

```
Hi Vincenzo,

Got it — I'll get STAkis set up on your laptop.

To move this forward, could you send me three things?
1. Your STAHLGRUBER customer number (that's what your STAkis access is tied to).
2. Whether you already used STAkis on a previous computer.
3. A good time for me to connect to your laptop remotely to install it.

Once I have those I'll take it from there and keep you posted.

Best,
CoolNetworks Support
```

---

## ¿Escalar?

**No** — se gestiona en N1 (el propio técnico). Cuello de botella: la cuenta admin local de Maswer para elevar el UAC (el binario ya está en la unidad de red).
- **Oliver descartado** — dejó Maswer, transición incompleta. No contactarlo.
- Vía: cuenta admin que controle el propio técnico; si no la tiene, **conet.de** (administra la infra de Maswer).

---

## Estado actual y pendientes

**Estado:** ABIERTO — sesión piloto del 14-jul-2026 (`MDEHEFCLI016`, TeamViewer) **no completada**; método definido, bloqueo reducido a **una** dependencia.

> **Método a seguir:** [Runbook — Instalación estándar de STAkis](2026-07-14_maswer_stakis-runbook-instalacion.md), incluido el [Anexo para conceder admin local](2026-07-14_maswer_stakis-runbook-instalacion.md#anexo--conceder-admin-local-procedimiento-probado).

**Resultado del piloto (14-jul-2026):**
- **Vincenzo es usuario estándar** (el UAC pide usuario+contraseña, no Sí/No).
- STAkis = **app Visual FoxPro 9 de red** en `\\MDEKASCLI003\STAkis_Profi` (`S:`); aun así el `KWB_STAKIS_NET_CLIENT.EXE` **exige elevación** → sin camino per-user.
- QuickSupport sin elevar → el UAC sale en secure desktop y **"bota" la conexión** (pantalla negra). No se pudo elevar QuickSupport (Vincenzo no es admin). `localadmin` sigue dando 1385.
**HALLAZGO CLAVE (14-jul-2026, verificado contra el DC):** la cuenta del técnico **`MASWER\IT-Support-Germany` ES miembro de `adm2-Administrators`** (tier de workstations). Es decir, **el técnico ES admin de los equipos de usuario con su propia cuenta.** El fallo fue teclear la cuenta equivocada (`localadmin` → 1385); la cuenta propia nunca se probó.

**Acción pendiente (self-service, sin conet):** en la próxima sesión, en el UAC teclear **`MASWER\IT-Support-Germany` + la contraseña del técnico**. Si eleva → instalar STAkis y cerrar.
- *Caveat:* funciona si `MDEHEFCLI016` incluye `adm2-Administrators` en su Administradores local. Si diera "acceso denegado", ese equipo no honra el tier → conet añade el grupo por GPO (correo ya redactado → [recuperacion-accesos-post-oliver.md](../Implement/2026-06-23_maswer_recuperacion-accesos-post-oliver.md)).

**Próximos pasos (según el runbook):**
1. **Fase 0 del runbook** — determinar la cuenta admin estándar: buscar la contraseña de `MASWER\admin` (KeePass compartida) y probar que eleva en un endpoint ajeno; en paralelo, sacar los switches silenciosos del binario en la máquina propia del técnico.
2. **Fase 1** — con la cuenta admin estándar, elevar el UAC y ejecutar `KWB_STAKIS_NET_CLIENT.EXE` desde la unidad de red en la máquina de Vincenzo.
3. **Verificar** arranque/login de STAkis, confirmar a Vincenzo y cerrar.
4. **Si la Fase 0 no da ninguna cuenta operativa** → prerrequisito conet (correo/agenda ya redactados) antes de poder ejecutar. No es un atajo: sin admin local no hay elevación.

**Notas:**
- Instalador y licencia **no son el bloqueo**: el cliente STAkis ya está en la unidad de red de Maswer. El cuello de botella es puramente la cuenta admin local.
- `MASWER\localadmin` descartada: error 1385 (logon type no concedido en este equipo).
- **Oliver Orth ya no trabaja en Maswer** — no contactarlo. El email que se había redactado para él queda anulado.
- Sin tocar nada más en el equipo hasta tener una cuenta admin operativa.
