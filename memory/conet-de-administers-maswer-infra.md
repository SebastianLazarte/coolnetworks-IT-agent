---
name: conet-de-administers-maswer-infra
description: "\"conet\" = conet.de, empresa externa (NO CoolNetworks) que administra la infraestructura de servidores de Maswer y además es su reseller CSP de Microsoft. Es el destino REAL de las escalaciones que la matriz llama \"N2 Systems\"."
metadata:
  type: project
---

**conet** es una empresa externa — **conet.de** — **NO CoolNetworks**. Fácil de confundir porque
la cuenta admin `conetadmin` aparece con Vollzugriff en las ACLs de carpetas de Maswer.

conet.de opera la infraestructura de **nivel servidor y plataforma** de Maswer. CoolNetworks
(Sebastian, [[user-identity]]) lleva el IT remoto del día a día; conet lleva lo que está por
debajo.

## Escalación: conet ES el "N2 Systems" real (confirmado 2026-08-17)

**No existe un equipo N2 Systems interno.** El flujo N1→N2 Systems de `core/rules.md` y de
`reference/classification-matrix.md` es andamiaje organizativo de ficción — ver
[[user-is-whole-it-stack]]. Para incidencias reales de infraestructura de red/servidores (p. ej.
WiFi o router de una oficina caídos), **el destino real de la escalación es conet.de**, no un
grupo interno. Cuando la matriz de clasificación encamine un ticket a "N2 Systems", encaminarlo
a conet.de y **decirlo explícitamente en el bloque ESCALATE?**.

## Contactos (conet Deutschland GmbH, Bundeskanzlerplatz 2, 53113 Bonn)

| Persona | Rol | Tel. | Móvil | Correo |
|---|---|---|---|---|
| **Stefan Wilhelm** | **Main Contact** — Architect, Cloud & IT Infrastructure Mgmt | +49 228 9714 1091 | +49 173 5486 332 | `swilhelm@conet.de` |
| Kevin Pütz-Kurth | **Firewall** — Cloud & Managed Services | +49 228 9714 1024 | +49 170 9402 928 | `KPuetz-Kurth@conet.de` |
| Fabian Degen | **Virtual Desktop** — C&MS (Frankfurt) | — | +49 151 67128 959 | `FDegen@conet.de` |
| Patrick Kuhlmann | **Sales / licencias** — conet Holding, Karlsruhe | — | — | `PKuhlmann@conet.de` |
| Maik Kantz | Suplente técnico | — | — | — |

- **Escalación técnica → Stefan Wilhelm** (Main Contact) o Kevin. **Licencias → Patrick
  Kuhlmann**; los técnicos no tocan licenciamiento.
- **Maik Kantz** respondió la escalación P1 de WiFi del 2026-08-17 en ausencia de Kevin, así que
  escribir a Stefan/Kevin sí llega a un suplente competente. Abrió con "no conozco del todo
  vuestra infraestructura, pero supongo que es la sede HEF01" — y **aun así el diagnóstico era
  correcto**: identificó un fallo de detección de RED ligado a SFOS 21.5.0 GA-Build171 y
  recomendó 21.5 MR2, que resolvió la caída sin tocar hardware. **Historial: fiarse de su
  análisis basado en consola** → [[defer-to-direct-console-evidence]].
- Kevin estuvo **OOO hasta el 2026-09-01** (auto-respuesta del 2026-08-17, sin reenvío ni
  suplente nombrado). **Esa ventana ya ha pasado** — asumirlo localizable, y si vuelve a saltar
  la auto-respuesta, actualizar esta línea.
- ⚠️ La lista original de contactos incluye a **Oliver Orth con su número privado**
  (+49 171 6038084, `oliver.orth@gmx.de`) como vía de soporte. **No usar** — ya no está en
  Maswer, ver [[oliver-left-maswer-no-handover]] y
  [[oliver-orth-admin-accounts-still-enabled]].

## Qué lleva conet

- **File server `MDERZFIL001`** a nivel servidor: auditoría/SACL, retención de logs, cambios de
  ACL en el propio servidor.
- **Plataforma Azure**: dimensionado y ampliación de discos de las VM. Precedente del reparto de
  responsabilidad en [[meuazac011-disco-c-insuficiente]] — liberar espacio *dentro* del volumen
  es de CoolNetworks (el parcheo mensual es suyo desde mayo-2026), **ampliar el disco es de
  conet**.
- **Despliegue masivo por GPO/script** en la flota (p. ej. estandarizar una herramienta de acceso
  remoto, [[remote-access-teamviewer-fails-fallback-anydesk]]), y los derechos de admin local
  cross-endpoint que faltan desde la salida de Oliver ([[oliver-left-maswer-no-handover]]).
- **Alertas de Defender for Cloud** sobre los servidores: las reciben ellos, así que hay que
  avisarles de los mantenimientos que las disparan →
  [[adsync-restart-triggers-defender-alert]].
- **Licencias Microsoft** (ver abajo).

## conet es TAMBIÉN el reseller CSP de Microsoft (confirmado 2026-08-28)

Ticket ADN #269249 (Michael Glüge): *"we do not provide direct support to endcustomer, please
contact your reseller. In this case your reseller is the company CONET Services GmbH."*

Cadena de canal: **Microsoft → ADN Distribution (distribuidor) → CONET Services GmbH (reseller)
→ Maswer**. ADN aparece en el tenant solo como *support contact*, una etiqueta de trazabilidad
de Microsoft — **no es un canal de soporte para Maswer y rebota** cualquier petición de cliente
final.

→ **Todas las preguntas de licenciamiento M365** (compras, número de puestos, precios, términos
NCE) van a conet, igual que el trabajo de servidor. Detalle en
[[maswer-m365-copilot-licensing]].

## Qué NO hay que pedirle a conet

- **Acceso a carpetas de red.** Desde el 25-ago-2026 está verificado que Sebastian puede
  gestionar él mismo los grupos de seguridad — ver [[sebastian-ad-privileges]] y
  [[maswer-access-via-ad-security-groups]]. No escalar peticiones de acceso por falta de
  permisos.
- **Altas, bajas, resets y cambios de pertenencia a grupos**: los ejecuta él directamente.

## Sin confirmar

- Si conet gestiona la consola de backup de M365 (Hornetsecurity/Altaro) — **no darlo por
  hecho**; se preguntó el 2026-07-01 y sigue pendiente de respuesta →
  [[maswer-m365-backup]].
- Por qué el firewall EU `MEUAZFW001` está fuera de Sophos Central →
  [[maswer-vpn-sophos]].

**How to apply:** toda petición a conet lleva: ruta UNC real o host afectado, usuarios, nivel de
acceso pedido, y **qué se ha probado ya**. En inglés, siempre
([[user-does-not-speak-german-use-english]]), sin explicarles cosas que ya saben de su propia
casa ([[dont-state-the-obvious-to-recipient]]).
