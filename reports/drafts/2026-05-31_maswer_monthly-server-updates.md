# Reporte del caso — Maswer / Actualización mensual de servidores y error de sincronización

- **Cliente:** Maswer
- **Dominio:** intern.maswer.com
- **Técnicos asignados:** Sebastian Lazarte Castellón y Miguel Rubira (CoolNetworks)
- **Origen:** Correo interno reportando un error de sincronización en un servidor + actualizaciones mensuales pendientes
- **Fecha:** 31-may-2026
- **Estado actual:** mayormente resuelto · 1 servidor pendiente de confirmación (Exchange, 172.30.1.11)

---

## Contexto

Maswer tiene ~9 servidores (controladores de dominio, dos servidores `pta`, un servidor de archivos y un servidor Exchange) en el dominio `intern.maswer.com`. La actualización mensual de SO/seguridad es responsabilidad de CoolNetworks (asignada a Miguel / Sebastian). Un correo interno señaló dos puntos:

1. Un **error de sincronización** en un servidor (probablemente replicación de AD, dado que hay varios DC).
2. **Actualizaciones mensuales abiertas desde hace ~2 semanas** en la mayoría de los servidores, con la petición de mantenerlas al día.

---

## Inventario de servidores y estado de actualización

| Hostname | IP | Rol | Exposición | Resultado de la actualización |
|---|---|---|---|---|
| mderzadc003 | 192.168.0.10 | Controlador de dominio | Hoch | ✅ Actualizado + reiniciado (Sebastian) |
| mderzadc004 | 192.168.0.9 | Controlador de dominio | Hoch | ✅ Actualizado + reiniciado (Sebastian) |
| meuazdc011 | 172.30.1.8 | Controlador de dominio | Hoch | ✅ Actualizado + reiniciado (Sebastian) |
| musazdc011 | 172.20.1.4 | Controlador de dominio | Hoch | ✅ Actualizado + reiniciado (Sebastian) |
| meuazpta011 | 172.30.1.9 | Servidor (pta) | Hoch | ✅ Actualizado + reiniciado (Sebastian) |
| meuazpta012 | 172.30.1.10 | Servidor (pta) | Hoch | ✅ Actualizado + reiniciado (Sebastian) |
| mderzfil001 | 192.168.0.13 | Servidor de archivos | Sehr hoch | ✅ Actualizado + reiniciado (Sebastian) |
| meuazac011 | 172.30.1.7 | Servidor (ac) | Hoch | ✅ Hecho antes por el remitente del correo |
| meuazex001 | 172.30.1.11 | Exchange | Sehr hoch | ⚠️ Reportado como hecho por el remitente; Sebastian no pudo acceder para verificar/aplicar |

---

## Cronología

| Fecha | Evento |
|---|---|
| (previo) | Se detecta un error de sincronización en un servidor. El remitente del correo lo resuelve con actualización + reinicio → la replicación vuelve a funcionar. |
| (previo) | El remitente actualiza 172.30.1.7 (meuazac011) y reporta 172.30.1.11 (meuazex001) como hecho. Marca el resto de actualizaciones como abiertas (~2 semanas). Pide a Miguel / Sebastian mantener el parcheo mensual al día. |
| 31-may | Sebastian aplica las actualizaciones mensuales pendientes y reinicia los 7 servidores que estaban abiertos (4 DC, 2 `pta`, 1 servidor de archivos). |
| 31-may | meuazex001 (172.30.1.11, Exchange) no accesible desde el lado de Sebastian → se marca para confirmación, ya que el remitente reportó haberlo parcheado. |
| 31-may | Se envía respuesta de estado al equipo confirmando el trabajo realizado y el único punto abierto. |

---

## Trabajo realizado

### Parcheo de servidores
- Se aplicaron las actualizaciones mensuales de SO/seguridad pendientes y se reiniciaron **7 servidores** que seguían abiertos: `mderzadc003`, `mderzadc004`, `meuazdc011`, `musazdc011`, `meuazpta011`, `meuazpta012`, `mderzfil001`.
- Los cuatro controladores de dominio quedaron parcheados. En adelante, los reinicios de DC se harán **escalonados (uno a uno)** para mantener sana la replicación de AD y evitar que se repita el error de sincronización.

### Error de sincronización
- Ya remediado por el remitente del correo (actualización + reinicio) antes de este ciclo; replicación confirmada de nuevo en funcionamiento. No requiere más acción de CoolNetworks más allá de monitorizar.

### Comunicación
- 1 respuesta de estado al correo interno: se confirmaron los 7 servidores parcheados, se reconoció la corrección de sincronización, se marcó 172.30.1.11 como pendiente de acceso/confirmación y se propuso una ventana de mantenimiento mensual recurrente.

---

## Tiempo

- **Tiempo activo del técnico (estimado):** parcheo + reinicios en 7 servidores, escalonados para los DC.
- Sin esperas prolongadas por el cliente; el único bloqueo es el acceso al servidor Exchange.

---

## Estado actual y pendientes

**Estado:** mayormente resuelto · 1 servidor pendiente

**Para cerrar formalmente el ciclo:**
1. Confirmar que **172.30.1.11 / meuazex001 (Exchange)** está totalmente parcheado — o el remitente lo confirma, o da acceso a Sebastian para verificar/aplicar. *Nota: es el único servidor con exposición "Sehr hoch" ya señalada, por lo que no debería quedar sin verificar.*

**En adelante (cadencia mensual):**
2. Configurar una **ventana de mantenimiento mensual recurrente** para los servidores de Maswer, de modo que las actualizaciones no vuelvan a acumularse más allá de las ~2 semanas.
3. Mantener los reinicios de DC **escalonados** para proteger la replicación de AD.
4. Resolver la falta de acceso al host Exchange para incluirlo en la rutina mensual estándar.
