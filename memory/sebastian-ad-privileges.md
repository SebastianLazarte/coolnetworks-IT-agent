---
name: sebastian-ad-privileges
description: "La cuenta de diario IT-Support-Germany es miembro directo de BUILTIN\\Administrators del dominio — control total sobre AD. CORRIGE la conclusión 'read-only' del 14-ago-2026, que fue un error de método."
metadata:
  type: project
---

## Corrección (25-ago-2026) — la conclusión anterior era falsa

`CN=Sebastian Lazarte,OU=HEF,OU=DE,OU=User Accounts,OU=Office365` (`sAMAccountName`
**IT-Support-Germany**, SID `…-5344`, verificado que coincide con el token de diario) es
**miembro directo de `BUILTIN\Administrators` del dominio** `intern.maswer.com`.
Eso es control total sobre el directorio y sobre los DCs — no hay ninguna limitación de
escritura, ni por país ni por OU.

**Verificado empíricamente el 25-ago-2026:** `Add-ADGroupMember` sobre
`MaswES_Projects_Operations_102030202_1_Proyectos_RW` (caso Nicolas Cardozo) **funcionó**,
sin ninguna ACE nominal suya en el objeto de grupo. Replicó a `MDERZADC003` y `MDERZADC004`.

**Por qué falló la auditoría del 14-ago:** se enumeró el token con `whoami /groups` en la
estación de trabajo. Ese token **solo contiene los alias BUILTIN de la máquina local**, no los
del dominio: la pertenencia a `BUILTIN\Administrators` del dominio la construye el DC al
autenticar y **nunca aparece** en el `whoami` local. De ahí la frase errónea "su token no
contiene Domain Admins ni Account Operators". El método correcto es leer el atributo `member`
del alias BUILTIN **en el DC** vía LDAP, no el token local.

**Cómo comprobarlo bien:**
```powershell
$root=New-Object System.DirectoryServices.DirectoryEntry("LDAP://MDERZADC003.intern.maswer.com/DC=intern,DC=maswer,DC=com")
$s=New-Object System.DirectoryServices.DirectorySearcher($root); $s.Filter="(&(objectClass=group)(cn=Administrators))"
($s.FindOne()).Properties["member"]
```

## Lo que sigue siendo válido de la auditoría anterior

**Un solo bosque y un solo dominio** `intern.maswer.com` (nivel funcional 2012 R2). `MUSAZDC011`
es DC del mismo dominio (sitio `Azure-Site-US`); los 4 DCs responden en 389 y 9389. Usuarios de
MX y US con UPN `@maswer.com` → mismo tenant, misma identidad. Ver [[maswer-ad-domain-infra]],
[[maswer-servers-inventory]], [[maswer-replicacion-dcs-azure-altas]].

**Lectura: sí, en los cuatro países por igual.** Usuarios bajo `OU=<país>,OU=User Accounts,OU=Office365`:
DE 90 (63 habilitados), ES 70 (46), MX 64 (59), US 26 (23), + `OU=EXT` 2 y `OU=Service` 9.

Sigue siendo cierto que `adm1-Administrators` / `adm2-Administrators` no otorgan derechos de
**directorio** (verificado 25-ago: `adm1` solo está anidado en `MFA-Administrators`, `adm2` en nada),
y que el privilegio *sobre AD* viene de la pertenencia directa a `BUILTIN\Administrators`.

## Corrección (09-sep-2026) — la frase "el privilegio no viene de ahí" era engañosa

Cierto para AD, **falso para los endpoints**. `adm1`/`adm2-Administrators` sí otorgan
**administrador local de la flota** vía las GPO `LocalAdminRights_adm1` (OU=Server) y
`LocalAdminRights_adm2` (OU=Clients) — y su cuenta de diario ya estaba en ambos grupos, así que
**ya era admin local de 472 de los 513 equipos** sin saberlo. El detalle completo, y el deny de
logon de `adm1` que rompía la elevación de UAC en clientes, en
[[maswer-local-admin-tiering-adm1-adm2]].

Ya **no** es cierto que "no existe ninguna cuenta `adm*` a su nombre": el 09-sep-2026 se creó
**`Admin2_SLazarte`** en `OU=adm2`, sólo en `adm2-Administrators`. Es el primer paso de la
separación que esta nota dejaba pendiente; falta sacar la cuenta de diario de
`BUILTIN\Administrators` y de `adm1`/`adm2`.

**Discrepancia (sin cambios):** AD tiene 7 sitios en MX (AGU, BJX, CUU, MTY, PBC, SLP, SLW) y 3 en US
(BQK, LGB, TCL); el Visio en [[maswer-network-topology]] solo documenta 3 y 1.

## Hallazgo de higiene: quién más está en BUILTIN\Administrators

Además de él: `conetadmin`, `admin`, `Alejandro Jasso` (adm0), `localadmin` (adm0),
`Administrator`, `Domain Admins`, `Enterprise Admins` — y **tres cuentas de Oliver Orth**
(`Oliver Orth` adm0, `Oliver Orth` adm1, `Admin1_OOrth`), lo que confirma y agrava
[[oliver-orth-admin-accounts-still-enabled]]. También **`CN=tplink,CN=Users`**: una cuenta de
servicio de dispositivo con admin de dominio, en el contenedor por defecto.

**Why:** la creencia "no tengo escritura, hay que pedírselo a conet" bloqueaba tareas que en
realidad puede ejecutar él mismo, y a la vez ocultaba que su cuenta de diario tiene privilegio
máximo — que es justo lo que la auditoría interna decía que no debía pasar ("cada admin usa una
cuenta dedicada, nunca su cuenta de diario"). Ver [[maswer-access-via-ad-security-groups]],
[[conet-de-administers-maswer-infra]].

**How to apply:** altas, bajas, resets y cambios de pertenencia a grupos los ejecuta él
directamente — **no** hay que escalarlos a conet.de por falta de permisos. Contrapartida: trabaja
con privilegio de administrador de dominio en su cuenta de uso diario, así que aplica la regla de
tocar solo el objeto del ticket y registrar el cambio. Pendiente de decidir con conet.de: separar
una cuenta `adm*` nominal y sacar la de diario de `BUILTIN\Administrators`, y limpiar las cuentas
de Oliver y `tplink`.

**Pendiente:** el plano Entra/M365 (roles propios y su `directoryScopeId`, Administrative Units)
sigue sin verificar — la autenticación device-code caducó sin autorizar.
