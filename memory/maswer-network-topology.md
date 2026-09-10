---
name: maswer-network-topology
description: Maswer's full WAN topology (hub-and-spoke) from the official Visio network diagram — all sites, firewall device names, subnets, Site2Site/SSLVPN structure. Use for any cross-site connectivity or firewall-naming question.
metadata:
  type: reference
---

Fuente: diagrama de red oficial "Maswer-IP-Visio 1.pdf" (compartido por el usuario, jul-2026). Todos los firewalls de sitio parecen ser Sophos (modelo **XGS** visible en el naming — ver [[maswer-vaihingen-s2s-vpn-runbook]] que ya confirma XGSDEVAI01 como Sophos XGS gestionado por Sophos Central).

## Convención de nombres de firewalls/routers de sitio
`[Modelo][País][Sede][num]` — ej. `XGSDEFRA01` = XGS-DE-FRA-01 (Frankfurt), `REDESBCN01` = RED-ES-BCN-01 (Barcelona). Nota: es una convención **distinta** a la de los servidores/VMs (ver [[maswer-servers-inventory]]) — esta es para firewalls/edge, la otra para servers Windows.

## Hub central: RZ FFM (Rechenzentrum Frankfurt am Main)
El datacenter/HQ de Maswer. Firewall HA pair: **XGSDEFRA01** / **XGSDEFRA02**.
- IPs: `10.101.0.157/24`, `172.16.0.3/24`, `192.168.0.2/24` (gateway de la LAN core donde viven MDERZADC003/004/FIL001 — ver [[maswer-servers-inventory]])
- Es el hub de Site-to-Site VPN hacia todos los sitios alemanes/españoles y hacia Azure Deutschland.

## Sitios conectados al hub RZ FFM (Site2Site VPN)
| Sitio | Firewall | LAN |
|---|---|---|
| Hockenheim Ring | (sin nombre en el diagrama) | 192.168.13.1/24 |
| Vaihingen an der Enz | XGSDEVAI01 (ver [[maswer-vaihingen-s2s-vpn-runbook]]) | 192.168.12.1/24 |
| Hennef | REDDEHEF01 | 192.168.1.1/24 |
| Rüsselsheim | REDDERUM01 | 192.168.2.1/24 |
| Calden | REDDECAL01 | 192.168.3.1/24 |
| Barcelona | REDESBCN01 | 192.168.4.1/24 |
| Zaragoza | REDESZAZ01 | 192.168.5.1/24 |
| Barcelona Bodyshop | REDESBCN02 | 192.168.8.1/24 |
| **??? sin identificar** | (sin nombre) | 192.168.9.1/24 — **pendiente de confirmar con conet.de qué sitio es** |

## Azure Deutschland (West Europe) — 172.30.0.0/16
Corresponde a la región "ME" (Maswer Europa) del inventario de VMs — ver [[maswer-servers-inventory]].
- SSLVPN pool: `10.242.1.0/24` · WAN/S2S: `172.30.250.4/24` · LAN gateway: `172.30.1.12/24`
- Conectado al hub RZ FFM vía Site2Site, y a Azure USA vía **Azure Peering** (VNet peering nativo, no VPN).

## Azure USA (South Central US) — 172.20.0.0/16
Corresponde a la región "MU" (Maswer US) del inventario de VMs.
- SSLVPN pool: `10.242.3.0/24` · WAN/S2S: `172.20.250.4/24` · LAN gateway: `172.20.1.5/24`
- Hub para los sitios mexicanos + Tuscaloosa (EEUU).

## Sitios conectados a Azure USA
| Sitio | Firewall | LAN |
|---|---|---|
| Saltillo (México) | REDMXSAL01 | 192.168.11.1/24 |
| Puebla (México) | REDMXPUE01 | 192.168.7.1/24 |
| Aguascalientes (México) | REDMXAGU01 | 192.168.6.1/24 |
| Tuscaloosa (EEUU, Alabama) | (sin nombre en el diagrama) | 192.168.10.1/24 |

## Cómo se relaciona con el resto
- Confirma y explica el prefijo **RZ = Rechenzentrum** en `MDERZADC003/004` y `MDERZFIL001` — ver nota actualizada en [[maswer-servers-inventory]].
- Coincide con las entidades ya vistas en el mapa de unidades de red ([[maswer-ad-domain-infra]]): Zaragoza, Barcelona/SpainSL, Mexico, MaswerGmbH — mismo universo de sedes.
- Los dos firewalls Sophos SSL VPN de las VMs Azure (MEUAZFW001 / MUSAZFW001, en [[maswer-servers-inventory]]) son probablemente los mismos representados aquí como el nodo de Azure Deutschland / Azure USA (las IP de este diagrama son internas; las **públicas** y el estado de firmware están en [[maswer-vpn-sophos]]).
- ⚠️ **Solo tres de estos firewalls están en Sophos Central.** El de Azure EU (`MEUAZFW001` / `108.142.212.203`), del que depende toda la VPN de acceso remoto europea, **no está enrolado** → punto ciego de gestión, detalle en [[maswer-vpn-sophos]].

## Pendiente de confirmar
- Qué sitio es el firewall sin nombre en `192.168.9.1/24`
- Nombre del firewall de Hockenheim Ring y de Tuscaloosa (aparecen sin device name en el diagrama)
- Si el diagrama está completo o hay sitios adicionales fuera de esta hoja
