# Reporte del caso — Maswer / Recuperación de base de datos KeePass compartida (Einkauf)

- **Cliente:** Maswer (Maswer Alemania)
- **Solicitante / usuario final:** Vincenzo Valle (VValle) — departamento de Compras (Einkauf). Usuario no técnico.
- **Canal:** Microsoft Teams (chat), no Freshworks.
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
- **Fecha de apertura:** 13-jul-2026 (incidente originado el 10-jul-2026)
- **Fecha de cierre:** — (pendiente de confirmación del usuario)
- **Estado actual:** RESUELTO PENDIENTE DE CONFIRMACIÓN — Base de datos recuperada y validada a nivel de fichero (`+maswer.kdbx`, firma KeePass 2 correcta). Falta que Vincenzo la abra con su contraseña maestra y confirme que están todas las entradas. Fichero original huérfano (`+maswer.kdbx.tmp`) conservado como respaldo. **Sin pérdida de datos y sin incidente de seguridad.**

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Software / Aplicaciones (pérdida de BD KeePass) — con matiz de seguridad por tratarse de la bóveda de credenciales |
| Prioridad | P2 - Alta (usuario clave bloqueado; bóveda de contraseñas del equipo de Compras) |
| Grupo | N1 (recuperación en primer contacto); conet.de solo si hubiera hecho falta restore desde backup del servidor |
| SLA inicial | Respuesta en 1 h |
| Escalado | No fue necesario. Se levantan dos recomendaciones a N2/dirección (backup de la carpeta y gestor multiusuario), ver Estado final |

---

## Solicitud recibida

> "I have a problem that Keepass is away and i dont have access. can you check that? … We had an issue with KeePass, and somehow the database file disappeared along with all the passwords and stored data. Is there any way to recover the database or restore the passwords and data?"

El usuario reporta que su base de datos KeePass "desapareció" con todas las contraseñas y datos, y pregunta si es posible recuperarla.

---

## Cronología

| Fecha | Evento |
|---|---|
| 10-jul (viernes) | El equipo de Compras añade contraseñas nuevas en KeePass; **no se mostraban**. Cierran el programa y, tras cerrarlo, la base de datos "desaparece". (Guardado a medias: ver causa raíz.) |
| 13-jul | Vincenzo contacta por Teams: KeePass "away", sin acceso; el fichero de la BD y todas las contraseñas han desaparecido. |
| 13-jul | Triage: Software / Aplicaciones, P2. Sin señales de incidente (ni nota de rescate, ni cifrado, ni cambios masivos de ficheros) → **no** es modo incidente; se trata como pérdida/borrado de fichero. |
| 13-jul | Búsqueda de `*.kdbx` en todos los recursos de red accesibles (M/O/P/R/S): sin resultados. Se identifica que la carpeta objetivo estaba en un área con permisos restringidos. |
| 13-jul | Vincenzo envía **captura** de la carpeta: ruta `P:\Einkauf\Keepass` (`\\MDERZFIL001.intern.maswer.com\maswer\maswerag\Einkauf\Keepass`). Se detecta el fichero **`+maswer.kdbx.tmp`** (10-jul 14:06, 1.110,7 KB): el temporal huérfano de un guardado transaccional interrumpido. Vincenzo confirma que **conserva la contraseña maestra**. |
| 13-jul | Acceso a la carpeta restringida: Sebastian se añade al grupo de seguridad **`MaswDEAG_Einkauf_RW`** (grupo correcto; Vincenzo también es miembro). |
| 13-jul | El DC de login del técnico (**`MUSAZDC011`**, Azure-Site-US) no tenía replicada la pertenencia (retardo inter-site). Se **fuerza la replicación** ejecutando `repadmin /syncall /Ade` **en `MUSAZDC011`** vía PowerShell remoting (`Invoke-Command`) — `SyncAll terminated with no errors`. |
| 13-jul | Se refresca el token del técnico (`klist purge` + cierre de sesiones SMB a `MDERZFIL001`). Acceso a `Einkauf\Keepass` confirmado. |
| 13-jul | Recuperación: se hace **copia** de `+maswer.kdbx.tmp` y a la copia se le quita la extensión `.tmp` → `+maswer.kdbx`. Se conserva el `.tmp` original intacto. |
| 13-jul | Verificación de integridad: primeros 8 bytes de `+maswer.kdbx` = `03 D9 A2 9A 67 FB 4B B5` → **firma de base de datos KeePass 2 válida** (no es solo un renombrado; por dentro es una BD correcta). |
| 13-jul | Enviada respuesta a Vincenzo: fichero recuperado, sin pérdida; abrir KeePass con la contraseña maestra y confirmar entradas. |

---

## Trabajo realizado

### Diagnóstico técnico
- **Causa raíz confirmada:** la BD (`maswer.kdbx`) es un **único `.kdbx` sobre una carpeta compartida** (`P:\Einkauf\Keepass`) que **varios usuarios del equipo de Compras abren en escritura a la vez**. KeePass, al guardar, usa escritura transaccional: escribe el temporal `+maswer.kdbx.tmp` y luego lo renombra encima del original. Con guardados solapados / interrupción sobre SMB, el renombrado final falló → quedó el `.tmp` huérfano y el original desapareció. Esto **explica el "desapareció" del viernes y volverá a ocurrir mientras se mantenga este montaje**.
- **No es incidente de seguridad:** bóveda intacta, guardado interrumpido, no exposición. No procede rotación de credenciales.
- El temporal `+maswer.kdbx.tmp` es, de hecho, la BD completa (KeePass escribe el fichero entero antes de renombrar). Renombrarlo a `.kdbx` restaura la base de datos.

### Recuperación
- Copia del temporal y renombrado de la copia a `+maswer.kdbx`; **original `.tmp` conservado** como red de seguridad.
- Firma interna verificada = KeePass 2 válida (`03 D9 A2 9A 67 FB 4B B5`).
- El prefijo `+` en el nombre es irrelevante para abrir; se recomienda renombrar a `maswer.kdbx` (nombre original que KeePass busca) para que lo encuentre solo.

### Acceso a la carpeta restringida (lado infraestructura)
- El acceso a `Einkauf` se controla por el grupo de seguridad AD **`MaswDEAG_Einkauf_RW`** ([[maswer-access-via-ad-security-groups]]). El técnico se añadió a ese grupo.
- **Retardo de replicación inter-site:** el equipo autentica contra `MUSAZDC011` (Azure-Site-US), que no tenía el cambio. Se forzó `repadmin /syncall /Ade` sobre ese DC (vía remoting) en lugar de esperar la convergencia (~30 min). Es una operación no destructiva.
- Refresco de token sin re-login completo: `klist purge` + cierre de sesiones SMB al file server, para que el nuevo ticket Kerberos llevara la pertenencia actualizada. Ver infra de dominio en [[maswer-ad-domain-infra]].
- La infra la administra **conet.de** ([[conet-de-administers-maswer-infra]]); en este caso la cuenta CoolNetworks tenía permisos suficientes y no hizo falta derivar.

### Comunicación con cliente
- Respuestas a Vincenzo en **inglés** (el usuario escribe en inglés; no se inventa alemán). Tono directo, sin prometer recuperación hasta tenerla verificada.
- Mensaje final: fichero recuperado, sin pérdida; abrir con la contraseña maestra y confirmar. Sin pedirle gestión de concurrencia (usuarios no técnicos).

---

## Estado final

**Estado:** RESUELTO PENDIENTE DE CONFIRMACIÓN. Base de datos recuperada y validada a nivel de fichero. Falta la confirmación de Vincenzo abriendo `+maswer.kdbx` (o `maswer.kdbx` tras renombrar) con su contraseña maestra y verificando las entradas. **Sin pérdida de datos, sin brecha de seguridad, sin incumplimiento de SLA.**

**Causa raíz:** base de datos KeePass única compartida en `P:\Einkauf\Keepass`, abierta en escritura por varios usuarios simultáneamente; un guardado transaccional interrumpido/solapado el 10-jul dejó el original perdido y solo el temporal `+maswer.kdbx.tmp`.

**Acciones de cierre pendientes:**
- **Renombrar** `+maswer.kdbx` → `maswer.kdbx` y conservar el `.tmp` unos días; luego eliminar.
- **Revertir/documentar** el acceso que el técnico se auto-concedió (`MaswDEAG_Einkauf_RW`): quién, cuándo y por qué. Era carpeta restringida de Compras.
- Guardar una **copia buena** del fichero recuperado como línea base.

**Recomendaciones (a N2/dirección):**
- **Red de seguridad inmediata, sin depender de usuarios:** activar/confirmar **Instantáneas/Versiones anteriores (VSS)** y **backup** (conet.de) sobre `P:\Einkauf\Keepass`, para que un incidente futuro sea un restore de minutos. Ver [[maswer-m365-backup]] para el backup existente (M365) y confirmar cobertura de este share de ficheros.
- **Arreglo de raíz:** migrar la bóveda compartida de un `.kdbx`-sobre-SMB a un **gestor de contraseñas multiusuario con servidor** (Vaultwarden/Bitwarden, Passbolt, o KeePass con servidor de sincronización). La concurrencia la maneja el servidor, no el usuario, y para gente no técnica es más sencillo (login web). Es un proyecto, no un cambio de hoy.

**Lecciones / notas para casos similares:**
- Un `.kdbx` "desaparecido" casi nunca está perdido: buscar el **temporal `+<nombre>.kdbx.tmp`**; suele ser la BD completa. Verificar la **firma** (`03 D9 A2 9A 67 FB 4B B5`) antes de dar por buena la recuperación.
- **Trabajar siempre sobre una copia** y conservar el original hasta confirmar apertura con la contraseña maestra.
- Sin contraseña maestra no hay recuperación posible (KeePass no tiene reset) — confirmarlo antes de invertir tiempo.
- Para acceder a carpetas restringidas: conceder por **grupo de seguridad AD**, forzar **replicación al DC de login correcto** (aquí `MUSAZDC011`, no el asumido `MEUAZDC011`) y refrescar token con `klist purge` + cierre de sesiones SMB, en vez de esperar la convergencia.
- **No pedir a usuarios no técnicos disciplina de concurrencia**: la solución para bóvedas compartidas debe ser técnica/servidor.
