# Reporte del caso — Acceso e instalación de STAkis

- **Cliente:** Maswer AG (dominio **MASWER**, confirmado en la captura del UAC)
- **Solicitante:** [a confirmar — ticket en inglés, sin firma]
- **Usuario final:** quien abre el ticket ("install it on my laptop") — portátil HP del dominio MASWER
- **Otros implicados:** Vincenzo Valle (contacto Maswer). **Oliver Orth ya no trabaja en Maswer** — no es vía de escalado ([[oliver-left-maswer-no-handover]]).
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
1. **Solicitante sin identificar** — el ticket llega en inglés y sin firma. No se conoce el usuario ni el nº de cliente STAHLGRUBER.
2. **"Acceso" e "instalar" son dos cosas distintas** — acceso = la licencia/credenciales STAHLGRUBER del cliente; instalar = el binario + permisos de administrador local para elevar.
3. **Reinstalación o alta nueva sin confirmar** — no se sabe si ya usaba STAkis en un equipo anterior (afecta a la reutilización de licencia).

---

## Diagnóstico inicial

- "stakis" = **STAkis Profi**, software de gestión de talleres y comercio de repuestos de STAHLGRUBER.
- **Binario ya disponible en la red de Maswer:** el ejecutable es `KWB_STAKIS_NET_CLIENT.EXE` y la captura muestra `Dateiursprung: Netzwerklaufwerk` (origen: unidad de red). Por tanto **no falta instalador ni licencia del proveedor** — el cliente STAkis ya está provisionado en el recurso de red.
- **Único bloqueo = elevación.** El UAC exige cuenta de administrador local porque el editor es desconocido (`Herausgeber: Unbekannt`). Al probar `MASWER\localadmin` falla con: *"Anmeldung fehlgeschlagen: Der Benutzer besitzt nicht den benötigten Anmeldetyp auf diesem Computer"* → **Windows error 1385 (`ERROR_LOGON_TYPE_NOT_GRANTED`)**. No es contraseña incorrecta: esa cuenta no es admin local en este equipo o tiene denegado el tipo de inicio de sesión por directiva.
- **Dependencia:** se necesita la cuenta admin local correcta de Maswer. **Oliver ya no está** y la transición fue incompleta ([[oliver-left-maswer-no-handover]]), así que la vía ya no es pedírsela a él: o la tiene el propio técnico, o se provisiona vía **conet.de** ([[conet-de-administers-maswer-infra]]).
- **Probable continuación** del caso 05-jun-2026 (reinstalación de STAkis para Joaquín). Verificar si es el mismo solicitante; si lo es, fusionar.

---

## Pasos para el técnico

1. **Determinar qué cuenta admin controla el técnico** sobre el dominio MASWER (cuenta admin de dominio propia, Domain Admin, o acceso al AD). `MASWER\localadmin` ya descartada — error 1385.
2. **Si hay cuenta admin de dominio que funcione:** elevar el UAC con ella (normalmente sí está en el grupo Administradores local, donde `localadmin` falló) y ejecutar `KWB_STAKIS_NET_CLIENT.EXE` desde la unidad de red.
3. **Si NO hay cuenta admin disponible** (agujero de la transición): provisionarla vía **conet.de**, que administra la infra de Maswer — pedir una cuenta admin de dominio operativa o que añadan la cuenta del técnico al grupo Administradores local del equipo (vía GPO/Restricted Groups).
4. **Verificar** que STAkis arranca e inicia sesión, **confirmar al usuario** y cerrar. Cotejar con el caso 05-jun (Joaquín): si es el mismo usuario, enlazar/fusionar.

---

## Customer reply (EN — el ticket llegó en inglés)

```
Hi [Name],

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

**Estado:** ABIERTO — bloqueado en la elevación (UAC). Oliver descartado como vía (dejó Maswer). Pendiente determinar el acceso admin del propio técnico.

**Próximos pasos:**
1. Confirmar qué cuenta con privilegios admin controla el técnico sobre el dominio MASWER.
2. Si tiene cuenta admin de dominio → elevar el UAC con ella y ejecutar `KWB_STAKIS_NET_CLIENT.EXE` desde la unidad de red.
3. Si no tiene ninguna (agujero de la transición) → solicitar a **conet.de** una cuenta admin operativa o que añadan la cuenta del técnico al grupo Administradores local del equipo.
4. **Verificar** arranque/login de STAkis, confirmar al usuario y cerrar.

**Notas:**
- Instalador y licencia **no son el bloqueo**: el cliente STAkis ya está en la unidad de red de Maswer. El cuello de botella es puramente la cuenta admin local.
- `MASWER\localadmin` descartada: error 1385 (logon type no concedido en este equipo).
- **Oliver Orth ya no trabaja en Maswer** — no contactarlo. El email que se había redactado para él queda anulado.
- Sin tocar nada más en el equipo hasta tener una cuenta admin operativa.
