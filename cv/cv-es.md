# Sebastián Lazarte Castellón

**Técnico de Sistemas e Infraestructura · Automatización con IA**

<!-- Completa antes de enviar: -->
`[Ciudad, País]` · `[Teléfono]` · `[Email]` · `[LinkedIn]` · `[GitHub]`

---

## Perfil

Técnico de sistemas responsable en solitario del servicio IT de una cuenta industrial del
sector de automoción con 14 sedes en cuatro países, cubriendo el stack completo: desde el
soporte a usuario hasta la administración de Active Directory híbrido, Azure, Exchange
Online y seguridad perimetral Sophos. Asumí la cuenta tras la salida del técnico anterior
sin traspaso de accesos ni documentación, y la reconstruí hasta convertirla en una
operación documentada y auditable. En paralelo diseño y pongo en producción agentes de IA
aplicados a operaciones IT reales.

---

## Experiencia

### CoolNetworks — Técnico de Sistemas y Soporte IT
**may. 2026 – actualidad** · Proveedor de servicios gestionados (MSP) IT y ciberseguridad ·
Cuenta asignada: cliente industrial del sector automoción (Alemania, España, México y EE. UU.)

#### Infraestructura y sistemas
- Responsable **único** del servicio IT de la cuenta: cubro N1, N2 y N3 sin nivel de
  escalado interno por encima; los únicos traspasos reales son soporte de fabricante (Sophos,
  Microsoft), operador e IT del propio cliente.
- Asumí la cuenta tras la salida del técnico anterior **sin traspaso de accesos ni
  documentación**. Reconstruí desde cero el inventario de servidores y la topología WAN
  cruzando Microsoft Defender for Endpoint, Azure Portal y el diagrama de red oficial del
  cliente, y lo convertí en documentación operativa reutilizable (inventario de hosts,
  índice tarea→servidor y runbooks).
- Administro un entorno **híbrido Active Directory / Microsoft 365**: controladores de
  dominio on-prem y en Azure (West Europe y South Central US), Entra Connect, agentes de
  Pass-Through Authentication en alta disponibilidad y Seamless SSO.
- Ejecuto el ciclo mensual de actualización y reinicio de la flota de servidores
  Windows Server 2019/2022.

#### Redes y seguridad perimetral
- Diagnostiqué una **caída total de conectividad** en una sede alemana (**P1, primera
  respuesta dentro del SLA de 15 minutos**) hasta la causa raíz: túnel IPsec site-to-site
  caído en un firewall Sophos XGS **sin grupo de failover configurado**. Documenté el
  runbook de recuperación y las medidas preventivas ausentes (failover group, alerta de
  tunnel-down, análisis de causa raíz del enlace).
- Gestiono la plataforma **Sophos Central** del cliente: 3 firewalls XGS, VPN SSL de acceso
  remoto y túneles site-to-site en topología hub-and-spoke, con dos regiones Azure
  interconectadas por VNet peering nativo.
- Detecté que un **firewall de producción de la región europea no estaba enrolado en
  Sophos Central**, quedando fuera de la gestión, el inventario y el reporting centralizados.

#### Identidad, correo y Microsoft 365
- Detecté una cuenta de un empleado dado de baja que llevaba **~6 semanas activa y en uso
  por otra persona**. Ejecuté el traspaso controlado —copia de seguridad del objeto con
  `Export-Clixml`, renombrado conservando el SID para preservar el perfil de Windows,
  reasignación de buzón y grupos— con procedimiento de *rollback* escrito previamente.
- Diagnostiqué una **parada de Azure AD Connect de ~18 horas sin sincronizar** que no había
  generado ninguna alerta, y la restablecí. Documenté además la alerta de Microsoft Defender
  for Cloud (*Potential Entra Connect Sync tampering*) que disparó el reinicio del servicio,
  clasificándola como verdadero positivo de una acción benigna.
- Detecté que un servidor etiquetado como **Exchange** en Defender for Endpoint **no tenía
  Exchange instalado** —verificado contra binarios, registro y servicios—. El hallazgo
  corrigió el procedimiento de gestión de direcciones de correo del cliente, que pasó a
  editarse sobre `proxyAddresses` en AD de forma incremental.
- Creé y delegué **6 buzones compartidos** en Exchange Online (Full Access + Send As, sin
  consumo de licencia) y documenté los riesgos de gobernanza asociados: suplantación,
  punto único de fallo y tratamiento de datos personales.
- Descarté un problema reportado de correo saliente verificando **SPF, DKIM y 10 días de
  message trace sin un solo fallo de entrega**; identifiqué la **ausencia de registro DMARC**
  en el dominio corporativo y propuse su publicación.

#### Datos, permisos y cumplimiento
- Recuperé el **100 % de la documentación del sistema de gestión ISO 14001** borrada de un
  servidor de ficheros, localizando la última instantánea **VSS** válida por comparación
  entre copias y restaurando desde el `DeviceObject` de la shadow copy, **sin pérdida de
  datos y sin impacto sobre el resto del recurso compartido**.
- A raíz de ese caso identifiqué dos huecos de trazabilidad —sin auditoría de borrado
  configurada y **retención del log de seguridad de solo ~6 días**— y redacté el plan de
  acción correctiva y el runbook técnico: SACL de borrado aplicada por GUID de subcategoría,
  ampliación del registro de seguridad y correlación de eventos 4660/4663/4656 por *Handle ID*.
- Preparé la evidencia para una **auditoría remota ISO/IEC 27001:2022 y ENS (RD 311/2022)**
  sobre 9 sistemas en alcance, mapeando controles del Anexo A y ensayando 8 escenarios en
  vivo: offboarding, ransomware, robo de portátil, CVE crítico en firewall, acceso a carpeta
  sensible y viaje imposible en Entra ID.
- **Paré** la concesión de accesos a una unidad departamental al detectar que sus grupos
  estaban segmentados por cliente final de automoción: concederlos en bloque habría creado
  acceso cruzado entre fabricantes competidores, en conflicto con la segregación
  *need-to-know* exigida por **TISAX**.
- Gestiono el ciclo de vida de las alertas de seguridad sobre una cadena Sophos Central →
  SIEM (Wazuh/Elastic) → ticketing. En la última revisión clasifiqué **16 alertas abiertas,
  el 100 % operativas de red y ninguna detección de amenaza**.
- Frené un alta de usuario con señales de **compromiso de correo corporativo (BEC)**:
  solicitud firmada por un tercero, credenciales pedidas para el solicitante y no para el
  titular, y sin aprobador identificado.
- Verifiqué la cobertura de **copia de seguridad de Microsoft 365** (Hornetsecurity 365 Total
  Backup) y documenté la diferencia entre la retención nativa de M365 y una copia real, como
  evidencia de auditoría.
- Gestiono los permisos sobre el servidor de ficheros mediante **grupos de seguridad de AD**
  en lugar de ACL por carpeta —en una intervención, 31 grupos aplicados a dos usuarios—,
  excluyendo deliberadamente los grupos de alcance global hasta validar su ACL real.

#### Soporte, documentación y comunicación
- Atiendo el ciclo completo del ticket en **Freshdesk**: triaje, prioridad, SLA, diagnóstico,
  respuesta al cliente y cierre. Tiempos de primera respuesta registrados de **11, 37 y 42
  minutos** en incidencias de software, conectividad y accesos.
- Redacto los **informes de caso y ejecutivos** que el MSP entrega a la dirección del
  cliente, con un pipeline propio de Markdown → Word/PDF en PowerShell.
- Trabajo en un entorno trilingüe: tickets en español, inglés y alemán, con documentación
  interna en inglés y entregables al cliente en español.

---

## Proyecto destacado

### Agente de soporte IT de Nivel 1 — diseño y puesta en producción
*Proyecto propio, aplicado a la operación real de CoolNetworks · Repositorio público, licencia MIT*

- Diseñé y puse en producción un **agente de IA que triaja tickets de Freshworks**:
  clasifica (7 categorías, prioridad P1–P4, grupo de asignación y SLA), propone un
  diagnóstico inicial, redacta la respuesta lista para enviar al cliente en su idioma y
  decide si escalar y con qué información.
- Arquitectura de contexto bajo **Interpretable Context Methodology (ICM)**: la estructura
  de carpetas *es* la arquitectura del agente. Cada fichero cumple una única función, de
  modo que un ticket de seguridad carga los criterios de escalado y los árboles de
  diagnóstico, y no las plantillas comerciales. Mantiene el foco del modelo y el coste de
  contexto bajos, y permite mantenerlo con un editor de texto, sin código ni framework.
- Base de conocimiento: matriz de clasificación con SLA, **7 árboles de diagnóstico anclados
  a la infraestructura real** (hosts, grupos de AD y runbooks concretos, nunca genéricos),
  **22 plantillas de respuesta bilingües** ES/EN, criterios de escalado y una capa de
  memoria persistente con los hechos operativos del cliente.
- Reglas de seguridad codificadas en el propio agente: nunca solicitar contraseñas, nunca
  tocar producción sin ventana de mantenimiento acordada, nunca improvisar ante un posible
  incidente de seguridad.
- Genera además los informes de caso y ejecutivos, exportados a Word y PDF mediante
  automatización en PowerShell.

---

## Competencias técnicas

| Área | Tecnologías |
|---|---|
| **Identidad y directorio** | Active Directory, ADUC/RSAT, GPO, Entra ID, Entra/Azure AD Connect, Pass-Through Authentication, Seamless SSO, MFA, Kerberos, modelo de administración por niveles (tiering) |
| **Microsoft 365** | Exchange Online e híbrido, buzones compartidos y delegación, SharePoint, OneDrive, Teams, Outlook, Intune, Microsoft Purview, SPF/DKIM/DMARC |
| **Cloud y virtualización** | Azure (VM, VNet peering, UDR, multirregión), Azure Virtual Desktop |
| **Redes y seguridad** | Sophos XGS y Sophos Central, VPN IPsec site-to-site y SSL de acceso remoto, topología hub-and-spoke, Microsoft Defender for Endpoint y for Cloud, Wazuh/Elastic (SIEM) |
| **Backup y recuperación** | Shadow Copies (VSS), Hornetsecurity 365 Total Backup, recuperación de datos y verificación de integridad |
| **Scripting y automatización** | PowerShell (módulo ActiveDirectory, Exchange Online, `Invoke-Command`/WinRM, ACL e `icacls`, `auditpol`, `wevtutil`, Word COM) |
| **Cumplimiento** | ISO/IEC 27001:2022, ENS (RD 311/2022), TISAX, RGPD, NIST CSF 2.0 |
| **Servicio y herramientas** | Freshdesk/Freshworks (SLA, grupos, automatizaciones), Git, Markdown, documentación técnica |
| **IA aplicada** | Diseño de agentes con conocimiento de dominio, ingeniería de contexto (ICM), Claude / Claude Code |

---

## Idiomas

- **Español** — nativo
- **Inglés** — profesional; idioma de trabajo técnico e interno
- **Alemán** — entorno de trabajo germanoparlante; proceso tickets en alemán y respondo en inglés

---

<!--
=====================================================================
PENDIENTE DE COMPLETAR POR TI — no tengo estos datos en el repositorio
=====================================================================

## Formación
- [Titulación, centro, años]

## Certificaciones
- [p. ej. AZ-900, MS-900, SC-900, MD-102, certificaciones Sophos]

## Experiencia anterior
- [Puestos previos a CoolNetworks: empresa, rol, fechas, 2-3 logros]
  Importante: el perfil de "5+ años de experiencia" que aparece en
  core/identity.md es la ficha ficticia del agente, NO tu biografía.
  Rellena esta sección con tu trayectoria real.

=====================================================================
VARIANTE CON CLIENTE NOMBRADO
=====================================================================
Si CoolNetworks te autoriza a nombrar la cuenta, sustituye en el
encabezado de Experiencia:

  "Cuenta asignada: cliente industrial del sector automoción
   (Alemania, España, México y EE. UU.)"

por:

  "Cuenta asignada: Grupo Maswer (Maswer AG / GmbH / Spain S.L.),
   proveedor industrial del sector automoción"

No añadas en ningún caso nombres de host, direcciones IP, seriales de
equipo ni nombres o correos de empleados del cliente.
-->
