# Agenda — Reunión con conet.de (Kevin Pütz-Kurth)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 03-jul-2026
**Contacto conet:** Kevin Pütz-Kurth — `KPuetz-Kurth@conet.de`
**Objetivo de la reunión:** dejar de resolver caso a caso y **entender la infra de una vez** — accesos, cuentas y servidores — para poder operar de forma autónoma.

> **Tono:** describir el bloqueo y **preguntar cómo lo tienen pensado**, NO llegar prescribiendo cómo configurar su AD. Conet es el dueño de la infra; los temas de seguridad se plantean para que ellos valoren.
> Idioma de la reunión/correo: **inglés** (no manejo alemán).

---

## 1. Elevación / admin en los equipos — BLOQUEO DIARIO (lo más urgente)
*Ref: `2026-06-23_maswer_recuperacion-accesos-post-oliver.md`*

- **¿Cómo está pensado que IT eleve/instale software en las máquinas de los usuarios?** ¿Hay una cuenta admin de dominio que debería usar y no me pasaron en la transición (¿`MASWER\admin`?), o hay que configurarme el acceso?
- `MASWER\localadmin` da **error 1385** (ni siquiera es admin local ahí) → ¿es la cuenta equivocada?
- No hay **GPO de Grupos restringidos** que reparta admin local a la flota, y los equipos están en `CN=Computers` (no en una OU gestionada). ¿Enlazan una GPO a nivel dominio o mueven los equipos a una OU de Workstations?
- **Impacto:** con esto se desbloquean **STAkis y Chrome**, parados ahora mismo.

## 2. Acceso remoto — probar y estandarizar TeamViewer
*Ref: memoria `remote-access-teamviewer-fails-fallback-anydesk`*

- ¿Hay una **licencia oficial de TeamViewer** (u otra herramienta) que deba usar? Hoy uso TeamViewer pero **a veces corta** (probable detección de "uso comercial" en versión gratuita) y acabo pidiendo **AnyDesk** ticket a ticket.
- **Probar en vivo** que TeamViewer conecta bien contra un equipo de Maswer.
- Objetivo: **estandarizar UNA herramienta licenciada con acceso desatendido (unattended)** desplegada igual en toda la flota. El despliegue masivo (GPO/Intune) pasa por conet → **encadenarlo con la petición de admin del punto 1**.

## 3. Jerarquía de cuentas privilegiadas
*Ref: `recuperacion-accesos-post-oliver`, memoria `maswer-ad-domain-infra`*

- Pedir un **overview de las cuentas privilegiadas**: usuario vs admin de dominio (`MASWER\admin`) vs admin local (`localadmin`) vs cuentas de servicio. Cuál usar para cada cosa y quién las tiene.
- ¿Cómo encaja el **entorno híbrido Entra/Azure** (grupos `MFA-MASWER`, `AzureFiles-Administrators`) con las cuentas on-prem?
- ¿Puedo gestionar yo los grupos de acceso `Masw*_RW` (`Add-ADGroupMember`) o necesito que me deleguen ese control?

## 4. Qué hay en cada servidor + frontera de responsabilidades
*Ref: `2026-05-31_maswer_monthly-server-updates.md` (confirmado con inventario Defender/Sophos, 9 servidores)*

| Host | IP | Rol | Criticidad |
|---|---|---|---|
| mderzadc003 | 192.168.0.10 | Controlador de dominio | High |
| mderzadc004 | 192.168.0.9 | Controlador de dominio | High |
| meuazdc011 | 172.30.1.8 | Controlador de dominio | High |
| musazdc011 | 172.20.1.4 | Controlador de dominio | High |
| meuazpta011 | 172.30.1.9 | Servidor `pta` — **¿qué es?** | High |
| meuazpta012 | 172.30.1.10 | Servidor `pta` — **¿qué es?** | High |
| meuazac011 | 172.30.1.7 | Servidor `ac` — **¿qué rol?** | High |
| mderzfil001 | 192.168.0.13 | Servidor de archivos (QM/SACL) | **Very high** |
| meuazex001 | 172.30.1.11 | Exchange — **sin acceso** | **Very high** |

- ¿Qué son exactamente los servidores **`pta`** y **`ac`**?
- **Acceso al Exchange `meuazex001`** — quedó sin poder verificar el parcheo mensual; necesito acceso para incluirlo en la rutina.
- ¿Hay **más servidores o servicios** (backup, Sophos, SIEM, VMs) fuera de esta lista?
- **¿Quién administra qué a nivel servidor: conet vs CoolNetworks?** Marcar la frontera de una vez.

## 5. Seguridad post-Oliver (plantear como observación, no exigencia)
*Ref: `recuperacion-accesos-post-oliver`*

- `localadmin` parece **cuenta compartida con la misma contraseña en toda la flota** → ¿conviene rotarla? Valorar **LAPS** (contraseña única por máquina).
- Offboarding de Oliver: **rotar/revocar** admin de dominio y cuentas de servicio que él conocía. Sugerir **deshabilitar antes que borrar**, con periodo de gracia (por si hay servicios corriendo bajo esas cuentas).

## 6. File server — auditoría de borrados y backup (para auditoría ISO 27001/ENS)
*Ref: `2026-07-02_runbook-auditoria-borrado-sacl.md`, caso `2026-06-29_recuperacion-intaudit-es`*

- La carpeta `QM` (ISO 9001/14001) en `mderzfil001` tiene la **SACL de auditoría vacía** → no se sabe quién borra. ¿La aplican ustedes o me dan acceso admin al servidor (`SeSecurityPrivilege`) para hacerlo yo?
- **Log de Seguridad rota en ~6 días** (20 MB). Ampliarlo (~1 GB) y/o reenviar a un colector WEF/SIEM.
- Confirmar que la política de auditoría "Sistema de archivos" queda **permanente por GPO**.
- Confirmar **frecuencia y retención de las shadow copies (VSS)**.
- ¿Hay **backup "de verdad" del file server** (no solo VSS) con **restauración probada**? (evidencia estrella de la auditoría).

## 7. Backup de Microsoft 365 (Hornetsecurity/Altaro)
*Ref: `2026-07-01_backup-m365-hornetsecurity-hallazgos.md`*

- ¿**Operan ustedes la consola de Hornetsecurity 365 Total Backup** (`eu-m365.backup.hornetsecurity.com`)? Necesito acceso o un informe: **usuarios protegidos, última copia OK, retención y una restauración de prueba**.
- ¿El alcance cubre a **todos** los usuarios o solo algunos?
- ¿Saben qué es la app **"BackApps Respaldos"** que también aparece en el tenant?

## 8. Permisos de carpetas protegidas (HR)
*Ref: `2026-06-11_resumen-ejecutivo-CEO.md`*

- La carpeta **HR** está especialmente protegida y su control final lo tienen ustedes. Nuestra cuenta no puede verificar permisos a nivel servidor. ¿Pueden **conceder a la cuenta de CoolNetworks el acceso para revisar/verificar**, o pasarnos un informe de quién accede a HR?

---

## Cierre de la reunión
- [ ] Acordar **cómo elevo/instalo** en las máquinas (punto 1) y **probar en vivo** en un equipo ajeno.
- [ ] Acordar **herramienta de acceso remoto** estándar (punto 2).
- [ ] Recibir/prometer el **overview de cuentas privilegiadas** (punto 3).
- [ ] Aclarar **roles de servidores + frontera conet/CoolNetworks** (punto 4).
- [ ] Dejar por escrito quién hace qué en **SACL/logs, backups y accesos HR** (puntos 6–8).
