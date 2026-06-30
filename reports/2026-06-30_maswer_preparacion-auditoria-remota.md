# Maswer — Preparación de auditoría ISO 27001:2022 + ENS (alcance remoto)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 30-jun-2026
**Alcance de este documento:** lo que **yo (operación remota)** tengo que saber abrir y demostrar en vivo.
**Fuera de mi alcance (delegar):** todo lo físico/on-site (sala/CPD, acceso físico, SAI, cableado, destrucción de discos, inventario físico de Zaragoza/Abrera) y la **operación a nivel servidor del file server, que administra conet.de**.

> **Regla de oro:** todo lo que enseñe debe tener **fecha + responsable + histórico + ticket real** detrás.
> Narrar el proceso **a la vez** que abro la pantalla que lo respalda. Documentación sin pantalla = "preparado la noche anterior".

---

## Cómo usar este checklist
- Marca `[x]` cuando tengas la evidencia localizada y sepas llegar a ella en < 30 s.
- Rellena la columna **Ticket/evidencia ejemplo** con un caso real de Maswer (no inventado).
- Lleva esto en una **segunda pantalla** durante la auditoría.
- Leyenda: 🆕 = control nuevo en ISO 27001:**2022** · ⚠️ = punto débil conocido a gestionar antes.

---

## CAPA 1 — Los 9 sistemas (lo que ya contemplaba Maswer)

### 1. Microsoft 365 / Entra ID
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Entra > Usuarios | Bajas con cuenta bloqueada/eliminada | "Un exempleado: ¿cuándo se desactivó?" | |
| Entra > Roles > Global Admin | Pocos admins (2–4), todos con MFA | "¿Cuántos admin globales y por qué?" | |
| Sign-in logs / Conditional Access | MFA para TODOS, bloqueo legacy auth | "¿Hay usuarios sin MFA?" | |
| Invitados/externos | Externos justificados y vigentes | "¿Quién accede de fuera?" | |

- [ ] MFA al 100% (especial admins)
- [ ] Sin exempleados con licencia activa
- [ ] **Unified Audit Log** activado y con retención suficiente
- [ ] Cuenta **break-glass** documentada y **con alerta si se usa**

### 2. Active Directory
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| ADUC > grupos admin | Miembros mínimos y justificados | "¿Quién es Domain Admin y por qué?" | |
| Cuentas inactivas | Bajas deshabilitadas | "Cuentas sin uso, ¿deshabilitadas?" | |
| Política de contraseñas (GPO) | Complejidad/caducidad | | |
| Permisos de carpetas (ej. `MaswES_QM_RW`) | Acceso por grupos, mínimo privilegio | "¿Quién accede a esta carpeta y por qué?" | |

- [ ] **Evidencia de revisión periódica de accesos con fecha** ⚠️ (prepárala YA)

### 3. Sophos Central (AV/EDR)
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Dashboard / Devices | Cobertura ~100%, todos al día | "¿Equipos offline hace semanas?" | |
| Threat Protection policy | Política aplicada + antiransomware | | |
| Alerts | Alertas atendidas | | |
| Cifrado (si lo gestionas) | BitLocker activo | "¿Este portátil de admin, cifrado?" | |

### 4. Sophos Firewall (Zaragoza y Abrera)
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Admins + MFA | Acceso admin con MFA | | |
| Reglas de firewall | Reglas justificadas (sin any-any) | "2 reglas al azar: motivo, aprobación, fecha, última revisión" | |
| Usuarios/sesiones VPN | VPN con MFA y controlada | | |
| IPS / firmware | Al día | | |
| **Backup de configuración** | Backup reciente de cada firewall | | |
| Log de cambios | Cambios con ticket | "Un cambio reciente y su aprobación" | |

### 5. Wazuh / Elastic (SIEM)
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Agentes | Todos conectados | "¿Agentes caídos?" | |
| Una alerta concreta | **Trazabilidad completa** | "Alerta → análisis → ticket → actuación → cierre → lección aprendida" | |

### 6. Herramienta de vulnerabilidades
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Último escaneo | Ciclo escaneo→ticket→fix→reescaneo | "5 cerradas: enséñame el reescaneo" | |
| Abiertas por criticidad | Responsable y plazo | "2 abiertas: ¿responsable?" | |
| Excepciones / riesgo aceptado | Aprobadas y justificadas | "1 crítica: ¿cómo se gestionó?" | |

### 7. Copias de seguridad ⭐ (lo más importante)
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Consola de backup | Trabajos OK / fallidos, retención, cifrado | "Un trabajo fallido y cómo se gestionó" | |
| **Restauración real** del último año | Prueba en entorno controlado | "Última restauración probada" | |
| Copia externa/**inmutable** | Resistente a ransomware | "¿Copia offline ante ransomware?" | |

- [ ] Caso real listo: **recuperación de `IntAudit_ES` desde shadow copy** (ver `2026-06-29_maswer_recuperacion-intaudit-es-iso14001`)
- [ ] ⚠️ Shadow copies **≠ backup completo** → enseñar también el backup "de verdad" con su restauración probada

### 8. Ticketing / soporte
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Tickets de incidentes/altas/bajas/cambios | Trazabilidad `solicitud → autorización → ejecución → validación → cierre` | "Enséñame el ticket de este cambio" | |

- [ ] Nada hecho "a mano" sin ticket (sería falta de control de cambios)

### 9. SharePoint / servidor de ficheros
| Abrir en vivo | Qué demostrar | Te preguntarán | Ticket/evidencia ejemplo |
|---|---|---|---|
| Permisos de carpetas críticas | Control y revisión | "¿Quién accede a esta carpeta sensible?" | |
| Usuarios externos / enlaces compartidos | Caducidad y control | | |

- [ ] ⚠️ **Hallazgo conocido del file server:** SACL de auditoría vacía + log de seguridad retiene ~6 días → ir por delante: *"detectado en un incidente real, escalado a conet.de, corrección propuesta (activar SACL + ampliar/reenviar logs a colector)"*.

---

## CAPA 2 — Controles 2022 que el documento de Maswer NO contemplaba

### Parches y configuración
- [ ] **Patch management (A.8.8):** WSUS/Intune/Sophos Patch → **% de cumplimiento** servidores y endpoints + cadencia de críticos
- [ ] 🆕 **Configuración segura (A.8.9):** baseline/hardening (GPO de seguridad, CIS/CCN-STIC, perfil Intune) — *"¿cómo nace endurecido un servidor nuevo?"*
- [ ] 🆕 **Software instalado / control de aplicaciones (A.8.19):** quién instala, allowlisting
- [ ] **Sincronización de relojes (A.8.17):** fuente NTP definida (necesaria para correlación de logs)

### Accesos privilegiados (más fino que "admins")
- [ ] **A.8.2:** cuentas admin **separadas** de las de usuario; admin no navega/usa correo con cuenta privilegiada
- [ ] **LAPS** para contraseña de admin local por equipo
- [ ] **Cuentas de servicio:** dónde se guardan credenciales, rotación
- [ ] **Break-glass** excluida de MFA pero **monitorizada con alerta**

### Email y web
- [ ] Anti-phishing/anti-spam (Defender O365 / Sophos) + **SPF/DKIM/DMARC** publicados
- [ ] 🆕 **Filtrado web (A.8.23):** política de categorías bloqueadas en Sophos

### Datos: clasificación, cifrado, fuga
- [ ] **Clasificación/etiquetado (A.5.12/A.5.13):** etiquetas de sensibilidad M365 (o respuesta si no hay)
- [ ] 🆕 **DLP (A.8.12):** una **regla concreta** + a ser posible un **evento real bloqueado**
- [ ] 🆕 **Criptografía (A.8.24):** BitLocker, TLS y **monitorización de caducidad de certificados/dominios**
- [ ] **Transferencia de información (A.5.14):** envío seguro de ficheros sensibles (no WeTransfer personal)

### Red
- [ ] 🆕 **Segregación de redes (A.8.22):** VLANs, **wifi invitados separada**, red de servidores aislada → tener diagrama lógico

### Continuidad e incidentes (profundizar más que el doc)
- [ ] 🆕 **Preparación TIC para continuidad (A.5.30):** prueba de **failover/DR** (no solo restaurar un fichero); RTO/RPO declarados vs. medidos
- [ ] **Respuesta a incidentes (A.5.24–A.5.28):** plan de IR + 🆕 **recopilación de evidencias (A.5.28)** — el caso del Excel borrado sirve de mini-ejemplo
- [ ] 🆕 **Inteligencia de amenazas (A.5.7):** cómo recibo/actúo sobre advisories (fabricantes, **CCN-CERT**)

### Endpoints y movilidad
- [ ] 🆕 **Dispositivos de usuario (A.8.1) / MDM:** cumplimiento Intune, móviles gestionados, BYOD
- [ ] **Teletrabajo (A.6.7):** VPN con MFA, equipo corporativo vs personal

### Otros
- [ ] **Pentest:** último informe y seguimiento de hallazgos (si se contrata)
- [ ] ⚠️ **Backup de M365:** Microsoft **no** hace backup por defecto → tener respuesta (copia de terceros / retención / retención legal)

---

## CAPA 3 — Escenarios "en vivo" que el auditor plantea de viva voz

> No quiere un PDF: quiere que **narre el proceso Y abra la evidencia** a la vez. Guion preparado para cada uno.

- [ ] **1. Baja de empleado hoy a las 17:00 → offboarding paso a paso**
  Ticket → desactivar cuenta (Entra/AD) → revocar sesiones/MFA → quitar de grupos → retener/reasignar datos → **devolución de equipo (A.5.11)** → cierre.
- [ ] **2. Ransomware esta noche → ¿qué pasa?**
  Detección (Sophos/Wazuh) → aislamiento → plan IR → **restauración desde copia inmutable/offline** → RTO/RPO.
- [ ] **3. Robo/pérdida de portátil de usuario privilegiado**
  BitLocker (dato no expuesto) → wipe remoto Intune → baja en inventario/Sophos → cambio de credenciales.
- [ ] **4. CVE crítico en el firewall Sophos → ¿qué haces y en cuánto?**
  Aviso (threat intel) → evaluación → ticket → parche/mitigación en plazo → reescaneo.
- [ ] **5. Petición de acceso a carpeta sensible → flujo completo**
  solicitud → **autorización del propietario del dato** → ejecución → validación → cierre (ej. `QM` / `MaswES_QM_RW`).
- [ ] **6. Inicio de sesión imposible (viaje imposible) en Entra**
  Conditional Access / Identity Protection → alerta de riesgo → bloqueo/reset → ticket.
- [ ] **7. Demuéstrame un cambio controlado (A.8.32)**
  cambio de firewall/servidor con solicitud, aprobación, ventana, rollback y registro.
- [ ] **8. Tabletop de un riesgo del análisis de riesgos**
  ej. "acceso indebido a SharePoint": riesgo → control → **evidencia técnica** → responsable → revisión periódica.

---

## CAPA 4 — Si también es auditoría ENS (RD 311/2022)

El documento de Maswer cita **categorización ENS y matriz de medidas** → es ISO 27001 **+ ENS**. Parte que suele llevar el responsable de seguridad/SGSI de Maswer, pero conviene saber qué es:

- [ ] **Categorización del sistema** (Básica/Media/Alta)
- [ ] **Declaración de Aplicabilidad ENS** (distinta de la de 27001)
- [ ] **Perfil de cumplimiento** + matriz de medidas del Anexo II
- [ ] Herramientas **CCN-STIC**: **PILAR** (riesgos), **CLARA/microCLARA** (hardening contra CCN-STIC 599), **ROCÍO** (red), **GLORIA/LUCÍA** (incidentes)
- [ ] Relación con **CCN-CERT** para notificación de incidentes
- [ ] Conformidad con guías **CCN-STIC** de la categoría

> Si no domino esta capa, dejar claro: yo llevo la **operación técnica**; la documentación ENS la lleva el **responsable de seguridad de Maswer**.

---

## CAPA 5 — Solapamiento RGPD (de mi propio caso)

- [ ] `H_Necesidades_de_formación_2026.xlsx` **contiene datos personales** (formación de trabajadores).
- [ ] Encuadre listo: control de acceso a datos personales + valoración de la pérdida como posible **brecha** (y notificación 72 h si procediera). No convertir el informe técnico en confesión de brecha, pero tener claro el marco.

---

## Las 5 que NO puedo fallar (si voy justo de tiempo)
1. [ ] **MFA en todos**, sobre todo admins.
2. [ ] **Sophos** con cobertura total y al día.
3. [ ] **Firewall** configurado, VPN con MFA y **backup de config**.
4. [ ] **Backups verificados con restauración real**.
5. [ ] **Vulnerabilidades e incidentes con tickets reales y cierre**.

---

## Acciones correctivas a cerrar/documentar ANTES de la auditoría
1. [ ] ⚠️ Revisión periódica de accesos **hecha y con fecha** (grupos AD / M365).
2. [ ] ⚠️ File server `MDERZFIL001`: **SACL de auditoría + retención de logs** — escalado a conet.de documentado (ver `2026-06-23_maswer_recuperacion-accesos-post-oliver` y `2026-06-29_maswer_recuperacion-intaudit-es-iso14001`).
3. [ ] Confirmar **backup de M365** (o respuesta justificada).
4. [ ] Verificar **monitorización de caducidad de certificados**.
5. [ ] Confirmar **break-glass** con alerta de uso.

---

*Relacionado:* `2026-06-29_maswer_recuperacion-intaudit-es-iso14001.md` · `2026-06-23_maswer_recuperacion-accesos-post-oliver`
