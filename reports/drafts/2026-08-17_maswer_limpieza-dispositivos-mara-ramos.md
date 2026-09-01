# Reporte del caso — Maswer / Limpieza de dispositivos obsoletos (Mara Ramos)

- **Cliente:** Maswer
- **Usuario afectado:** Mara Ramos (Entra ID)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Ticket:** sin ticket asociado — acción administrativa directa de mantenimiento
- **Estado actual:** **completado** — verificado tras ejecución

---

## Qué se hizo

Desde el centro de administración de Microsoft Entra ID, en la ficha del usuario Mara
Ramos → **Dispositivos**, se seleccionaron 7 objetos de dispositivo y se eliminaron con
la acción **Eliminar**.

**Motivo:** limpieza de objetos de dispositivo obsoletos/duplicados asociados a la
cuenta — no responde a un incidente puntual ni a una solicitud del cliente.

**Evidencia observada que respalda ese motivo:**
- Dos de los siete objetos comparten el mismo nombre de equipo, **`DESZARCLI100`** —
  patrón típico de un dispositivo que se volvió a unir a Entra sin que se retirara el
  objeto anterior.
- Tres de los siete figuran como **Habilitado: No** (`DDEBRMCLI001`,
  `DESZARCLI100`, `DESKTOP-7379LJS`), es decir, ya estaban deshabilitados antes de la
  limpieza.

## Dispositivos eliminados

| Nombre | Habilitado | SO | Versión |
|---|---|---|---|
| DESZARCLI008 | Sí | Windows | — |
| MESZAZCLI12567 | Sí | Windows | — |
| DDEBRMCLI001 | No | Windows | 10.0.19044.2006 |
| MESZARCLI1234 | Sí | Windows | — |
| DESZARCLI100 | No | Windows | 10.0.19045.3086 |
| DESZARCLI100 | Sí | Windows | — |
| DESKTOP-7379LJS | No | Windows | 10.0.19044.1889 |

Tipo de unión: Microsoft Entra (columna truncada en pantalla, a confirmar cuál variante —
*Entra joined* vs *Entra registered* — por dispositivo si se necesita para auditoría).

## Verificación

Tras confirmar la eliminación, la ficha de Mara Ramos → Dispositivos muestra
**"0 dispositivos encontrados"**. La limpieza se completó sin errores.

## Advertencia mostrada por Entra ID (a tener en cuenta)

El diálogo de confirmación de Microsoft Entra ID incluye un aviso estándar en toda
eliminación de dispositivos:

> "La eliminación de los dispositivos seleccionados afectará a todas las cuentas de
> usuario de este inquilino en los dispositivos seleccionados."

Este es el texto genérico que Microsoft muestra siempre, no una confirmación de que
estos 7 equipos fueran compartidos por otros usuarios. **No se verificó** si alguno de
los siete tenía otras cuentas registradas en el mismo dispositivo antes de eliminarlo.
Dado que 6 de los 7 nombres siguen el patrón de equipo individual de Maswer (prefijo de
sede + `CLI` + número) y solo uno queda sin ese patrón (`DESKTOP-7379LJS`, nombre por
defecto de Windows, más propio de un equipo personal/no gestionado), el riesgo de haber
afectado a un tercero se considera bajo, pero queda como punto abierto.

## Siguiente paso

- Si algún otro usuario reporta pérdida de acceso condicional, MFA registrado o
  compliance de Intune en alguno de estos 7 nombres de equipo en los próximos días,
  revisar aquí primero.
- Sin acción pendiente sobre Mara Ramos: su lista de dispositivos está limpia y
  verificada.
