# Reporte de caso — Maswer GmbH (Vaihingen) / Caída total de internet — túnel S2S_Vaihingen

- **Cliente:** Maswer GmbH (Maswer Alemania — Vaihingen an der Enz)
- **Contacto:** Alketa Vrella
- **Infraestructura clave:** Sophos XGS (`admin@XGSDEVAI01`, serial X125058C8GJ8H51, gestionado vía Sophos Central) · túnel IPsec **S2S_Vaihingen** (route-based, perfil `S2SVaihingen`)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha:** 08-Jun-2026
- **Estado actual:** **Resuelto** (sitio online) · pendientes de prevención abiertos para N2 Sistemas

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Red e Infraestructura |
| Prioridad | P1 - Crítica (caída total de sitio, negocio parado) |
| Grupo | N1 primer contacto → N2 Sistemas |
| SLA inicial | Respuesta en 15 min · resolución objetivo 4 h |
| Idioma del ticket | Alemán → respuesta en inglés (no inventamos alemán) |
| Empresa en Freshdesk | Maswer Alemania (confirmar mapeo del contacto) |

---

## Cómo llegó el caso

1. **Primer aviso por WhatsApp** (canal fuera de plataforma). Alketa indica que cree haber abierto un ticket previo y que el Wi-Fi está caído desde por la mañana, no pueden trabajar.
2. **Segundo mensaje, ya en el ticket, en alemán.** Aporta dato clave nuevo: **no hay internet ni por Wi-Fi ni por cable LAN**. Solicita explícitamente envío de técnico in situ.

Acción de N1:
- Consolidar en un único ticket (sin abrir duplicados).
- Redirigir educadamente desde WhatsApp al portal de soporte (donde están las herramientas de diagnóstico).
- Confirmar que el contacto está mapeado a la compañía **Maswer Alemania**.

---

## Diagnóstico inicial

- Caída total de sitio, **LAN + Wi-Fi simultáneamente** → descarta fallo solo de Wi-Fi (APs/controladora).
- Apunta a **enlace WAN/ISP** o **firewall perimetral / routing**.
- El **firewall Sophos XGS sigue alcanzable vía Sophos Central** → el dispositivo está vivo, el problema está en el camino del tráfico, no en el equipo.

---

## Hallazgo en Sophos XGS (Site-to-site VPN → IPsec)

Una única conexión configurada:

| Campo | Valor |
|---|---|
| Nombre | **S2S_Vaihingen** |
| Perfil | `S2SVaihingen` |
| Tipo | **Route-based (Tunnel interface)** |
| Active | 🟢 verde (habilitado administrativamente) |
| **Connection** | 🔴 **rojo (túnel caído, no establecido)** |
| Failover group | *Sin registros* |

**Causa raíz muy probable:** el sitio enruta su tráfico/internet a través del túnel S2S_Vaihingen. Túnel caído + sin grupo de failover = sitio entero sin internet por LAN y Wi-Fi. Encaja al 100% con los síntomas.

---

## Resolución

- El IT anterior del cliente, **Oliver**, restauró el túnel desde su lado.
- Verificado: **Connection en verde, internet de vuelta en Maswer Vaihingen.**
- No se ejecutaron cambios en producción desde CoolNetworks durante este incidente.

---

## Comunicaciones enviadas

1. **Acuse inicial al cliente (inglés, en el ticket).** Confirmación de criticidad, consolidación con el aviso de WhatsApp, preguntas operativas mínimas (luces del router/firewall, alcance).
2. **Mensaje en WhatsApp.** Redirección proactiva al ticket, sin preguntar permiso: instrucciones claras (abrir el ticket, mirar la respuesta, enviar las fotos) y oferta de llamada como respaldo.
3. **Email de agradecimiento a Oliver (no técnico).** Breve: gracias por resolverlo, confirmación de que queda documentado por nuestra parte.

---

## Línea de tiempo

| Fecha / hora | Evento |
|---|---|
| 08-Jun, mañana | Inicio de la caída en Maswer Vaihingen (LAN + Wi-Fi). |
| 08-Jun | Alketa contacta por WhatsApp pidiendo ayuda urgente. |
| 08-Jun | Llega mensaje en alemán al ticket: confirma caída de LAN además de Wi-Fi; pide técnico in situ. |
| 08-Jun | N1 clasifica como P1, redirige a la plataforma, prepara escalado a N2 Sistemas. |
| 08-Jun | Revisión del Sophos XGS → S2S_Vaihingen con Connection en rojo identificado como causa raíz probable. |
| 08-Jun | Oliver (IT previo del cliente) restablece el túnel. Sitio recupera internet. |
| 08-Jun | Email de agradecimiento a Oliver. Runbook documentado en memoria del agente. |

---

## Pendientes (prevención — para N2 Sistemas)

El "bounce" del túnel es primeros auxilios, no la cura. Si no se cierran estos puntos, el incidente se va a repetir:

1. **Configurar un Failover group** en el Sophos para el sitio de Vaihingen. Sin camino de respaldo, una sola caída del túnel = sitio entero a oscuras.
2. **Alerta de tunnel-down** en Sophos Central o en el RMM. Hoy el monitor es el cliente: nos enteramos cuando ya están parados.
3. **Análisis de causa raíz del túnel:**
   - Revisar el perfil `S2SVaihingen` (IKE, lifetimes, DPD, rekey).
   - Estabilidad de la línea ISP en ambos extremos.
   - IP WAN dinámica en el peer sin DDNS, fragmentación/MTU.
4. **Confirmar la ruta por defecto** del sitio: ¿realmente todo el tráfico de Vaihingen sale por este túnel? Documentarlo.
5. **Definir si WhatsApp es canal de soporte acordado para Maswer Alemania.** Si no lo es, dejarlo por escrito para no normalizar avisos P1 fuera de plataforma.

---

## Runbook de recuperación (si vuelve a caer)

Guardado en memoria del agente: [`maswer-vaihingen-s2s-vpn-runbook.md`](../memory/maswer-vaihingen-s2s-vpn-runbook.md).

Resumen operativo:
1. Confirmar firewall alcanzable en Sophos Central + `S2S_Vaihingen` Connection en rojo.
2. **Capturar logs IPsec antes de tocar nada** (desaparecen al recuperar el túnel).
3. Bounce del túnel: Active OFF → esperar ~10 s → ON. Renegocia Phase 1 + 2; vuelve verde en 30–60 s. **Requiere "ok" explícito del cliente registrado en el ticket** (regla N1: producción solo en P1 con autorización).
4. Si no recupera → escalar **N2 Sistemas, P1** con logs + estado de WAN.

---

## Notas de proceso

- Clasificación y respuesta dentro del SLA de P1 (15 min).
- Cero modificaciones en producción desde CoolNetworks → sin riesgo añadido al incidente.
- Redirección de canal (WhatsApp → portal) realizada de forma proactiva, sin pedir permiso, manteniendo la sensación de acompañamiento.
- Conocimiento del entorno del cliente capturado en memoria para futuros incidentes del mismo patrón.
