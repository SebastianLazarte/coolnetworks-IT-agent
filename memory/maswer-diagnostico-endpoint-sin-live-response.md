---
name: maswer-diagnostico-endpoint-sin-live-response
description: Qué consolas sirven y cuáles no para diagnosticar un portátil de Maswer sin sesión remota — Live Response apagado en el tenant, Remediations y Device query sin licencia; la vía que funciona es Script de plataforma + Recopilar diagnósticos.
metadata:
  type: reference
---

Verificado el **3-sep-2026** durante el caso del portátil `OORTH` ([[oorth-portatil-heredado-stefanie-zimmermann]]).

## Paso 0 — de la persona al nombre del equipo

El inventario de Defender **busca por nombre de máquina, no por usuario**, y los equipos de Maswer no llevan el nombre de la persona (buscar "ZIMMERMAN" devuelve 0 resultados). Rutas válidas:

- `admin.microsoft.com` → **Usuarios** → [persona] → pestaña **Dispositivos** → nombre, modelo, build, fecha de registro, última conexión. La más rápida.
- Defender → **Advanced hunting**: `DeviceLogonEvents` filtrando por `AccountName`, o `DeviceInfo` por `Model`.

## Lo que SÍ se puede hacer (solo lectura, sin tocar el equipo)

| Consola | Qué da |
|---|---|
| Defender → Assets → Devices → ficha del equipo | Primary user, dominio, SO/build, logons de 30 días, alertas e incidentes |
| ficha → **Inventories** | software y hardware/firmware instalado, versiones de drivers |
| ficha → **Discovered vulnerabilities** / **Missing KBs** | CVEs por severidad, parches pendientes |
| Intune → ficha del equipo → **Hardware** | RAM, almacenamiento total y libre, número de serie |
| Intune → ficha → `...` → **Recopilar diagnósticos** | ZIP con registros de eventos y logs (incluida la carpeta de logs del IME). Sin script ni licencia extra |

## Lo que NO está disponible en este tenant

- **Live Response** → `Failed to create a Live Response session — Live Response tenant setting is disabled`. El toggle está en `Settings → Endpoints → General → Advanced features`. Abrir esa página por URL directa **redirige a Home en silencio si falta el permiso Manage Portal Settings** (Security o Global Administrator). Y si la base es **Defender for Business** (licencia Microsoft 365 Business), *Live response unsigned script execution* directamente **no existe** → no se pueden ejecutar `.ps1` propios ni encendiendo el toggle.
- **Intune → Correcciones (Remediations)** → exige Windows Enterprise E3/E5, Education A3/A5 o Windows VDA. Microsoft 365 Business no está en la lista.
- **Intune → Consulta de dispositivos (Device query)** → editor en solo lectura; requiere el complemento de pago *Análisis avanzado de Intune*.

## La única vía para ejecutar código en un endpoint

```
Intune → Dispositivos → Administrar dispositivos → Scripts y correcciones
      → Scripts de plataforma → Agregar → Windows 10 y posterior
```
- *Ejecutar con las credenciales de inicio de sesión*: **No** (así corre como SYSTEM) · *Aplicar comprobación de firma*: **No** · *PowerShell de 64 bits*: **Sí**
- Se asigna **solo a grupos**, no a equipos sueltos → crear un grupo de Entra con el equipo dentro.
- **No devuelve la salida al portal.** El script escribe a fichero y se recoge después con **Recopilar diagnósticos**.

## Trampa de idioma (portátiles alemanes)

Los contadores de rendimiento están traducidos, así que `Get-Counter '\Memory\Pool Nonpaged Bytes'` **falla**. Usar WMI, que es independiente del idioma:

```powershell
$m = Get-CimInstance Win32_PerfRawData_PerfOS_Memory
[int]($m.PoolNonpagedBytes/1MB); [int]($m.PoolPagedBytes/1MB); $m.AvailableMBytes
```

**Why:** el plan "abro Live Response y saco un poolmon" se cayó tres veces seguidas por toggle, por permisos y por licencia. Sin este mapa se repite el mismo recorrido en cada ticket de endpoint.

**How to apply:** en cualquier ticket de rendimiento o diagnóstico de un equipo de usuario, empezar por la tabla de solo lectura — a menudo cierra el caso sin ejecutar nada. Si hace falta ejecutar, ir directo a Scripts de plataforma y olvidarse de Live Response. Si de verdad se necesita Live Response, es una petición de licencia/rol, no un clic: pasa por [[conet-de-administers-maswer-infra]]. Encaja con [[remote-access-teamviewer-fails-fallback-anydesk]]: sigue sin haber una herramienta desatendida estándar en la flota.
