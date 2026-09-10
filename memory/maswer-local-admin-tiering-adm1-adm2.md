---
name: maswer-local-admin-tiering-adm1-adm2
description: "Maswer YA tiene admin local en la flota por GPO: adm1-Administrators → OU=Server, adm2-Administrators → OU=Clients. Sebastian ya era admin de 472/513 equipos; el bloqueo de UAC no era falta de permisos sino el deny de logon interactivo de adm1 en clientes."
metadata:
  type: reference
---

Verificado el **09-sep-2026** contra `intern.maswer.com`, al investigar cómo darle admin
de flota al técnico. **Resultó que ya lo tenía.** El mecanismo lo montó conet y lleva años puesto.

## El modelo de tiers que ya existe

```
adm1-Administrators  --[GPO LocalAdminRights_adm1]-->  BUILTIN\Administrators   enlace: OU=Server    14 equipos
adm2-Administrators  --[GPO LocalAdminRights_adm2]-->  BUILTIN\Administrators   enlace: OU=Clients  458 equipos
```

Ambas GPO usan **Restricted Groups en forma "Memberof"** (el grupo de dominio se hace miembro
del grupo local `S-1-5-32-544`). Estado `AllSettingsEnabled`, permiso **Aplicar a Usuarios
autenticados**, **sin filtro WMI**, y **ninguna OU del dominio tiene herencia bloqueada**
(`gPOptions=1` → 0 resultados). Es decir: aplican a todo lo que cuelga de esas dos OUs.

`IT-Support-Germany` (cuenta de diario de Sebastian) **ya era miembro de los dos grupos**.
Comprobado en real desde su sesión: `\\MDERZFIL001\C$` y `\\MDERZADC003\admin$` responden.

## La trampa: el deny de tier mata la elevación en clientes

```
GPO DenyLocalLogon_adm0_adm1  → enlazada en OU=Clients [ACTIVO]
    SeDenyInteractiveLogonRight → adm1-Administrators, adm0-Administrators
```

El diseño es correcto (tier servidor no pisa puestos), pero **la cuenta de diario estaba en los
dos tiers a la vez**: `adm2` la hacía administradora del cliente y `adm1` le denegaba el logon
interactivo en ese mismo cliente. **Deny gana siempre.**

Eso explica el fallo de elevación de UAC en máquinas de usuario — la **Autenticación de Windows**
de TeamViewer/AnyDesk es un logon de tipo interactivo, así que cae en ese deny. Es la causa
probable de los fallos del caso Carroccia y del piloto de STAkis, no la ausencia de derechos.
**Hipótesis fuerte, pendiente de confirmar con `gpresult /r` en un cliente piloto.**

Otras GPO del modelo: `DenyLocalLogon_adm0` y `DenyRDPLogon_adm0` (OU=Server),
`AllowRDPAccess_adm1` (OU=Server), `DIsableStandardLocalAdministrator` (OU=Clients).

## Solución aplicada (09-sep-2026)

Creada **`Admin2_SLazarte`** (CN=Sebastian Lazarte, `OU=adm2,OU=Administratoren`,
UPN `Admin2_SLazarte@maswer.com`), **sólo** en `adm2-Administrators`. Replicada en los 4 DCs.
No está en `adm1-Administrators`, ni en `Domain Admins`, ni en `Enterprise Admins`, ni en
`BUILTIN\Administrators`. Sigue la convención existente (`Admin2_AJasso`, `Admin2_MRGarcia`).

→ Da admin + logon interactivo en los 458 clientes sin tocar nada previo y sin perder el acceso
a servidores que da `adm1`. Es además lo que pedía la auditoría: cuenta dedicada, no la de diario
([[sebastian-ad-privileges]]).

⚠️ **`adm2-Administrators` no está anidado en `MFA-Administrators`** (`adm1` sí lo está). El tier
de puesto no tiene MFA forzada. Pendiente de decidir con conet.

## Brecha: 37 equipos en `CN=Computers`

**A `CN=Computers` no se le puede enlazar una GPO** → esos 37 equipos habilitados no reciben
`LocalAdminRights_adm2` ni ninguna otra política de cliente. Incluye la propia estación del
técnico (`MESZAZCLI21478`), donde `IT-Support-Germany` aparece añadido **a mano** al grupo
Administradores local — el parche que tapaba el síntoma.

Moverlos a `OU=<sede>,OU=<país>,OU=Clients` los cubriría, pero también les caería de golpe todo
el juego de GPO de cliente (mapeos de unidad, proxy, Sophos, screensaver) → **pilotar con 2-3,
no mover en bloque**. Alternativa de fondo: `redircmp` para que los equipos nuevos nazcan ya en
una OU. Lista completa levantada el 09-sep-2026.

## Lo que sigue bloqueado, y no es AD

Contra un cliente (`MDEHEFCLI007`): **445 abierto pero `C$` responde "no existe"**,
**5985/WinRM cerrado**, **DCOM → "El servidor RPC no está disponible"**. Coincide con el RPC
bloqueado ya visto en el caso `intaudit`. Aunque el token sea perfecto, **no hay canal de
administración remota hacia los puestos** — por eso la vía que sí funciona es un agente saliente
tipo TeamViewer Host como servicio, y no RPC/WinRM
([[remote-access-teamviewer-fails-fallback-anydesk]]).

**How to apply:** antes de pedir o montar nada de "admin en la flota", mirar primero
`LocalAdminRights_adm1/adm2` y la pertenencia a `adm1/adm2-Administrators`. Para actuar sobre un
**puesto** usar `Admin2_SLazarte`; para un **servidor**, la cuenta de diario (vía `adm1`) hasta
que se cree una `Admin1_` dedicada. Nunca mezclar los dos tiers en una misma cuenta — es lo que
causó este bloqueo. Ver [[conet-de-administers-maswer-infra]] y [[no-remote-sessions-endusers]].
