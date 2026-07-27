# Reporte del caso — STAkis (STAHLGRUBER) en Calden / tres equipos

- **Cliente:** Maswer (oficina de Calden)
- **Solicitante:** Vincenzo Valle (contacto IT de Calden) — ver [[maswer-calden-contacts]]
- **Usuarios finales:** Joachim Priedemann (funciona parcialmente) y Jan Lukas (no funciona)
- **Equipo de referencia:** "central computer" de Calden — STAkis funciona correctamente
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha de apertura:** 21-jul-2026 (ticket "IT Issues in Calden")
- **Estado actual:** ABIERTO · en investigación (pendiente capturar el error exacto en cada equipo)

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Software / Aplicaciones (3rd-party — STAkis Profi / STAHLGRUBER) |
| Prioridad | P3 - Media (2 usuarios afectados, workaround = "central computer"; sin bloqueo de toda la oficina, sin señales de seguridad) |
| Grupo | N1 - Soporte general (first touch) → **caso con el proveedor STAHLGRUBER** tras descartar causas de nuestro lado. No es escalado interno N2/N3. |
| SLA inicial | Respuesta en 4 h · resolución objetivo 2 días hábiles |

---

## Solicitud recibida

> "The first issue concerns STarkis. It works correctly on the central computer, only partially on Joachim's computer, and not at all on Jan Lukas' computer. Could you please get in touch with both employees and help resolve these issues so they can work without interruptions?"

---

## Contexto

- **STarkis = STAkis Profi**, software de gestión de talleres y comercio de repuestos de **STAHLGRUBER** (3rd-party). Confirmado en casos previos (05-jun y 23-jun-2026).
- El cliente STAkis ya está provisionado en la **unidad de red** de Maswer (`KWB_STAKIS_NET_CLIENT.EXE`, origen "Netzwerklaufwerk") — ver caso 23-jun. Canales del proveedor: portal `kunden.stahlgruber.de`, soporte `stakis.support@stahlgruber.de`, hotline `0800 5782-547`.
- Asunto **recurrente en Calden**: ya figuraba como problema "antiguo y separado" en el ticket del 18-may (Joachim). Ver [[starkis-external-vendor-calden]].

---

## Diagnóstico inicial

- Patrón (OK en el "central computer", parcial en Joachim, nulo en Jan Lukas) = típico cliente-servidor: el cliente STAkis en la unidad de red conecta a una instancia/BD central. El gradiente entre equipos apunta a **diferencias por máquina**: versión del cliente, mapeo de la unidad de red, elevación/UAC, o permisos de acceso (en Maswer, por grupo de seguridad AD — ver [[maswer-access-via-ad-security-groups]]).
- Sin señales de seguridad. **Sin pérdida de datos.**
- La resolución de fondo depende del **proveedor (STAHLGRUBER)**; nuestro trabajo es descartar primero causas locales y aportar el error exacto de cada equipo.

---

## Pasos para el técnico

1. Confirmar cómo arranca STAkis en cada cliente (unidad de red mapeada y a qué instancia/BD central conecta).
2. **Jan Lukas** (falla del todo): contactar directamente y capturar el error exacto al abrir; verificar instalación, alcance a la instancia central, versión del cliente y pertenencia al grupo de seguridad AD frente a un usuario que sí funciona.
3. **Joachim** (parcial): identificar qué funciones fallan; comparar versión/permisos contra el "central computer". Joachim no es técnico → vía Vincenzo (sin agendar sesión hasta confirmar qué ocurre).
4. Cotejar ambos equipos contra el "central computer" (único que funciona).
5. Con errores + versiones documentados, abrir caso con **soporte STAkis (STAHLGRUBER)** en **inglés** (el técnico no habla alemán — ver [[user-does-not-speak-german-use-english]]).

---

## Customer reply (EN — el ticket llegó en inglés)

Se envió **un único acuse combinado** a Vincenzo cubriendo las dos incidencias del ticket. Parte relativa a STAkis:

```
Hi Vincenzo,

Thanks for the message. We're already looking into both issues and we'll contact
each person directly.

STarkis: this is run by an external provider, so we'll open a support case with
them to get it working on Joachim's and Jan Lukas' PCs. We'll reach Jan Lukas
directly to see the exact error on his machine, and we'll look into Joachim's side
as well.

[...]

We'll come back to you once we've had a look.

Best,
CoolNetworks Support
```

---

## Propuesta de solución

El patrón (OK en el "central computer", parcial en Joachim, nulo en Jan Lukas) con un cliente que corre desde la **unidad de red** (`KWB_STAKIS_NET_CLIENT.EXE`, "Netzwerklaufwerk") apunta a que la diferencia es **por máquina/usuario**, no del software en sí. En Maswer tanto el acceso al cliente como el mapeo de esa unidad se gobiernan por **grupo de seguridad AD** (mapeo por GPO `Laufwerk-*`, User Configuration — ver [[maswer-ad-domain-infra]] y [[maswer-access-via-ad-security-groups]]). Por eso la mayor parte se resuelve **del lado servidor**, sin depender de los usuarios.

### Hipótesis de causa raíz (ordenadas por probabilidad)
1. **Acceso/mapeo de la unidad de red por grupo AD incompleto.** Jan Lukas (nulo) probablemente no está en el grupo que le mapea la unidad de STAkis y/o da acceso al cliente. Joachim (parcial) sí abre el cliente pero le falta un grupo/permiso para ciertos módulos o para la BD central.
2. **Elevación / UAC.** STAkis puede exigir permisos locales al arrancar o escribir su config. Precedente directo: el caso del 23-jun bloqueó en `MASWER\localadmin` **error 1385**. Sin admin local en las máquinas de usuario (sin traspaso de Oliver — ver [[oliver-left-maswer-no-handover]]), esto lo tiene que conceder [[conet-de-administers-maswer-infra]].
3. **Versión del cliente distinta** a la del "central computer".

### Plan de resolución (lado servidor primero)
1. Identificar **qué usuario y equipo** es el "central computer" que funciona, y sacar su membresía de grupos AD + qué grupo `Masw*` le mapea la unidad de STAkis (DC `MDERZADC003`, dominio `intern.maswer.com`).
2. Comparar con `Get-ADPrincipalGroupMembership` la membresía de **Jan Lukas** y **Joachim** contra ese usuario de referencia. Los grupos que falten → **añadir al usuario al grupo** (no tocar ACLs). Si no tengo permiso para gestionar el grupo, solicitarlo a conet.de (Kevin Pütz-Kurth).
3. Confirmar que la **GPO `Laufwerk-*`** mapea la unidad de STAkis en las cuentas de Calden (filtrado por ese grupo).
4. Si el cliente arranca pero pide **elevación (error 1385)** → gestionar admin local de esas máquinas vía conet.de (avisar que puede disparar la alerta de Defender ya conocida no aplica aquí; es UAC local).
5. Descartado lo anterior y con **errores + versiones documentados por máquina**, abrir caso con **STAHLGRUBER** en inglés (`stakis.support@stahlgruber.de` · hotline `0800 5782-547`).

### Acciones puntuales con usuarios (mínimas, solo para evidencia)
- **Jan Lukas** (contacto directo): captura del **error exacto** al abrir STAkis + versión del cliente que aparece.
- **Joachim** (vía Vincenzo): **qué funciones** concretas fallan. No agendar sesión guiada hasta tener el error; casi todo se compara del lado servidor.

### Resultado esperado
La mayoría de los casos de este tipo se cierran en el paso 2–3 (alta en el grupo AD correcto) sin intervención del proveedor. El caso con STAHLGRUBER queda como plan B solo si, con acceso y versión correctos, el cliente sigue fallando contra la instancia/BD central.

---

## ¿Escalar?

**No a N2/N3.** Es coordinación con un **proveedor externo (STAHLGRUBER)** tras las comprobaciones de nuestro lado. Escalar a N2 Systems solo si se confirma que el bloqueo es de infraestructura Maswer (unidad de red, permisos AD, elevación/UAC).

---

## Estado actual y pendientes

**Estado:** ABIERTO · con propuesta de solución (ver sección "Propuesta de solución") · pendiente de ejecución.

**Próximos pasos (según el plan de resolución):**
1. Sacar la membresía de grupos AD del usuario del "central computer" (referencia) en `MDERZADC003`.
2. Comparar Jan Lukas y Joachim contra esa referencia (`Get-ADPrincipalGroupMembership`) y añadir a los grupos `Masw*` que falten; si no puedo gestionarlos, pedir a conet.de.
3. Verificar mapeo de la unidad de STAkis por GPO `Laufwerk-*` en las cuentas de Calden.
4. En paralelo, pedir a Jan Lukas (directo) el error exacto + versión, y a Joachim (vía Vincenzo) qué funciones fallan.
5. Si tras acceso/versión correctos sigue fallando → abrir caso con STAHLGRUBER en inglés.

**Notas:**
- Sin tocar los equipos más allá de la captura de errores.
- Sin pérdida de datos ni incidente de seguridad.
- Contactos de la sede en [[maswer-calden-contacts]]: Jan Lukas directo; Joachim vía Vincenzo.
