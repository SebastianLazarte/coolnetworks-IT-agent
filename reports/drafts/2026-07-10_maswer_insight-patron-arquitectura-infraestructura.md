# INSIGHT DE ARQUITECTURA — Patrón de Infraestructura Maswer

**Cliente:** Maswer (Maswer AG / Maswer GmbH / Maswer Spain S.L. / filiales México y EEUU)
**Área:** Infraestructura de red, identidad y servidores (on-prem + Azure)
**Preparado por:** CoolNetworks — Soporte IT
**Fecha:** 10 de julio de 2026
**Fuentes:** consola de inventario de servidores, Azure Portal, export de Microsoft Defender for Endpoint, diagrama de red oficial ("Maswer-IP-Visio 1.pdf")

---

## Resumen ejecutivo

La infraestructura de Maswer sigue un patrón de **hub-and-spoke híbrido con extensión
regional a la nube**: un centro de datos físico en Frankfurt actúa como hub principal
para las sedes europeas, y dos "hubs" adicionales en Azure (Alemania y EEUU) replican
esa misma función para las sedes americanas y para las cargas de trabajo ya migradas a
la nube. La identidad (Active Directory) permanece **maestra en on-premise** en las tres
capas, con la nube actuando como extensión sincronizada, no como reemplazo.

Es un diseño coherente y defendible — no aleatorio — que responde a tres necesidades:
continuidad de una red multi-sede ya existente, adopción gradual de la nube sin migrar
identidad, y control sobre dónde viven las contraseñas por motivos de seguridad.

---

## 1. Tres hubs, no uno

| Hub | Ubicación | Rol |
|---|---|---|
| **RZ FFM** (Rechenzentrum Frankfurt am Main) | Físico, Alemania | Hub histórico: firewall HA (`XGSDEFRA01`/`02`), DCs on-prem, file server |
| **Azure Deutschland** (West Europe) | Nube | Extensión del hub alemán: DC réplica, AAD Connect, Exchange hybrid, AVD |
| **Azure USA** (South Central US) | Nube | Hub regional para México/EEUU: DC réplica, firewall propio |

Cada hub tiene su propio firewall Sophos con SSL VPN y su propia subred de gestión
(`172.30.x` para Alemania/Azure DE, `172.20.x` para Azure US), y todos están unidos
entre sí: RZ FFM ↔ Azure Deutschland por Site-to-Site VPN, Azure Deutschland ↔ Azure
USA por **peering nativo de VNet** (no VPN — más rápido, sin cifrado IPsec de por medio
porque va por red troncal de Microsoft).

**Por qué:** las sedes mexicanas (Saltillo, Puebla, Aguascalientes) y la de EEUU
(Tuscaloosa) cuelgan de Azure USA en vez de tunelizar hasta Frankfurt. Tiene sentido por
latencia — un sitio en México llega antes a South Central US que a Alemania — y evita
que todo el tráfico transatlántico dependa de un único enlace largo hacia el hub
europeo.

## 2. Identidad: on-prem manda, la nube sincroniza

El patrón se repite en todas las capas: **el Active Directory on-prem es la fuente de
verdad**, y todo lo demás (Entra ID, buzones de Exchange, alias) se deriva de ahí.

- `MDERZADC003` / `MDERZADC004` (Frankfurt, on-prem) son los controladores de dominio
  maestros.
- `MEUAZAC011` (Azure) ejecuta Entra/AAD Connect — sincroniza identidad hacia la nube,
  no al revés.
- `MEUAZPTA011` / `MEUAZPTA012` — **dos** agentes de Pass-Through Authentication, no
  Password Hash Sync. Esto es una decisión deliberada: **las contraseñas nunca salen del
  entorno on-prem**; cada inicio de sesión en Microsoft 365 se valida contra el AD local
  en tiempo real. Es la opción más restrictiva de las que ofrece Microsoft para
  autenticación híbrida, típica de organizaciones con exigencias de seguridad o
  cumplimiento más altas de lo habitual.
- Los alias/nombres de buzón se editan en AD on-prem, no en M365 — mismo patrón,
  reforzado en memoria interna.

**Por qué dos agentes PTA:** es el mínimo recomendado por Microsoft para alta
disponibilidad — si un agente cae, el otro sigue validando logins sin interrupción.

## 3. Réplicas de Domain Controller en Azure, no solo Entra ID

Además de sincronizar a Entra ID, Maswer mantiene **controladores de dominio Windows
completos dentro de Azure** (`MEUAZDC011` en Alemania, `MUSAZDC011` en EEUU). Esto va
más allá de una integración de identidad en la nube estándar: indica que hay cargas de
trabajo en Azure (VMs, aplicaciones, el propio Exchange hybrid, AVD) que necesitan
resolución LDAP/Kerberos de baja latencia **dentro** de la región de Azure, sin depender
de un túnel hasta Frankfurt para cada autenticación. Es el patrón típico de una
migración "lift-and-extend": las cargas se mueven a la nube, pero el dominio se extiende
con ellas en vez de sustituirse por un directorio nativo de la nube.

## 4. Redundancia: presente en el núcleo, ausente en los extremos

| Componente | Redundancia |
|---|---|
| Firewall RZ FFM | Par HA (`XGSDEFRA01`/`02`) |
| DCs on-prem | 2 (`ADC003`/`ADC004`) |
| Agentes PTA | 2 (`PTA011`/`PTA012`) |
| Túneles Site-to-Site a sedes (Vaihingen y, previsiblemente, el resto) | **1 solo túnel, sin failover** |

El patrón de alta disponibilidad se aplica de forma consistente en el núcleo
(datacenter, identidad), pero **no llega a las sedes remotas**: cada sede depende de un
único túnel IPsec sin ruta de respaldo — el caso de Vaihingen (ver informe de la
incidencia de junio 2026) es representativo, no una excepción. Es el punto más frágil
del diseño actual.

## 5. Qué queda fuera de esta lectura (a confirmar)

- El propósito exacto de `MEUAZAVD-0` (Azure Virtual Desktop) — ¿escritorios para
  usuarios remotos, para las sedes sin workstation completa (México/Tuscaloosa), o para
  contratistas externos?
- Identidad del sitio en `192.168.9.1/24` y de los firewalls sin nombre en Hockenheim
  Ring y Tuscaloosa (diagrama incompleto en esos puntos).
- Confirmación formal de "RZ = Rechenzentrum" por parte de conet.de (evidencia fuerte
  por el propio diagrama, pendiente de respuesta por correo).

Estas preguntas ya están en el correo enviado a conet.de
(`2026-07-10_conet_infra-documentation-request.md`).

---

## Conclusión

No es una arquitectura improvisada: es un hub-and-spoke híbrido clásico, con identidad
on-prem-first por decisión de seguridad, y extensión a la nube organizada por geografía
(Alemania/Europa vs. América) en vez de por tipo de carga. El único punto que no sigue
el mismo nivel de robustez que el resto del diseño es la conectividad de las sedes
remotas, que depende de un único túnel sin redundancia.

---

*Documento preparado por CoolNetworks · 10 de julio de 2026.*
