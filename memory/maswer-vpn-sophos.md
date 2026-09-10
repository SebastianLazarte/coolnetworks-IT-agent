---
name: maswer-vpn-sophos
description: "VPN de acceso remoto de Maswer = Sophos SSL VPN. Sophos Central solo lista 3 firewalls; el gateway EU 108.142.212.203 NO está enrolado — punto ciego de gestión."
metadata:
  type: reference
---

La VPN de acceso remoto de Maswer es **Sophos SSL VPN** (cliente Sophos Connect, tipo SSL/TCP).
Confirmado 2026-07-02: conexión con el cliente Sophos Connect al gateway `108.142.212.203`.

## Dónde se ve qué, en la consola web del firewall (SFOS, `https://<IP-firewall>:4444`)

- **Quién tiene VPN concedida:** CONFIGURE → VPN → SSL VPN (Remote Access) → miembros de la
  política (usuarios/grupos); lista de usuarios en CONFIGURE → Authentication → Users/Groups.
- **Quién está conectado ahora:** MONITOR & ANALYZE → Current Activities → Live Users.
- **Histórico de conexiones:** MONITOR & ANALYZE → Log Viewer, filtrando módulo
  VPN/Authentication.

## Parque de firewalls en Sophos Central (confirmado 2026-07-24, tenant "Maswer AG")

Firewall Management → Firewalls lista solo **tres**, todos Ungrouped. **Firmware: los tres
actualizados a SFOS 21.5 MR2 el 2026-08-17** — todo el parque estaba en 21.5.0 GA-Build171
hasta entonces. La actualización se lanzó desde Sophos Central (Firewall Management →
Firewalls → icono ⬇ en la columna Versión) y completó en los tres.

| Nombre en Central | IP pública | Modelo | Qué es |
|---|---|---|---|
| XGSDEFRA (par HA) | 195.20.133.175 | XGS128 | Hub RZ Frankfurt (= XGSDEFRA01/02) |
| XGSDEVAI01 | 87.234.245.186 | XGS128 | Vaihingen — ver [[maswer-vaihingen-s2s-vpn-runbook]] |
| XGSUSAZ01 | 104.210.193.97 | SFV2C4 (virtual) | Azure **US** — la VM `MUSAZFW001` del inventario |

## Punto ciego: el firewall EU no está en Central

El firewall **Azure EU** `MEUAZFW001` / `108.142.212.203` — el gateway que termina la SSL VPN
de acceso remoto de **todos los usuarios europeos** — **NO está enrolado en este tenant de
Sophos Central**, aunque su gemelo US sí lo está. Central no es una vía para administrarlo.

Orden a probar cuando haga falta un cambio en él: (1) cambiar de tenant con el selector
"Maswer AG" arriba a la derecha, por si vive en otra entidad; (2) consola directa
`https://108.142.212.203:4444`; (3) [[conet-de-administers-maswer-infra]]. Las credenciales de
admin de ese firewall siguen SIN confirmar a fecha 2026-07-24.

**Asunto abierto con conet.de:** por qué el gateway VPN de EU está fuera de la gestión de
Central — es un punto ciego de monitorización sobre la caja de la que depende todo usuario
remoto europeo.

Atajo útil: `XGSUSAZ01` es la misma arquitectura (firewall virtual Sophos en Azure, mismo
build), así que su configuración de acceso remoto / reglas de país es una buena aproximación a
lo que probablemente tenga el de EU. Topología completa en [[maswer-network-topology]].
