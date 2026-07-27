# PLAN DE MEJORAS — TRAZABILIDAD Y PROTECCIÓN DE DATOS

**Cliente:** Maswer Spain S.L.
**Área:** Calidad / Documentación ISO (unidad `R:` — `QM\ISO 14001 Spain`)
**Preparado por:** CoolNetworks — Soporte IT
**Fecha:** 2 de julio de 2026
**Origen:** acción correctiva derivada de la contingencia de recuperación de datos (junio 2026)

---

## Contexto

La contingencia se resolvió con éxito y sin pérdida de datos. No obstante, durante la
investigación se identificaron dos aspectos que conviene reforzar para el futuro:

1. **No fue posible determinar con certeza quién eliminó el archivo**, por la configuración
   de auditoría existente en la carpeta.
2. **La retención del registro de seguridad es corta** (~6 días), lo que limita el margen
   para investigar hechos pasados.

Este documento recoge las mejoras previstas para cerrar esos puntos.

---

## Mejoras previstas

### 1. Auditoría de borrado a nivel de carpeta (SACL)
Activar el registro de eliminaciones sobre la estructura `QM`, de modo que cualquier borrado
quede asociado a **usuario, archivo y fecha/hora**.

- **Qué aporta:** trazabilidad completa de futuros borrados.
- **Alcance:** carpeta `QM` con herencia a todas las subcarpetas ISO.
- **Impacto en servicio:** ninguno (no requiere corte ni ventana de mantenimiento).

### 2. Ampliación de la retención del registro de seguridad
Aumentar el tamaño del log de seguridad del servidor y valorar su reenvío a un sistema de
recolección centralizado (SIEM).

- **Qué aporta:** capacidad de investigar incidentes de días o semanas atrás.
- **Impacto en servicio:** ninguno.

### 3. Verificación de la política de auditoría por directiva (GPO)
Confirmar que la auditoría de acceso a ficheros queda fijada de forma permanente por política
de dominio, para que no dependa de configuraciones locales.

### 4. Revisión de las copias de seguridad (instantáneas de volumen)
Confirmar frecuencia y retención de las copias que permitieron la recuperación, para asegurar
que se mantiene un margen adecuado de restauración.

---

## Resumen de acciones

| # | Acción | Beneficio | Impacto en servicio |
|---|---|---|---|
| 1 | Auditoría de borrado (SACL) en `QM` | Saber quién/cuándo se borra | Ninguno |
| 2 | Ampliar retención del log / SIEM | Investigar hechos pasados | Ninguno |
| 3 | Fijar auditoría por GPO | Configuración permanente | Ninguno |
| 4 | Revisar copias de seguridad | Margen de recuperación | Ninguno |

---

## Consideraciones de ejecución

- Las acciones 1–3 requieren permisos de administración a nivel de servidor. Según el modelo
  de gestión actual, los cambios de configuración a ese nivel en la infraestructura de Maswer
  los administra el proveedor **conet.de**; CoolNetworks aporta el procedimiento técnico detallado.
- Ninguna de las acciones interrumpe el servicio ni requiere ventana de mantenimiento.
- El procedimiento técnico paso a paso está documentado internamente y disponible para su ejecución.

---

*Documento preparado por CoolNetworks · 2 de julio de 2026.*
