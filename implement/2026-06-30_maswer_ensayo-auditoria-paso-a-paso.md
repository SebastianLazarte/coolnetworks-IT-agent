# Maswer — Ensayo paso a paso para la auditoría en vivo (alcance remoto)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 30-jun-2026 · **Auditoría:** dentro de **2 días**
**Objetivo:** llegar con soltura. Saber **qué abrir, en qué orden, qué decir** y **qué NO mostrar**, sin que ningún proceso o pregunta me sorprenda.

> Acompaña al checklist `2026-06-30_maswer_preparacion-auditoria-remota.md`. Aquí está el **guion ensayado**.

---

## Reglas de oro para el directo
1. **Comparte solo la ventana concreta**, no la pantalla completa (evita correos, contraseñas, post-its, otras pestañas).
2. **Habla mientras navegas:** "voy a abrir X → aquí se ve Y → esto demuestra el control Z". El silencio mientras buscas pone nervioso al auditor (y a ti).
3. Si **no sabes algo o no es tuyo**: *"Eso lo gestiona [conet.de / Maswer in situ]; te muestro la parte que opero yo."* Nunca improvises ni inventes.
4. **Nunca toques nada** que el auditor no pida (no borres, no cambies reglas). Solo mostrar.
5. Si una muestra **sale mal** (un equipo offline, un fallo): no lo escondas. *"Buen punto, esto está en seguimiento en el ticket X."* Un fallo gestionado suma; uno oculto resta.
6. Ten **dos monitores**: uno comparte, otro con este guion + el checklist.
7. Para datos personales en pantalla (nombres de empleados): minimízalo, pero no pasa nada por mostrar un usuario real si el auditor lo pide.

---

## Plan de los 2 días

### HOY (día -2): preparar el terreno
- [ ] **Cerrar/anotar las 2 acciones correctivas críticas** (no llegarás a todo, pero sí a tener respuesta):
  - Revisión de accesos con fecha (aunque sea hacerla hoy y firmarla).
  - File server SACL/logs → tener el correo de escalado a conet.de a mano.
- [ ] **Localizar cada pantalla del checklist** y dejarlas en favoritos/pestañas.
- [ ] **Elegir tus casos reales** (rellenar la columna ticket-ejemplo): 1 alta, 1 baja, 1 cambio de firewall, 1 restauración, 1 alerta de SIEM, 1 vulnerabilidad cerrada con reescaneo.
- [ ] **Comprobar accesos:** que entras a TODAS las consolas (M365, Entra, ADUC/RDP, Sophos Central, ambos firewalls, Wazuh, backup, ticketing). Renueva MFA/contraseñas que caduquen ANTES.

### MAÑANA (día -1): ensayo en seco
- [ ] **Cronometra un ensayo completo** siguiendo la "Secuencia recomendada" de abajo, en voz alta, compartiendo pantalla contigo mismo (graba si puedes y reescúchate).
- [ ] Para cada uno de los **8 escenarios hipotéticos** di la respuesta en voz alta una vez.
- [ ] Detecta dónde tardas > 30 s en llegar a una pantalla → ponla en favoritos.
- [ ] Prepara el entorno técnico: webcam, micro, conexión estable, plan B (móvil con datos por si cae Internet — irónico en una auditoría).

### DÍA DE LA AUDITORÍA (día 0)
- [ ] 30 min antes: abre y **loguea TODAS las consolas** (deja las sesiones activas para no perder tiempo con MFA en vivo).
- [ ] Cierra Teams/Outlook/notificaciones (modo "no molestar").
- [ ] Ten a mano: este guion, el checklist, los nº de ticket de tus casos reales.
- [ ] Agua, y respira: el auditor **busca evidencia de proceso, no pillarte**. Si el proceso existe, se nota.

---

## Secuencia recomendada de la demo (orden lógico que cuenta una historia)

Va de "quién entra" → "con qué equipo" → "protegido cómo" → "qué vigilamos" → "y si falla, recuperamos". Esto demuestra madurez.

1. Identidades (Entra + AD)
2. Endpoints (Sophos Central)
3. Perímetro (Sophos Firewall)
4. Vigilancia (Wazuh + vulnerabilidades)
5. Recuperación (Backups)
6. Trazabilidad transversal (Ticketing)
7. Datos (SharePoint / ficheros)

---

## GUION DETALLADO — bloque por bloque

> Formato: **Abre así** (ruta de clics) · **Di esto** (frase) · **Si preguntan…** · **Trampa a evitar**.

### 1. Microsoft 365 / Entra ID
**Abre así (Entra):** `entra.microsoft.com` → *Identidad > Usuarios > Todos los usuarios*. Luego *Identidad > Roles y administradores > Administrador global*. Luego *Protección > Acceso condicional > Directivas*. Luego *Identidad > Supervisión > Registros de inicio de sesión*.
**Abre así (Centro de administración M365 — `admin.microsoft.com`, por si el auditor lo pide desde aquí):**
- **Altas/bajas:** 👤 *Usuarios > Usuarios activos* (crear/editar/gestionar). Un exempleado: 👤 *Usuarios > Usuarios eliminados* (o el usuario bloqueado en *Usuarios activos*).
- **Admins globales:** 🏷️ *Roles > Asignaciones de roles* — ⚠️ **la sección "Roles" solo aparece tras pulsar "Mostrar todo"** al fondo del menú izquierdo; tenlo localizado para no titubear en vivo.
- **Grupos de acceso:** 👥 *Teams y grupos > Grupos y equipos activos*.
- **Salto a portales:** 🌐 *Centros de administración* (Mostrar todo) → *Identidad* (Entra), *Seguridad* (Defender), *Exchange*, *SharePoint*, *Intune*.
**Di esto:** "Toda identidad pasa por Entra con MFA obligatorio vía Acceso Condicional. Los administradores globales son [N] y todos con MFA. Las bajas se desactivan el mismo día — te enseño una reciente. La gestión diaria de usuarios y roles la hago desde el Centro de administración de M365 y salto a Entra para el detalle de identidad."
**Si preguntan "un exempleado":** abre el usuario dado de baja → muestra *Cuenta bloqueada = Sí* + fecha + el ticket de baja. (En M365: 👤 *Usuarios > Usuarios eliminados* conserva el registro.)
**Si preguntan "usuarios sin MFA":** abre la directiva de Acceso Condicional que fuerza MFA a todos / o *Sign-in logs* filtrando por MFA.
**Trampa a evitar:** que aparezca un admin global de más o un invitado externo olvidado (👤 *Usuarios > Usuarios invitados*). **Revísalo HOY.** Y no te quedes buscando "Roles" en el menú de M365: recuerda que está **detrás de "Mostrar todo"**.

### 2. Active Directory
**Abre así (paso a paso, narrando cada uno):**
1. RDP a la consola → abre **ADUC** (`dsa.msc`).
2. **Grupos privilegiados:** ve a la OU/contenedor de grupos → abre *Domain Admins* y *Enterprise Admins* → pestaña *Miembros*. Enseña que la lista es **corta y nominal** (nada de cuentas genéricas ni de más).
3. **Cuentas de baja:** *Users* → menú *Ver > Filtro* (o *Buscar*) para listar **cuentas deshabilitadas** → abre una baja reciente → pestaña *Cuenta*: verás *"La cuenta está deshabilitada"* + a través del ticket, la fecha.
4. **Política de contraseñas:** `gpmc.msc` → *Default Domain Policy* (o la GPO de contraseñas) → *Configuración del equipo > Directivas > Configuración de Windows > Directivas de cuenta > Directiva de contraseñas* → enseña longitud mínima, complejidad, caducidad, historial y bloqueo.
5. **Acceso a carpetas (DACL = quién puede):** propiedades de la carpeta `QM` → *Seguridad* → verás el grupo `MaswES_QM_RW` (y *Avanzada* para ver el detalle de permisos heredados). Este es el control de **acceso**.
**Di esto:** "Los grupos privilegiados tienen miembros mínimos y nominales. Las bajas se deshabilitan el mismo día. El acceso a carpetas es **por grupo de seguridad, con mínimo privilegio** — ejemplo: la carpeta QM solo la ve el grupo MaswES_QM_RW."
**Si preguntan "¿cuándo revisaste estos accesos?":** muestra el **registro de revisión de accesos con fecha** (el que preparas hoy).
**Trampa a evitar:** cuentas inactivas sin deshabilitar; miembros de más en grupos privilegiados. **Revísalo HOY.**

#### 2a. Modelo de administración por niveles (tiering) — ⭐ tu punto fuerte, enséñalo
Maswer tiene la OU `Administratoren` segmentada en niveles, con un grupo de seguridad por nivel. **Ábrelo y nárralo** — demuestra madurez:

| Nivel (OU) | Grupo | Miembros actuales | Alcance |
|---|---|---|---|
| **adm0** — Tier 0 | `adm0-Administrators` | Alejandro Jasso, Oliver Orth, Conet Admin, localadmin | Dominio / DCs |
| **adm1** — Tier 1 | `adm1-Administrators` | Admin1_OOrth, Oliver Orth, Conet Admin | Servidores |
| **adm2** — Tier 2 | `adm2-Administrators` | Alejandro Jasso, Miguel Rubira Garcia, Oliver Orth | Puestos |

Grupos por rol adicionales: `AzureFiles-Administrators`, `Files-Administrators`, `MFA-Administrators`.

**Di esto:** *"La administración está segmentada por niveles: adm0 para dominio, adm1 para servidores, adm2 para puestos, cada uno con su grupo. Cada admin usa una cuenta dedicada según el nivel, nunca su cuenta de diario. El acceso privilegiado es nominal y mínimo."*

**Verifica HOY (antes del directo):**
- [ ] Que `adm1-Administrators` y `adm2-Administrators` **NO** son miembros de *Domain Admins* (si lo fueran, rompe el tiering — es lo primero que mira el auditor).
- [ ] Que cada persona tiene **cuenta dedicada por nivel** y no es la misma cuenta reutilizada entre Tier 0/1/2. Ojo a la **nomenclatura inconsistente** (`Admin1_OOrth` correcto vs `Oliver Orth` a secas) → ten claro cuál es cuál. Renombrar a patrón único = mejora post-auditoría, no la toques ahora.
- [ ] Que Alejandro Jasso, Oliver Orth y Miguel Rubira García son admins **actuales**.

#### 2c. Justificación de Domain Admins (rellena y llévala impresa)
Domain Admins hereda a los adm0 + varias cuentas de servicio. Ten una frase por miembro para no titubear:

| Miembro | Tipo | Justificación / acción |
|---|---|---|
| `adm0-Administrators` (grupo) | Grupo Tier 0 | Cuentas humanas de dominio (Alejandro Jasso, Oliver Orth) + Conet + localadmin. |
| `Administrator` | Built-in | Cuenta de emergencia, uso controlado, no de diario. |
| `conetadmin` / Conet Admin | Humana (conet.de) | Operador de la infraestructura; acceso contractual documentado. |
| `localadmin` | Genérica | ¿Uso concreto? Justificar o retirar. **Revisar HOY.** |
| `ADMadfs` | Servicio (AD FS) | 🔴 Cuenta de servicio en DA — mejora planificada: sacar de DA con privilegio mínimo (cambio con ventana + conet.de). |
| `SVC Kerberos…` | Servicio (AD FS/AADConnect) | 🔴 Ídem — mejora continua planificada. |
| `SVCAdfsProxy` | Servicio (AD FS) | 🔴 Ídem — mejora continua planificada. |
| `tplink` | ¿? | 🔴🔴 **Sin justificar.** Investigar hoy (creación, último logon, propósito). Si no se explica → **escalar a N2 Cybersecurity**, no exhibir. |

**Frase para el directo si abren Domain Admins:** *"Conviven admins humanos por nivel y algunas cuentas de servicio heredadas de AD FS/Azure AD Connect. Está identificado como mejora: separarlas de Domain Admins con privilegio mínimo, cambio planificado con conet.de. Cada miembro tiene justificación documentada."*

#### 2b. Cómo mostrar el "registro de archivos" (auditoría de accesos/borrados)
> Ojo: el auditor puede pedir dos cosas distintas y conviene no confundirlas.
> - **Permisos (DACL) = *quién puede* acceder** → eso es el paso 5 de arriba (*Seguridad* de la carpeta).
> - **Registro/auditoría (SACL + log) = *quién hizo qué* (accedió, borró, cambió permisos)** → es lo de aquí abajo.

**Cómo se muestra (donde SÍ está activado):**
1. **Que la auditoría esté habilitada por GPO:** `gpmc.msc` → GPO del file server → *Configuración del equipo > Directivas > Configuración de Windows > Configuración de seguridad > Configuración de directiva de auditoría avanzada > Acceso a objetos* → *Auditar el sistema de archivos = Correcto/Erróneo*.
2. **Que la carpeta tenga SACL:** propiedades de la carpeta → *Seguridad > Avanzada > pestaña Auditoría* → aquí se define **qué se registra** (p. ej. *Todos → Eliminar / Cambiar permisos*). Si esta pestaña está vacía, **no hay registro** de esa carpeta.
3. **Ver los eventos:** en el file server, *Visor de eventos* (`eventvwr.msc`) → *Registros de Windows > Seguridad* → *Filtrar registro actual* por Id. de evento:
   - **4663** — acceso a un objeto (incluye lectura/escritura/borrado efectivo)
   - **4660** — objeto eliminado
   - **4670** — cambio de permisos
   - **4656 / 4658** — apertura/cierre de identificador
   Enseña un evento y lee: **quién** (cuenta), **qué** (archivo/carpeta), **cuándo** y **qué acción**.

**⚠️ Realidad de Maswer (hallazgo conocido — NO lo abras tú por sorpresa):** en el file server que opera **conet.de**, la carpeta afectada **no tenía la SACL activada** y el **log de seguridad solo retiene unos días**. Si el auditor entra por aquí (borrados, retención, "enséñame quién borró X"):
- **No improvises ni lo escondas.** Ve directo a la **frase preparada del bloque 9** y enseña el informe + el correo de escalado a conet.de.
- Encuádralo como **mejora continua documentada**: corrección propuesta = activar SACL en la carpeta + ampliar la retención del log de seguridad y reenviarlo a un colector (Wazuh).
**Trampa a evitar:** intentar demostrar en vivo un registro de borrados en la carpeta del hallazgo (no lo hay todavía). Muestra el mecanismo donde SÍ funciona, y para el punto débil usa la frase preparada.

### 3. Sophos Central (AV/EDR)
**Abre así:** `central.sophos.com` → *Dashboard* (resumen de salud) → *Devices > Computers/Servers* (ordena por *Last activity*) → *Endpoint Protection > Policies* → *Alerts*.
**Di esto:** "Cobertura prácticamente total, todos reportando y con la política de protección + antiransomware aplicada. Las alertas se atienden — aquí el histórico."
**Si preguntan "este portátil de admin":** ábrelo → muestra *Protegido*, *Tamper protection*, cifrado/BitLocker, última actividad.
**Trampa a evitar:** un equipo *offline* desde hace semanas. Si lo hay, ten la explicación ("equipo retirado/en ticket X"). **Revisa la lista HOY.**

### 4. Sophos Firewall (Zaragoza y Abrera) — repite para los DOS
**Abre así:** consola de cada firewall → *Administration > Device access* (admins + MFA) → *Rules and policies > Firewall rules* → *VPN* (usuarios y sesiones activas) → *Protect > Intrusion prevention* → *Backup & firmware* (versión + backup de config) → *Log viewer* / audit log (cambios).
**Di esto:** "Acceso admin con MFA, firmware al día, IPS activo, VPN con MFA y con backup de configuración. Cada regla tiene un motivo y queda registrada."
**Si preguntan "2 reglas al azar":** ábrelas → explica *motivo, quién la pidió/aprobó (ticket), fecha, última revisión*. Si una regla es vieja y no sabes para qué es → **no la inventes**: "la reviso y documento como parte de la mejora continua".
**Trampa a evitar:** reglas *any-any*, VPN sin MFA, sin backup de config reciente. Comprueba el backup de config de AMBOS firewalls HOY.

### 5. Wazuh / Elastic (SIEM)
**Abre así:** dashboard de Wazuh → *Agents* (estado de conexión) → *Security events* / *Threat Hunting* → abre **una alerta concreta** que ya sepas que enlaza a un ticket.
**Di esto:** "Centralizamos eventos en Wazuh. Te enseño la trazabilidad completa de una alerta real."
**Demo estrella (ensáyala literal):** alerta → muestra el evento → "lo analizamos así" → abre el **ticket** asociado → "se actuó así" → cierre → lección aprendida.
**Trampa a evitar:** elegir en vivo una alerta que no tenga ticket detrás. **Elige tu alerta-ejemplo HOY** y verifica que la cadena está completa.

### 6. Herramienta de vulnerabilidades
**Abre así:** consola → último escaneo (fecha) → vulnerabilidades abiertas por criticidad → una **cerrada** con su reescaneo → excepciones/riesgo aceptado.
**Di esto:** "Escaneamos con periodicidad [X]. El ciclo es escaneo → ticket → corrección → reescaneo que confirma el cierre."
**Si preguntan "5 cerradas":** por cada una muestra el **reescaneo posterior** que confirma que ya no aparece. Sin reescaneo, no está cerrada.
**Trampa a evitar:** marcar cerradas sin reescaneo; críticas abiertas sin plan/responsable.

### 7. Copias de seguridad ⭐ (el momento más importante)
**Abre así:** consola de backup → trabajos (OK/fallidos) → retención y cifrado → copia externa/inmutable → histórico de restauraciones.
**Di esto:** "Copias con retención [X], cifradas, con copia externa/inmutable resistente a ransomware. Y lo importante: las probamos con restauraciones reales."
**Demo estrella:** enseña una **restauración real** del último año (o, si el auditor lo pide, restaura un fichero de prueba en vivo a una carpeta temporal). Apóyate en el caso documentado: recuperación de `IntAudit_ES` desde shadow copy.
**Si preguntan "un trabajo fallido":** muéstralo y cómo se reintentó/resolvió (ticket).
**Trampa a evitar:** vender shadow copies como si fueran el backup completo. Son un **complemento**; enseña el backup real con su restauración probada.

### 8. Ticketing (hilo conductor de TODO)
**Abre así:** tu herramienta de tickets → filtros por tipo (incidente / alta / baja / cambio firewall / permisos).
**Di esto:** "Todo deja rastro: solicitud → autorización → ejecución → validación → cierre. Cualquier cosa que te haya enseñado, aquí está su ticket."
**Trampa a evitar:** que un cambio que mostraste antes **no tenga** ticket. Por eso elegimos los casos-ejemplo con ticket desde HOY.

### 9. SharePoint / servidor de ficheros
**Abre así:** permisos de una carpeta crítica → grupos con acceso → enlaces externos/compartidos → registro de cambios.
**Di esto:** "Permisos por grupo, revisados periódicamente, sin compartición externa descontrolada."
**⚠️ Frase preparada para el hallazgo conocido del file server** (si el auditor entra por auditoría/borrados/retención de logs):
> *"En un incidente real detectamos que esa carpeta no tenía activada la auditoría de borrado (SACL) y que el log de seguridad del servidor solo retiene unos días. Lo documentamos, lo escalamos a conet.de —que opera ese servidor— y la corrección propuesta es activar la SACL y ampliar/reenviar los logs a un colector. Aquí está el informe y el correo de escalado."*
Esto convierte un punto débil en **mejora continua documentada** (lo que el auditor quiere ver).

---

## Los 8 escenarios hipotéticos — respuestas ensayadas

> El auditor los suelta de viva voz. Responde **narrando el proceso Y abriendo la pantalla** correspondiente. Practica cada uno una vez en voz alta mañana.

1. **"Se va un empleado hoy a las 17:00."** → "Abro el ticket de baja → en Entra desactivo la cuenta y revoco sesiones/MFA → la saco de grupos en AD → retengo/reasigno su OneDrive/correo → se gestiona la devolución del equipo → cierro el ticket." *(Abre Entra en un usuario de baja real.)*
2. **"Ransomware esta noche."** → "Sophos/Wazuh detecta y aísla → activo el plan de incidentes → restauro desde la copia **inmutable/offline** que el cifrado no alcanza → mido contra RTO/RPO." *(Abre la consola de backup mostrando la copia externa.)*
3. **"Roban un portátil de un admin."** → "El disco está cifrado con BitLocker, el dato no se expone → wipe remoto por Intune → baja en inventario y Sophos → roto credenciales si hace falta." *(Abre Intune/Sophos.)*
4. **"CVE crítico en el firewall Sophos."** → "Recibo el aviso → evalúo afectación → abro ticket → aplico parche/mitigación en el plazo de críticos → reescaneo para confirmar." *(Abre Backup&firmware del firewall.)*
5. **"Alguien pide acceso a una carpeta sensible."** → "Solicitud por ticket → autoriza el **propietario del dato** → ejecuto el cambio de grupo → valido → cierro." *(Abre el grupo MaswES_QM_RW + su ticket.)*
6. **"Inicio de sesión imposible en Entra."** → "Acceso Condicional / Identity Protection lo marca como riesgo → bloqueo o fuerzo reset → abro ticket." *(Abre Protección > Riesgo.)*
7. **"Enséñame un cambio controlado."** → cambio de firewall/servidor con solicitud, aprobación, ventana, rollback y registro. *(Abre el ticket de cambio + el log del firewall.)*
8. **"Cógeme un riesgo del análisis de riesgos."** → ej. "acceso indebido a SharePoint": riesgo identificado → control implantado (permisos por grupo + revisión) → **evidencia técnica** (la pantalla de permisos) → responsable → revisión periódica.

---

## Qué NO mostrar / qué NO decir
- ❌ No compartas pantalla completa con correo/contraseñas/otras pestañas a la vista.
- ❌ No abras ni toques configuraciones que no te pidan.
- ❌ No inventes una respuesta para quedar bien. "No lo sé, lo verifico" es válido y profesional.
- ❌ No asumas la culpa de lo que no operas tú (file server lo lleva conet.de; lo físico, Maswer in situ).
- ❌ No presentes el incidente del Excel como "brecha" sin que te pregunten; preséntalo como **caso de éxito de recuperación** y, si surge el ángulo de datos personales, encuádralo con calma.

---

## Mini-tarjeta del día (imprime esto)
**Orden:** Identidad → Endpoint → Firewall → SIEM/Vulns → Backup → Ticketing → Ficheros.
**Casos-ejemplo listos (rellena los nº):** alta #____ · baja #____ · cambio firewall #____ · restauración #____ · alerta SIEM #____ · vuln cerrada+reescaneo #____.
**Las 5 imbatibles:** MFA todos · Sophos cobertura total · Firewall+VPN MFA+backup config · Backup con restauración real · Vulns/incidentes con ticket y cierre.
**Frase comodín:** *"Eso lo opera [conet.de/Maswer in situ]; te muestro lo que gestiono yo."*

---

*Relacionado:* `2026-06-30_maswer_preparacion-auditoria-remota.md` · `2026-06-29_maswer_recuperacion-intaudit-es-iso14001.md` · `2026-06-23_maswer_recuperacion-accesos-post-oliver`
