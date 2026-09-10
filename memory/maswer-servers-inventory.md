---
name: maswer-servers-inventory
description: Inventory of Maswer's server/VM fleet (on-prem + Azure) with roles confirmed via Defender for Endpoint "Device Role" tag where available, rest inferred from naming convention. Also serves as the task→servidor lookup ("Qué servidor para qué tarea") — which host to RDP/act on for a given action. See "Pendiente de confirmar" for open items.
metadata:
  type: reference
---

Inventario construido a partir de dos capturas (consola de inventario de servidores + Azure Portal "Máquinas virtuales") y confirmado con export CSV de Microsoft Defender for Endpoint (jul-2026, campo "Device Role"). Complementa [[maswer-ad-domain-infra]] y [[conet-de-administers-maswer-infra]].

## Qué servidor para qué tarea
Índice inverso (tarea → servidor). El detalle autoritativo de cada host está en las tablas de abajo; esto es solo el atajo para saber **dónde actuar** según lo que hay que hacer. Todo lo pendiente de confirmar sigue marcado como tal.

| Tarea | Servidor(es) | Cómo / nota |
|---|---|---|
| Forzar sync AD→M365 | `MEUAZAC011` | RDP → `Start-ADSyncSyncCycle -PolicyType Delta`. **Antes, `Sync-ADObject` a los DCs de Azure** o el alta no llega → [[maswer-replicacion-dcs-azure-altas]]. Detalle del servidor: [[maswer-aad-connect-server]] |
| Crear/editar usuario, buzón (nombre/alias), grupos AD | DC on-prem `MDERZADC003` / `MDERZADC004` (ADUC/RSAT) | AD on-prem = master de identidad; Exchange híbrido gobierna el alias en AD, no en M365 — ver [[maswer-ad-domain-infra]] |
| Exchange híbrido (buzones, colas) | ⚠️ **NO es `MEUAZEX001`** | Verificado en la máquina (22-jul-2026): sin binarios (`C:\Program Files\Microsoft\Exchange Server` no existe), sin clave `HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup`, sin servicios `MSExchange*`. Los cmdlets `*-RemoteMailbox` **no existen ahí**. El rol "ExchangeServer" venía de la etiqueta Defender, no de la máquina. Direcciones de correo → editar `proxyAddresses` en AD (`MDERZADC003`) con `-Add`/`-Remove`, nunca `-Replace` de la colección, + sync. Pendiente: `Get-ADObject -LDAPFilter '(objectClass=msExchExchangeServer)'` para ver si hay Exchange en el bosque |
| DNS / autenticación de dominio | `MDERZADC003`/`MDERZADC004` (on-prem), `MEUAZDC011` (EU), `MUSAZDC011` (US) | DCs por región |
| VPN / firewall EU | `MEUAZFW001` (Sophos SSL VPN, pública 108.142.212.203) | remote-access VPN de la región EU — ver [[maswer-network-topology]] |
| VPN / firewall US | `MUSAZFW001` (pública 104.210.193.97) | firewall/VPN de la filial US |
| File server / permisos NTFS | `MDERZFIL001` | **rol CONFIRMADO 25-ago-2026** (no inferido): shares `maswer\{NEXPRO,intranet,maswerag,maswerspainsl}` = unidades M/O/P/R; ruta local `D:\Shares\Maswer\<share>\…`. Acceso por grupo de seguridad, no por ACL directa. `Get-Acl` sobre UNC da "Acceso denegado" incluso con privilegio de dominio → leer la ACL vía `Invoke-Command` sobre la ruta local. Ver [[maswer-access-via-ad-security-groups]] y `reference/runbook-acceso-carpetas-red-maswer.md` |
| Escritorios virtuales (AVD) | `MEUAZAVD-0` | propósito/usuarios **pendiente de confirmar** |

## Convención de nombres
`[entidad][sitio][rol][num]`
- **Entidad:** `MDE` = Maswer Deutschland (on-prem) · `ME` = Maswer Europa (Azure West Europe) · `MU` = Maswer US (Azure South Central US)
- **Sitio:** `RZ` = **Rechenzentrum** (alemán: "centro de datos") — confirmado por el diagrama de red Visio, que rotula el hub central como "**RZ FFM**" (Rechenzentrum Frankfurt am Main), con el firewall HA `XGSDEFRA01`/`XGSDEFRA02` ahí alojado. Esto **reinterpreta** `MDERZADC003` como `MDE`+`RZ`+`ADC003` (no `MD`+`ERZ` como se había supuesto antes) · `AZ` = Azure
- **Rol:** `ADC` = Domain Controller (on-prem) · `DC` = Domain Controller (Azure) · `AC` = Entra/AAD Connect (dir-sync) · `PTA` = Pass-through Authentication agent · `EX` = Exchange (hybrid) · `FW` = Firewall/gateway VPN · `FIL` = File server · `AVD` = Azure Virtual Desktop

Ver detalle completo de sedes y topología de red en [[maswer-network-topology]].

## On-prem (dominio intern.maswer.com)
| Servidor | IP | OS | Rol (Defender Device Role) | Criticidad |
|---|---|---|---|---|
| MDERZADC003 | 192.168.0.10 | WindowsServer2022 | Dns, DomainController (confirmado) — ver [[maswer-ad-domain-infra]] | High |
| MDERZADC004 | 192.168.0.9 | WindowsServer2022 | Dns, DomainController (confirmado) | High |
| MDERZFIL001 | 192.168.0.13 | WindowsServer2019 | File server (inferido por nombre, sin tag en Defender) | Very High |

Las tres están alojadas en el **RZ FFM** (Rechenzentrum Frankfurt am Main), la subred core `192.168.0.0/24` detrás del firewall HA `XGSDEFRA01`/`XGSDEFRA02` — ver [[maswer-network-topology]].

## Azure — West Europe (RG Maswer_RG_ME…, sub CONET-CSP-M…, subred 172.30.1.0/24)
| VM | IP | OS | Rol (Defender Device Role) | Criticidad |
|---|---|---|---|---|
| MEUAZDC011 | 172.30.1.8 | WindowsServer2022 | Dns, DomainController (confirmado) | High |
| MEUAZAC011 | 172.30.1.7 | WindowsServer2019 | EntraConnectServer, AzureADConnectServer (confirmado) — detalle en [[maswer-aad-connect-server]]; ⚠️ disco C: al 98%, ver [[meuazac011-disco-c-insuficiente]] | High |
| MEUAZPTA011 | 172.30.1.9 | WindowsServer2022 | sin tag — inferido por nombre (par HA con PTA012) | High |
| MEUAZPTA012 | 172.30.1.10 | WindowsServer2022 | sin tag — inferido por nombre (par HA con PTA011) | High |
| MEUAZEX001 | 172.30.1.11 | WindowsServer2022 | ⚠️ etiqueta Defender = ExchangeServer, pero **NO tiene Exchange instalado** — verificado en la máquina 22-jul-2026 (ver la fila "Exchange híbrido" de la tabla de tareas y [[maswer-exchange-hybrid]]). La etiqueta es lo único que sostenía el rol | Very High |
| MEUAZFW001 | pública 108.142.212.203 (Linux) | — (no aparece en el CSV de Defender, fuera de alcance por ser Linux/gateway) | Firewall Sophos SSL VPN de la región EU (confirmado por el usuario) | — |
| MEUAZAVD-0 | — | — | Azure Virtual Desktop host | — |

## Azure — South Central US (filial US, confirmado por el usuario)
Administrado por conet.de y también por el usuario (mismo modelo que la región EU — ver [[conet-de-administers-maswer-infra]]). Nótese que está en una subred distinta a la EU: **172.20.1.0/24** (no 172.30.x).

| VM | IP | OS | Rol (Defender Device Role) |
|---|---|---|---|
| MUSAZDC011 | 172.20.1.4 | WindowsServer2022 | Dns, DomainController (confirmado) |
| MUSAZFW001 | pública 104.210.193.97 (Linux) | — | Firewall Sophos SSL VPN de la filial US (confirmado por el usuario) |

## Cómo se relacionan
El AD on-prem (MDERZADC003/004) es el master de identidad → sincroniza a Entra ID vía MEUAZAC011 (Connect) + MEUAZPTA011/012 (autenticación pass-through, sin contraseñas en la nube) → identidad híbrida. Exchange híbrido corre en MEUAZEX001. Cada firewall (MEUAZFW001 / MUSAZFW001) es la puerta de entrada/VPN de su región (EU / US). MEUAZAVD-0 es un host de escritorios virtuales, aparte del resto de infraestructura de identidad.

## Pendiente de confirmar con el usuario
- "RZ" = Rechenzentrum tiene fuerte evidencia (rótulo explícito "RZ FFM" en el diagrama Visio), pero sigue sin ser un email/documento de conet.de confirmándolo formalmente
- Propósito de MEUAZAVD-0 (¿para qué usuarios/equipo está publicado?)
- Rol exacto de MEUAZPTA011/012 y MDERZFIL001 — coherente con el nombre pero sin tag de Defender que lo confirme
- Las capturas/CSV pueden estar recortadas — puede haber más servidores/VMs no listados aquí (revisar la lista completa sin paginar)
