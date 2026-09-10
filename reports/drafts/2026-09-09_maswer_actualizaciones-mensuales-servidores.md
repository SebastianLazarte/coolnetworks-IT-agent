# Reporte del caso — Maswer / Actualizaciones mensuales de servidores y VMs (ciclo sep-2026)

- **Cliente:** Maswer
- **Dominio:** intern.maswer.com
- **Técnico asignado:** Sebastian Lazarte Castellon (CoolNetworks)
- **Plataforma / hosting:** conet.de (Azure CSP + RZ FFM)
- **Fecha:** 09-sep-2026
- **Ventana de mantenimiento:** fin de mes (recurrente mensual)
- **Estado actual:** 🟡 en curso — atraso de MEUAZAC011 resuelto; el resto de la flota se parchea en la ventana de fin de mes

---

## Contexto

El parcheo mensual de SO/seguridad de la flota de servidores de Maswer es responsabilidad de
CoolNetworks desde el ciclo de **mayo-2026**. conet.de mantiene la plataforma por debajo
(dimensionado de discos, ampliación de VM, firewalls, alertas de Defender for Cloud).

El parcheo se ejecuta en una **ventana de mantenimiento a fin de mes**, así que a fecha de este
reporte la flota está a la espera de esa ventana; no es atraso.

La excepción de este ciclo es **MEUAZAC011**, que arrastraba dos CU acumulativas fallidas
(2026-07 KB5099538 y 2026-08 KB5120238, ambas `0x80246007`) por falta de espacio en el disco de
sistema. **Ya está resuelto**: liberado el espacio, la CU se instaló correctamente.

---

## Alcance — servidores y máquinas virtuales

### En alcance del parcheo mensual (Windows Server)

| # | Host | IP | Ubicación | OS | Rol | Criticidad | Estado del ciclo |
|---|---|---|---|---|---|---|---|
| 1 | MDERZADC003 | 192.168.0.10 | On-prem RZ FFM | Server 2022 | Controlador de dominio + DNS | Alta | 🗓️ Ventana fin de mes — reinicio escalonado |
| 2 | MDERZADC004 | 192.168.0.9 | On-prem RZ FFM | Server 2022 | Controlador de dominio + DNS | Alta | 🗓️ Ventana fin de mes — reinicio escalonado |
| 3 | MDERZFIL001 | 192.168.0.13 | On-prem RZ FFM | Server 2019 | Servidor de archivos (unidades M/O/P/R) | Muy alta | 🗓️ Ventana fin de mes |
| 4 | MEUAZDC011 | 172.30.1.8 | Azure West Europe | Server 2022 | Controlador de dominio + DNS | Alta | 🗓️ Ventana fin de mes — reinicio escalonado |
| 5 | MEUAZAC011 | 172.30.1.7 | Azure West Europe | Server 2019 | Entra / AAD Connect (sincronización) | Alta | ✅ CU aplicada tras liberar disco — atraso jul/ago cerrado |
| 6 | MEUAZPTA011 | 172.30.1.9 | Azure West Europe | Server 2022 | Pass-through Authentication (par HA) | Alta | 🗓️ Ventana fin de mes — uno del par cada vez |
| 7 | MEUAZPTA012 | 172.30.1.10 | Azure West Europe | Server 2022 | Pass-through Authentication (par HA) | Alta | 🗓️ Ventana fin de mes — uno del par cada vez |
| 8 | MEUAZEX001 | 172.30.1.11 | Azure West Europe | Server 2022 | Etiquetado "Exchange" — **sin Exchange instalado** | Muy alta | 🗓️ Ventana fin de mes |
| 9 | MUSAZDC011 | 172.20.1.4 | Azure South Central US | Server 2022 | Controlador de dominio + DNS | Alta | 🗓️ Ventana fin de mes — reinicio escalonado |
| 10 | MEUAZAVD-0 | — | Azure West Europe | *a confirmar* | Host de escritorios virtuales (AVD) | *a confirmar* | ❓ Fuera de la rutina hasta confirmar OS y uso |

### Fuera del alcance de Windows Update

| Host | IP pública | Tipo | Quién parchea |
|---|---|---|---|
| MEUAZFW001 | 108.142.212.203 | Firewall Sophos (VPN región EU) | Firmware SFOS → conet.de (Kevin Pütz-Kurth) |
| MUSAZFW001 | 104.210.193.97 | Firewall Sophos (VPN filial US) | Firmware SFOS → conet.de (Kevin Pütz-Kurth) |

Los firewalls de sede (`XGSDEFRA01/02`, `REDDEHEF01`, `REDESBCN01`…) tampoco entran en el
parcheo mensual de CoolNetworks: son firmware Sophos gestionado por conet.

---

## Cronología

| Fecha | Evento |
|---|---|
| jul-2026 | KB5099538 falla en MEUAZAC011 con `0x80246007` (6 intentos). |
| ago-2026 | KB5120238 falla en MEUAZAC011 con el mismo código (27 intentos). |
| 07-sep-2026 | Se confirma que el disco C: de MEUAZAC011 (29,4 GB, 0,5 GB libres) es la causa raíz. Se descartan WSUS, proxy y bloqueo de red. Se vacía `C:\Windows\SoftwareDistribution\Download` (~5,9 GB) parando solo `wuauserv` y `bits`. |
| 07/09-sep-2026 | **La CU acumulativa se instala correctamente en MEUAZAC011.** Atraso de julio y agosto cerrado. |
| fin de sep-2026 | Ventana de mantenimiento: parcheo del resto de la flota (9 hosts). |

---

## Trabajo realizado

### MEUAZAC011 — desbloqueo del parcheo
- Diagnóstico de causa raíz: el fallo estaba en la fase de **descarga**, no de instalación. Cada
  reintento dejaba payload parcial y reducía el espacio para el siguiente.
- Liberados ~5,9 GB borrando el caché de descarga de Windows Update (borrado, no renombrado: con
  0,5 GB libres la copia `.old` no cabía).
- **CU acumulativa instalada con éxito.** Al ser acumulativa cubre también el KB5099538 de julio
  que había fallado. *(KB exacto instalado: confirmar en el historial de actualizaciones.)*
- No se tocó ADSync durante la limpieza, así que no se disparó la alerta "Entra Connect Sync
  tampering" de Defender for Cloud. El reinicio de la instalación sí la dispara → avisar a conet.

### Resto de la flota
- 9 hosts programados para la **ventana de mantenimiento de fin de mes**. Los cuatro
  controladores de dominio se reinician **escalonados, uno a uno**, para no romper la replicación
  de AD. Mismo criterio para el par PTA011/PTA012: nunca los dos a la vez, o se cae la
  autenticación pass-through.

---

## Puntos abiertos

1. **MEUAZAC011 — ampliación de disco (conet).** El parcheo está desbloqueado, pero el disco de
   sistema sigue siendo de 29,4 GB. Liberar espacio es de CoolNetworks; **ampliarlo a ≥80 GB es
   de conet** (plataforma). Sin la ampliación el problema reaparece en 3-4 ciclos: cada LCU
   mensual vuelve a llenar el volumen. Aprovechar que en Azure la ampliación exige parar la VM y
   la ventana de fin de mes ya la contempla.
2. **Avisar a conet antes de la ventana**: el mantenimiento de MEUAZAC011 dispara la alerta
   "Entra Connect Sync tampering" en Defender for Cloud, que reciben ellos.
3. **MEUAZAVD-0**: confirmar OS, uso y si entra en la rutina mensual estándar. Hoy queda fuera.
4. **Firewalls Sophos**: el firmware SFOS no entra en este ciclo. `MEUAZFW001` además **no está
   enrolado en Sophos Central**, así que su estado de firmware no es visible desde consola.
