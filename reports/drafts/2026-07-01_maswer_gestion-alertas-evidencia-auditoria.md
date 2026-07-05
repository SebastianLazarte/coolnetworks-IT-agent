# Maswer — Gestión de alertas de seguridad: cómo se maneja y cómo respaldarlo en la auditoría

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 01-jul-2026
**Propósito:** dar respaldo argumental y de proceso a lo que se enseña en el bloque 3 (Sophos Central) y 5 (Wazuh) del guion de auditoría. No es "tenemos pocas alertas", es "tenemos un **proceso** de gestión de alertas y aquí está la evidencia".

> Acompaña a `2026-06-30_maswer_ensayo-auditoria-paso-a-paso.md`.
> Nota de método: elaborado con conocimiento general de gestión de eventos de seguridad + el entorno real de Maswer. Los controles ISO/NIST citados son marcos públicos de referencia.

---

## 1. La idea que un auditor quiere ver (no la que crees)
El auditor **no** valora "cero alertas" — un tablero en cero suele significar que **nadie mira**, no que todo esté bien. Lo que valora es que exista un **ciclo de vida de la alerta gestionado y trazable**:

> **Detección → Triaje → Clasificación → Respuesta → Resolución → Cierre con motivo → Aprendizaje.**

Una alerta abierta con una explicación y un ticket **suma**; una alerta cerrada a las bravas sin verificar **resta**. Tu objetivo en la demo es demostrar el **ciclo**, no un número bonito.

---

## 2. El ciclo de vida de una alerta (el modelo que respalda tu demo)

| Fase | Qué significa | Dónde se ve en TU entorno |
|---|---|---|
| **1. Detección** | La herramienta genera el evento | Sophos Central (endpoint/firewall/wireless), Wazuh (SIEM), firewalls Sophos |
| **2. Triaje** | ¿Es real? ¿Es de seguridad u operativa? ¿Urgencia? | Revisión en consola + severidad (alta/media/baja) |
| **3. Clasificación** | Amenaza vs operativo vs falso positivo | Ver §4 |
| **4. Respuesta** | Acción: contener, corregir, escalar | Ticket + actuación (o escalado a conet.de / N2) |
| **5. Resolución** | El problema deja de existir | Verificar **estado ACTUAL del dispositivo**, no solo la alerta |
| **6. Cierre** | Reconocer la alerta **con motivo** | Sophos: "Reconocer"; Wazuh: cierre del caso; ticket cerrado |
| **7. Aprendizaje** | ¿Se repite? ¿Hay que cambiar algo? | Alertas recurrentes → causa raíz (ej. túnel Hockenheim) |

**Clave de la fase 5–6:** en Sophos Central una alerta puede seguir "abierta" aunque el problema ya esté resuelto (no todas se auto-limpian). Por eso el cierre correcto es: **verificar el estado actual del dispositivo → si está sano, reconocer con motivo → si sigue mal, mantener abierta con ticket.** Nunca reconocer en masa a ciegas.

---

## 3. Cómo se traduce a lo que TÚ tienes (la arquitectura que enseñas)
Maswer no tiene una sola fuente de alertas, tiene una **cadena** — y eso es una fortaleza si la narras bien:

```
Sophos Central ──┐
Firewalls Sophos ─┼──► (eventos) ──► Wazuh/Elastic (SIEM, correlación) ──► Ticketing ──► Cierre
Wireless APs ─────┘                                     │
                                                        └──► Escalado: conet.de (infra) / N2 Cybersecurity
```

- **Sophos Central** = detección en endpoint, firewall y red (primera línea).
- **Wazuh** = centralización y correlación de eventos (el "cerebro" que da trazabilidad — bloque 5).
- **Ticketing** = el hilo conductor: toda alerta relevante deja rastro solicitud→acción→cierre (bloque 8).
- **Escalado** = lo que no operas tú va a conet.de (infra/servidor) o a N2 Cybersecurity (posible incidente).

**Frase de respaldo:** *"No dependemos de una única herramienta ni de la memoria de una persona: la detección es multicapa, la correlación está centralizada en Wazuh y todo cierre queda trazado en ticketing."*

---

## 4. Clasificación: seguridad vs operativa (tu caso real)
El punto **más fuerte** de tu tablero actual: de 16 alertas, **0 son detecciones de amenaza**. Todas son **operativas de red**. Hay que saber defender esa distinción, porque es lo que convierte "16 alertas abiertas" en "cero riesgo de seguridad activo".

| Tipo | Ejemplos en tu tablero | Cómo se trata |
|---|---|---|
| **Amenaza de seguridad** | (ninguna ahora) malware, ransomware, EDR, login sospechoso | Plan de incidentes, contención, posible escalado N2 |
| **Operativa / disponibilidad** | AP offline, PoE insuficiente, gateway del AP, túnel S2S renegociando | Ticket de infra, corrección, verificación |
| **Falso positivo / ruido** | alertas que auto-resuelven | Reconocer con nota; si se repite, ajustar umbral |

**Frase de respaldo:** *"Separamos alertas de amenaza de alertas operativas. Ahora mismo no hay ninguna detección de amenaza activa; lo abierto es disponibilidad de red — un AP sin PoE, otro offline y un túnel VPN de sede renegociando— y está en el circuito de tickets de infraestructura."*

---

## 5. Métricas que respaldan madurez (aunque sean cualitativas)
No necesitas un cuadro de mando perfecto; sí demostrar que **piensas en estos términos**:

- **MTTA (tiempo medio de reconocimiento):** ¿cuánto tardas en ver/atender una alerta?
- **MTTR (tiempo medio de resolución):** de detección a cierre.
- **Backlog y antigüedad:** cuántas abiertas y desde cuándo (una alerta de hace semanas necesita explicación — es tu caso con el AP offline del 19-jun).
- **Recurrencia:** una misma alerta repetida = síntoma de causa raíz no resuelta (túnel Hockenheim aparece 2 veces → o es corte del ISP de la sede, o hay que estabilizar el túnel).
- **Tendencia:** ¿suben o bajan las alertas mes a mes?

**Frase de respaldo:** *"Vigilamos no solo el número, sino la antigüedad y la recurrencia: una alerta repetida la tratamos como causa raíz, no como incidencia suelta."*

---

## 6. Qué evidencia concreta enseñar (checklist para el directo)
Para **cada** alerta que el auditor abra, deberías poder mostrar 3 de estas 5 cosas:

- [ ] **Severidad y fecha** (que el sistema clasifica solo).
- [ ] **Estado actual del dispositivo** (que verificas antes de cerrar).
- [ ] **Ticket asociado** (solicitud → acción → cierre).
- [ ] **Motivo del cierre / reconocimiento** (por qué se cerró).
- [ ] **Correlación en Wazuh** (si es de seguridad, la traza completa).

Si de una alerta puedes enseñar esto, el control está **demostrado**, no solo afirmado.

---

## 7. Mapeo a estándares (la vara con la que te miden)
Tu proceso encaja con controles reconocidos. No hace falta recitarlos, pero tenerlos claros da seguridad y credibilidad:

**ISO/IEC 27001:2022 — Anexo A:**
- **A.5.24** Planificación y preparación de la gestión de incidentes.
- **A.5.25** Evaluación y decisión sobre eventos de seguridad ← *esto es exactamente el triaje de alertas*.
- **A.5.26** Respuesta a incidentes.
- **A.5.27** Aprendizaje de incidentes ← *recurrencia / causa raíz*.
- **A.8.15** Registro (logging).
- **A.8.16** Actividades de monitorización ← *el propio hecho de vigilar Sophos/Wazuh*.

**NIST CSF 2.0:**
- **Detect (DE):** detección continua (Sophos + Wazuh).
- **Respond (RS):** triaje, análisis, mitigación, comunicación (ticketing + escalado).

**Frase de respaldo:** *"El circuito alerta→triaje→respuesta→aprendizaje se alinea con A.5.25 y A.5.27 de ISO 27001 y con las funciones Detect y Respond de NIST."*

---

## 8. Tus alertas actuales — clasificadas y defendidas
Prepara esto **antes** del directo (verifica estado actual y rellena ticket/motivo):

| Alerta | Clasificación | Estado a verificar | Defensa preparada |
|---|---|---|---|
| `S2S_Hockenheim-1` IPSec (Jul 1 y Jun 21) | Operativa / VPN — **recurrente** | ¿Túnel UP ahora? (Firewall > VPN) | "Renegociación del túnel de la sede Hockenheim; causa = [corte ISP / estabilidad]; en seguimiento, ticket #___. Enlaza con runbook S2S." |
| `APXD…` gateway IP | Operativa / WiFi — **alta** | ¿AP con conectividad ahora? | "AP no alcanzaba su gateway; corregido/en ticket #___." |
| `AP6DECAL01` PoE insuficiente | Operativa / WiFi — **alta** | ¿AP alimentado y online ahora? | "Puerto PoE/switch sin potencia suficiente; cambio de puerto/switch en ticket #___." |
| `AP6DEHEF01` offline (Jun 19) | Operativa / WiFi | ¿Online ahora? (lleva ~12 días) | "AP retirado/en reparación / sede sin uso; ticket #___." **No dejarlo sin explicación.** |

---

## 9. Errores que restan (evítalos)
- ❌ **Reconocer en masa** para dejar el contador en 0 sin verificar → si el auditor abre una y el equipo sigue caído, pierdes credibilidad.
- ❌ Presentar "16 alertas" sin la distinción amenaza/operativa → parece descontrol.
- ❌ No tener explicación de la alerta **más antigua** (la del AP offline) → es la primera que pincha un auditor.
- ❌ Confundir "alerta cerrada" con "problema resuelto" → siempre verifica el **estado actual del dispositivo**.
- ❌ Improvisar sobre una alerta que resulte ser de seguridad → si aparece una amenaza real sin ticket, **escala a N2**, no la minimices.

---

## 10. Resumen de una frase (para abrir el bloque 3)
> *"No medimos seguridad por tener el tablero en cero, sino por tener un proceso: cada alerta se clasifica (amenaza u operativa), se verifica contra el estado real del dispositivo, se resuelve con ticket y se cierra con motivo. Hoy no hay ninguna amenaza activa; lo abierto es operativo de red y está trazado."*

---

*Relacionado:* `2026-06-30_maswer_ensayo-auditoria-paso-a-paso.md` · `2026-06-30_maswer_preparacion-auditoria-remota.md` · runbook S2S VPN
