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

## ¿Escalar?

**No a N2/N3.** Es coordinación con un **proveedor externo (STAHLGRUBER)** tras las comprobaciones de nuestro lado. Escalar a N2 Systems solo si se confirma que el bloqueo es de infraestructura Maswer (unidad de red, permisos AD, elevación/UAC).

---

## Estado actual y pendientes

**Estado:** ABIERTO · en investigación.

**Próximos pasos:**
1. Capturar el error exacto en el equipo de Jan Lukas (contacto directo).
2. Identificar qué funciones fallan en el de Joachim (vía Vincenzo).
3. Descartar causas locales (versión / unidad de red / permisos AD / elevación).
4. Abrir caso con STAHLGRUBER con la evidencia recopilada.

**Notas:**
- Sin tocar los equipos más allá de la captura de errores.
- Sin pérdida de datos ni incidente de seguridad.
- Contactos de la sede en [[maswer-calden-contacts]]: Jan Lukas directo; Joachim vía Vincenzo.
