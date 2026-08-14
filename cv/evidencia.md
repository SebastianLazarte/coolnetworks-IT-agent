# Evidencia del CV — respaldo de cada afirmación

**Uso interno. No enviar con el CV.**

Cada afirmación con cifra o hecho verificable de [cv-es.md](cv-es.md) / [cv-en.md](cv-en.md)
tiene aquí su fichero de origen y qué contar si preguntan en entrevista. Regla: **ningún
número en el CV sin fila en esta tabla**.

---

## Perfil y alcance del puesto

| Afirmación en el CV | Fuente | Qué contar en entrevista |
|---|---|---|
| Responsable único, cubro N1+N2+N3 sin escalado interno | `memory/user-is-whole-it-stack.md:8` | No hay compañero de N2 Sistemas ni N2 Ciberseguridad. Cuando un runbook dice "escalar a N2", en la práctica sigo yo con el siguiente nivel de diagnóstico. Los traspasos reales son fabricante, operador e IT del cliente. |
| Asumí la cuenta tras salida sin traspaso ni documentación | `memory/oliver-left-maswer-no-handover.md:8,10` | El técnico anterior salió sin transferir las cuentas administrativas. Confirmé con `gpresult /r` que no existía GPO de Grupos restringidos: el admin local estaba puesto a mano, máquina a máquina. Pedí a la empresa que administra la infra una GPO que empuje el grupo de admin a la flota y LAPS para sustituir la `localadmin` compartida. |
| Desde may. 2026 | `memory/oliver-left-maswer-no-handover.md:10` | "En julio-2026 entra a su tercer mes". |
| 14 sedes en 4 países | `memory/maswer-network-topology.md:18-47` | 9 sedes DE/ES colgando del hub central + 3 en México + 1 en EE. UU. (Alabama) + el propio datacenter = 14. Más dos regiones Azure. Una sede sigue sin identificar en el diagrama. |
| Sector automoción | `reports/drafts/2026-07-09_maswer_folder-access-p-q.md:58` · `core/identity.md:52` | Los grupos de la unidad departamental están segmentados por fabricante final. |

## Infraestructura y sistemas

| Afirmación | Fuente | Detalle |
|---|---|---|
| Reconstruí inventario y topología desde cero | `memory/maswer-servers-inventory.md:8` · `maswer-network-topology.md:8` | Inventario cruzado de dos capturas + export CSV de Defender for Endpoint (campo *Device Role*); topología a partir del diagrama Visio oficial. Marqué explícitamente qué roles están confirmados y cuáles inferidos por convención de nombres. |
| AD híbrido con DCs on-prem y en dos regiones Azure | `memory/maswer-servers-inventory.md:32-58` | 2 DCs on-prem (WS2022) + 1 DC en West Europe + 1 DC en South Central US. |
| Entra Connect, PTA en HA, Seamless SSO | `memory/maswer-servers-inventory.md:45-47` · `maswer-ad-domain-infra.md:12` | Servidor Entra Connect confirmado por tag de Defender; par de agentes PTA en alta disponibilidad; GPO *Seamless Single Sign On* en el dominio. Pass-through, no Password Hash Sync: no hay contraseñas en la nube. |
| Ciclo mensual de parcheo WS2019/2022 | `reports/drafts/2026-05-31_maswer_monthly-server-updates.md:14,23-33` | ~9 servidores en el lote; 7 actualizados y reiniciados por mí, 1 por el remitente, 1 pendiente de acceso. **Di el dato con este desglose, no como "9 servidores parcheados".** |

## Redes y seguridad perimetral

| Afirmación | Fuente | Detalle |
|---|---|---|
| Caída total de sitio, P1, respuesta en SLA de 15 min | `reports/drafts/2026-06-08_maswer_vaihingen-internet-outage-s2s-vpn.md:16-21,121` | LAN + Wi-Fi caídos a la vez → descarta APs. Firewall alcanzable desde Sophos Central → el equipo está vivo, el problema está en el camino del tráfico. |
| Causa raíz: túnel S2S caído sin failover group | `…vaihingen…md:49-58` | Única conexión configurada: *Active* en verde, *Connection* en rojo, *Failover group* sin registros. El sitio enruta su internet por ese túnel. |
| ⚠️ **Yo NO restauré el túnel** | `…vaihingen…md:64-66` | **Cuidado en entrevista.** Lo restauró el IT anterior del cliente desde su lado. Mi aportación fue el diagnóstico hasta causa raíz, la gestión del P1 y el runbook de recuperación. No cambié nada en producción. El CV dice "diagnostiqué", nunca "restablecí". |
| Runbook de recuperación y medidas preventivas | `memory/maswer-vaihingen-s2s-vpn-runbook.md:12-20` | Secuencia: verificar firewall vivo en Central → capturar logs IPsec **antes** de actuar (se pierden al recuperar) → bounce Active OFF/ON con verde en 30-60 s → si no recupera, es peer remoto o WAN. Pendientes: failover group, alerta tunnel-down, RCA del enlace. |
| 3 firewalls XGS en Sophos Central | `reports/drafts/2026-07-24_maswer_vpn-kosovo-alketa-vrella.md:57` | Todos en SFOS 21.5.0. Dato honesto: un reporte mío anterior contaba 4; lo corregí explícitamente en `:126`. Si preguntan, es un buen ejemplo de autocorrección documentada. |
| Firewall EU no enrolado en Sophos Central | `…vpn-kosovo…md:67,69` | El gateway de VPN de la región europea no aparece en Central; su consola responde en el puerto 4444 con certificado autofirmado. |
| Hub-and-spoke + VNet peering entre regiones Azure | `memory/maswer-network-topology.md:34` | Azure Alemania ↔ Azure USA por peering nativo, no por VPN. Las sedes mexicanas y la de Alabama cuelgan de Azure USA, no del hub alemán. |

## Identidad, correo y M365

| Afirmación | Fuente | Detalle |
|---|---|---|
| Cuenta de baja activa ~6 semanas y en uso por otra persona | `reports/drafts/2026-07-15_maswer_incidente-transicion-mgeisz-jan-y-adsync.md:16` | Baja el 31-may, la otra persona entra el 01-jul, detectado el 13/14-jul. |
| Traspaso con `Export-Clixml`, rename conservando SID, rollback escrito | `reports/drafts/2026-07-14_vincenzo-valle_traspaso-mgeisz-jan.md:70-155` · `2026-07-22_…kundenmaswer…md:29` | El renombrado no cambia el SID, así que el perfil de Windows se conserva. El reporte incluye bloques marcados "descartados — no ejecutar" por riesgo de reemplazar `proxyAddresses` y perder la dirección de enrutamiento. |
| Azure AD Connect parado ~18 h sin alerta | `2026-07-15_…-adsync.md:39-41,83` | Scheduler congelado desde el 14-jul 14:06, detectado el 15-jul ~08:45. Nadie se enteró: no había alerta de sync-stall. |
| Alerta Defender for Cloud *Entra Connect Sync tampering* | `2026-07-15_…-adsync.md:14-24` | Severidad Medium, disparada por mi `Restart-Service ADSync`. Verdadero positivo de una acción benigna: la clasifiqué y documenté como tal. |
| Servidor etiquetado Exchange sin Exchange instalado | `memory/maswer-servers-inventory.md:17` · `2026-07-22_…kundenmaswer…md:53-59` | Verificado el 22-jul-2026: no existe la ruta de binarios, no existe la clave de registro `…\ExchangeServer\v15\Setup`, no hay servicios `MSExchange*`, los cmdlets `*-RemoteMailbox` no están. El rol venía de la etiqueta de Defender, no de la máquina. |
| 6 buzones compartidos, sin licencia | `2026-07-14_maswer_buzones-compartidos-norman-single.md:90,95,105-111` | `New-Mailbox -Shared` + `Add-MailboxPermission` (FullAccess, automapping) + `Add-RecipientPermission` (SendAs). Quota compartida de 49,5 GB sin consumir licencia. Verificados 6/6. |
| Riesgos de gobernanza documentados | `…buzones-compartidos…md:146-169` | Cuatro: suplantación, términos de uso de portales de terceros, punto único de fallo y RGPD. |
| SPF, DKIM y 10 días de message trace sin fallos | `2026-07-21_maswer_envio-correo-service-calden.md:79-89` | Todos los mensajes `Delivered`, ni uno *Failed*, *Quarantined* ni *FilteredAsSpam*. DKIM habilitado y válido. |
| DMARC ausente | `…envio-correo…md:83,97` | `_dmarc.maswer.com` devuelve NXDOMAIN. Propuse publicar `p=none` con `rua` para empezar a medir. |

## Datos, permisos y cumplimiento

| Afirmación | Fuente | Detalle |
|---|---|---|
| 100 % de la documentación ISO 14001 recuperada, sin pérdida de datos | `reports/especiales/2026-07-02_maswer_resumen-auditor-recuperacion-datos.md:14,114-122` | Tabla de resultado: pérdida de datos **Ninguna**, impacto en otros archivos **Ninguno**, incidente de seguridad **No**. |
| Localicé el recurso real detrás de una letra de unidad | `…recuperacion-datos.md:46-57` | La usuaria solo aportó una captura con la letra. Encontré la definición del mapeo leyendo los `Drives.xml` de las GPO en SYSVOL. |
| Última instantánea VSS válida por comparación entre copias | `…recuperacion-datos.md:75-84` | Dos copias diarias. La del 15/06 12:00 tenía el archivo, la de las 18:00 ya no: esa fue la fuente de restauración. |
| Restauración desde el `DeviceObject` de la shadow copy | `…recuperacion-datos.md:90-99` | `Invoke-Command` + `Copy-Item` desde la ruta de la instantánea, sin sobrescribir nada existente. |
| Verificación por tamaño | `…recuperacion-datos.md:105-108` | 32.628 y 32.937 bytes, con sus fechas de modificación originales. |
| Log de seguridad con retención de ~6 días | `reports/especiales/2026-07-02_maswer_plan-mejoras-trazabilidad-datos.md:19` · `implement/2026-07-02_…-sacl.md:128` | Registro de ~20 MB. Por eso no se pudo determinar quién borró el archivo: la auditoría de borrado no estaba configurada y el log ya había rotado. |
| Runbook de SACL: GUID, eventos 4660/4663/4656 | `implement/2026-07-02_maswer_runbook-auditoria-borrado-sacl.md:45-46,79-87,145-151,166-173` | `auditpol` por GUID de subcategoría para evitar el error 0x57 en un servidor con Windows en español. Correlación de los tres eventos por *Handle ID*. Incluye rollback. |
| Auditoría ISO 27001:2022 + ENS, 9 sistemas, 8 escenarios | `implement/2026-06-30_maswer_preparacion-auditoria-remota.md:23-98,150-165` | ⚠️ **Digo "preparé", nunca "superamos".** El repo documenta la preparación y el ensayo (30-jun / 01-jul-2026); no consta el veredicto de la auditoría. |
| Paré accesos por segregación TISAX | `2026-07-09_maswer_folder-access-p-q.md:58` | Los grupos de esa unidad están organizados por cliente final de automoción. Concederlos en bloque habría dado acceso cruzado entre fabricantes competidores. Dejé el lote en pausa esperando criterio del cliente: **sigue abierto**. |
| 31 grupos AD aplicados a dos usuarios | `2026-07-09_…-p-q.md:44,57` | Excluí los grupos `_GL_` por indicación expresa del cliente y los `_ALL_` por precaución, hasta validar si reotorgaban acceso por otra vía. |
| 16 alertas, 0 detecciones de amenaza | `2026-07-01_maswer_gestion-alertas-evidencia-auditoria.md:57` | Todas operativas de red: túnel IPsec recurrente, un AP con PoE insuficiente, un AP offline. El valor está en saber defender la distinción entre "16 alertas abiertas" y "cero riesgo activo". |
| Cadena Sophos Central → Wazuh/Elastic → ticketing | `…gestion-alertas…md:41-50` | Ciclo de vida definido: detección, triaje, clasificación, respuesta, resolución, cierre con motivo, aprendizaje. |
| Señales de BEC en un alta | `2026-08-06_maswer_alta-kevin-santangelo.md:26-36` | Mensaje firmado por otra persona, credenciales pedidas para el solicitante y no para el titular, dispositivo personal, sin aprobador. **Caso en curso.** |
| Backup M365 con Hornetsecurity | `implement/2026-07-01_maswer_backup-m365-hornetsecurity-hallazgos.md:12-14,29-37` | Backup activo y verificado. Documenté la retención nativa de M365 (papelera 93 días, Files Restore 30 días) y por qué no equivale a una copia de seguridad. |
| Permisos por grupo de seguridad, no por ACL | `memory/maswer-access-via-ad-security-groups.md:10-17` · `2026-06-18_…-schulungsliste…md:92-95` | Patrón `<entidad>_<recurso>_<R|RW>`. El caso Schulungsliste se resolvió por pertenencia a grupo, sin tocar ACL. |

## Soporte y comunicación

| Afirmación | Fuente | Detalle |
|---|---|---|
| Tiempos de primera respuesta de 11, 37 y 42 min | `implement/2026-06-11_resumen-ejecutivo-CEO.md:112-115` | Problema de software 11 min · caída de conectividad 37 min · solicitud de acceso 42 min. Las críticas, por debajo de la hora (`:118`). |
| Ciclo completo en Freshdesk | `memory/freshworks-entity-structure.md:8-11` · `reference/classification-matrix.md:25-28` | Instancia real del MSP, con las compañías del cliente separadas por país. Matriz de SLA P1 15 min/4 h · P2 1 h/8 h · P3 4 h/2 días · P4 1 día/5 días. |
| Pipeline Markdown → Word/PDF en PowerShell | `reports/CONTEXT.md:22-24` | `build_word_report.ps1` y `convert_to_pdf.ps1` vía Word COM. Usa índices de estilo integrados en vez de nombres, para que funcione con Word en cualquier idioma. |
| Entorno trilingüe | `core/identity.md:50-56` · `core/rules.md:5-12` | Tickets en español, inglés y alemán. Los alemanes se traducen y se responden en inglés: la regla explícita es no inventar alemán. |

## Proyecto del agente

| Afirmación | Fuente | Detalle |
|---|---|---|
| 7 categorías, P1–P4, grupo y SLA | `reference/classification-matrix.md:11-17,25-28,43-47` | |
| 7 árboles de diagnóstico anclados a infra real | `reference/diagnostic-trees.md:9,37,65,90,114,139,167` · `core/rules.md:103` | La regla de anclaje es explícita: los pasos nombran el host, el grupo AD y el runbook reales, nunca boilerplate. |
| 22 plantillas bilingües | `reference/response-templates.md:16-204,218-429` | EN-1 a EN-11 y ES-1 a ES-11 en paralelo. |
| Metodología ICM | `README.md:117-119` | La estructura de carpetas es la arquitectura: en un ticket de seguridad se cargan escalado y árboles, no las plantillas comerciales. |
| Reglas de seguridad codificadas | `core/rules.md:74-79` | Nunca pedir contraseñas, nunca tocar producción sin ventana de mantenimiento, nunca improvisar ante posible incidente, nunca inventar información. |
| Licencia MIT | `README.md:134` | |

---

## Lo que NO puedo afirmar — verificado contra el repositorio

Si en una entrevista te preguntan por alguno de estos puntos, la respuesta honesta está aquí.

| No afirmar | Por qué |
|---|---|
| **"5+ años de experiencia en soporte IT"** | Es la ficha ficticia del agente en `core/identity.md:11`, no tu biografía. Tu experiencia en esta cuenta arranca en ~may. 2026. |
| **Volumen de tickets** ("X tickets/mes", "N tickets resueltos") | No existe ningún contador agregado. El único dato formal es de 2 tickets (`2026-06-11_maswer_consolidado-tickets-641-644.md:7`). Los 30 reportes son casos individuales, no un total. |
| **Porcentaje de cumplimiento de SLA** | Solo consta "2/2 Within SLA" (`…641-644.md:118-122`). Nada sostiene un "98 % de SLA". |
| **MTTA / MTTR** | Se nombran como métricas a implantar (`2026-07-01_…-auditoria.md:72-76`), nunca se midieron. |
| **Distribución 35/25/15/15/10 %** | El propio informe la declara *estimación* (`implement/2026-06-11_resumen-ejecutivo-CEO.md:124`). Úsala solo hablando, y diciendo que es una estimación. |
| **Haber superado la auditoría ISO 27001/ENS** | Solo consta la preparación y el ensayo. No hay veredicto en el repo. |
| **Número de usuarios finales del cliente** | El rango "30 a 300 empleados" de `core/identity.md:18` es el perfil genérico de cliente del agente, no el headcount real. Lo más cercano son ~24 contactos en Freshdesk. |
| **Haber restaurado el túnel de Vaihingen** | Lo restauró el IT anterior del cliente (`…vaihingen…md:64`). |
| **Trabajo del proveedor externo de infraestructura** | Hay una empresa externa que administra la infraestructura (`memory/conet-de-administers-maswer-infra.md:8`). No te atribuyas lo que ejecutan ellos. |
| **Casos abiertos como cerrados** | Siguen en curso a 13-ago-2026: VPN Kosovo, instalación STAkis, correo de la sede de Calden, unidad departamental en pausa por TISAX, alta con señales de BEC. |
