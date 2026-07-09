# Reporte del caso — Maswer / Acceso a carpetas P: (Maswer AG) y Q: (Maswer Deutschland GmbH)

- **Cliente:** Maswer (Maswer Alemania)
- **Solicitante:** Por confirmar desde el contacto del ticket
- **Nota:** Ticket **nuevo e independiente** (no es continuación de un ticket anterior). El ticket anterior relacionado sobre este mismo acceso se cierra como superado/duplicado y el trabajo se consolida aquí.
- **Usuarios finales:** El solicitante ("us") + Angelika Stangenberg (angelika.stangenberg@maswer.com)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
- **Fecha de apertura:** 09-jul-2026
- **Fecha de cierre:** —
- **Estado actual:** PENDIENTE (esperando respuesta del cliente) — Acceso a **P: (Maswer AG)** ya aplicado a Vincenzo Valle (VValle) y Angelika Stangenberg (AStangenberg): 31 grupos `MaswDEAG_*_RW`, excluyendo `_GL_` y `_ALL_` (este último excluido por precaución hasta confirmar que no re-otorga GL por otra vía). Falta confirmar con el cliente el alcance para **Q: (Maswer Deutschland GmbH)**, ver nota abajo.

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Cuentas y Acceso (permisos de carpeta) |
| Prioridad | P3 - Media (varios usuarios, impacto leve de negocio: no pueden compartir el contrato de Conet; sin caída de servicio) |
| Grupo | N1 (configuración de cliente); conet.de si la cuenta CoolNetworks no tiene delegada la gestión de los grupos |
| SLA inicial | Respuesta en 4 h · resolución en 2 días hábiles |
| Escalado | Pendiente — depende de si la cuenta CoolNetworks puede ejecutar `Add-ADGroupMember` sobre estos grupos; si no, va a conet.de |

---

## Solicitud recibida

> "Unfortunately, we have found that we still do not have access to all folders, which is why we are currently unable to send you the contract with Conet. We kindly ask you to grant us access to all folders under Maswer AG (P:) and Maswer Deutschland GmbH (Q:) that Mr. Oliver Orth has access to, so that we can work without any restrictions. Please for Angelika Stangenberg, too!"

Solicitud de acceso de lectura/escritura ("without any restrictions") a las carpetas de las unidades **P: (Maswer AG)** y **Q: (Maswer Deutschland GmbH)** para el solicitante y para Angelika Stangenberg, tomando como referencia el acceso de Oliver Orth. La lista exacta de cuentas y logins no está especificada en el mensaje inicial.

---

## Cronología

| Fecha | Evento |
|---|---|
| 09-jul | Ticket **nuevo e independiente** recibido: solicitud de acceso a las carpetas de P: (Maswer AG) y Q: (Maswer Deutschland GmbH) para el solicitante y Angelika Stangenberg, tomando como referencia el acceso de Oliver Orth. |
| 09-jul | Triage: Cuentas y Acceso, P3. La solicitud original pedía "el mismo acceso que Oliver Orth"; se decide **no replicar el acceso de Oliver** (tenía privilegios de admin/propietario que no corresponden a estos usuarios). A la espera de la **confirmación de Maurizio** sobre el alcance exacto. |
| 09-jul | **Maurizio confirma (corrige su indicación previa):** conceder los permisos **excepto la carpeta "GL" del directorio AG (P: Maswer AG)**. Pide una breve confirmación de vuelta. |
| 09-jul | Enviada confirmación breve a Maurizio: se concede el mismo acceso que Oliver salvo la carpeta GL de AG. |
| 09-jul | Ticket anterior relacionado marcado para **cierre** como superado/duplicado; el trabajo se consolida en este ticket. |
| 09-jul | Enviada actualización de estado a **Vincenzo** (solicitante, en espera): aprobado y en curso; acceso a P: y Q: salvo la carpeta GL de AG; se avisará cuando esté listo para probar (puede requerir cerrar y volver a iniciar sesión). |
| 09-jul | **Aplicado el lado P: (Maswer AG):** VValle y AStangenberg añadidos a los 31 grupos `MaswDEAG_*_RW`, excluyendo `_GL_` y, por precaución, `_ALL_` (pendiente confirmar en el ACL de la carpeta GL si `ALL_RW` la incluye; hasta entonces se deja fuera del lote). |
| 09-jul | Al revisar **Q: (Maswer Deutschland GmbH)** se detecta que, a diferencia de AG (carpetas por departamento), muchos grupos son **por proyecto/cliente final** (Daimler, Porsche, VW, Herchenbach, Kassel, Brita…). Dar acceso a "todos los `_RW`" implicaría acceso cruzado entre carpetas de distintos clientes de automoción, lo que puede chocar con la política **TISAX** de segregación por need-to-know. **Se pausa la aplicación en Q: y se pide confirmación al cliente** sobre si el acceso debe cubrir todos los proyectos o solo un subconjunto. |

---

## Trabajo realizado

### Diagnóstico técnico
- El acceso a carpetas en Maswer se controla por **grupos de seguridad de AD** con el patrón `<entidad>_<recurso>_<R|RW>`, **no** editando ACL por carpeta. Conceder = añadir al usuario al grupo correspondiente. Ver [[maswer-access-via-ad-security-groups]].
- Unidades objetivo: **P: = MaswerAG** (grupos `MaswDEAG_*`) y **Q: = MaswerGmbH**. Ver mapeo de unidades en [[maswer-ad-domain-infra]].
- "without any restrictions" → nivel escritura (`_RW`) salvo que el cliente pida solo lectura.

### Concesión de permisos
- **P: (Maswer AG) — APLICADO (09-jul).** VValle y AStangenberg añadidos a los grupos `MaswDEAG_*_RW` (31 grupos), excluyendo `_GL_` (indicación expresa de Maurizio) y, por precaución, `_ALL_` hasta confirmar su ACL real sobre GL. Cuenta CoolNetworks tenía permisos suficientes para `Add-ADGroupMember` — no fue necesario derivar a conet.de para este lote.
- **Q: (Maswer Deutschland GmbH) — EN PAUSA, pendiente de respuesta del cliente.** A diferencia de AG, los grupos de GmbH incluyen carpetas de **proyecto/cliente final** (Daimler, Porsche, VW, Herchenbach, Kassel, Brita, etc.), no solo departamentales. Conceder "todos los `_RW`" daría acceso cruzado entre clientes de automoción, lo cual puede no ser deseable bajo **TISAX** (segregación por need-to-know). Se solicita al cliente confirmar si el acceso a Q: debe ser total o limitado a un subconjunto de proyectos.
- **No se replica el acceso de Oliver Orth:** tenía privilegios de admin/propietario que no corresponden a estos usuarios. Se conceden los grupos de datos estándar de cada unidad. Oliver ya no trabaja en Maswer — no contactar ([[oliver-left-maswer-no-handover]]).
- ⚠️ **Excluir GL con un grant por grupos requiere cuidado:** si el acceso a GL proviene de un grupo amplio (p. ej. `MaswDEAG_ALL_RW`), añadir a ese grupo también daría GL. Queda pendiente verificar el ACL de la carpeta GL para confirmar si `ALL_RW` puede reincorporarse sin riesgo, o si debe quedar excluido permanentemente. Ver [[maswer-access-via-ad-security-groups]].
- Verificación pendiente: `Get-ADGroupMember <grupo>` (o `whoami /groups` en el usuario), logoff/login para refrescar el token, y confirmar que P: (ya aplicado) y Q: (pendiente) abren correctamente.

### Comunicación con cliente
- Enviada confirmación breve a Maurizio (inglés — cliente alemán, el técnico no habla alemán, ver [[user-does-not-speak-german-use-english]]): se concede acceso a las carpetas de P: y Q: **excepto la carpeta GL de AG**. Sin mencionar a Oliver.
- **09-jul, pendiente de alcance Q::** correo dirigido a **Vincenzo** (solicitante original del ticket), con copia a **Maurizio Carroccia** (quien valida/autoriza los accesos), pidiendo confirmar si Q: debe cubrir todos los proyectos/clientes o solo un subconjunto.

### Decisiones de triage
- Categoría: Cuentas y Acceso. Prioridad: P3. Grupo: N1 → conet.de según delegación.
- Ticket **nuevo e independiente**; el ticket anterior relacionado se cierra como superado/duplicado.

---

## Estado final

**Estado:** PENDIENTE (esperando respuesta del cliente) — Acceso a **P: (Maswer AG)** aplicado (09-jul) para VValle y AStangenberg, excluyendo GL y ALL. Acceso a **Q: (Maswer Deutschland GmbH)** en pausa: se ha pedido al cliente confirmar si el acceso debe cubrir todas las carpetas de proyecto/cliente o solo un subconjunto, por la posible implicación TISAX de dar acceso cruzado entre clientes de automoción. También queda pendiente verificar el ACL de la carpeta GL para decidir si `MaswDEAG_ALL_RW` puede añadirse sin riesgo. Además, **cerrar el ticket anterior** relacionado como superado/duplicado.

**Causa raíz del bloqueo:** los usuarios no estaban en los grupos de seguridad de MaswerAG (P:) y MaswerGmbH (Q:) con nivel escritura. Resuelto para P:; pendiente para Q: a la espera de confirmar alcance con el cliente.

**Lecciones / notas para casos similares:**
- **Conceder por grupos de seguridad de AD, no por ACL.** Añadir al usuario al grupo `<entidad>_<recurso>_<RW>` de cada unidad; no tocar la pestaña Seguridad. Ver [[maswer-access-via-ad-security-groups]].
- **No replicar el acceso de exempleados de IT.** Oliver tenía privilegios de admin/propietario; los usuarios finales reciben solo los grupos de datos estándar de cada unidad, con las exclusiones que indique el responsable (aquí, la carpeta GL de AG). Oliver ya no trabaja en Maswer — no contactar ([[oliver-left-maswer-no-handover]]).
- **Un ticket nuevo del cliente sobre un tema ya abierto** se consolida en uno solo: se trabaja el nuevo y se cierra el anterior como superado/duplicado, para no duplicar esfuerzo ni respuestas.
- **La infra la administra conet.de** (empresa externa, NO CoolNetworks). Si N1 no puede gestionar los grupos por falta de delegación, la concesión va a conet, no a N2 CoolNetworks ([[conet-de-administers-maswer-infra]]).
- **La delegación de gestión de grupos sigue sin confirmar** — es punto de la agenda pendiente con conet (¿puede la cuenta CoolNetworks gestionar los `Masw*_RW`?). Ver [[2026-07-03_maswer_agenda-reunion-conet]].
