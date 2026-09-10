---
name: oliver-orth-admin-accounts-still-enabled
description: "Las cuatro cuentas admin *OOrth de Oliver Orth siguen habilitadas y con Domain Admin efectivo (confirmado 14-ago y re-confirmado 25-ago-2026) — exposición de seguridad abierta, no solo higiene"
metadata:
  type: project
---

**Oliver Orth fue el administrador IT anterior de Maswer** (antes de Sebastian). Su cuenta de
usuario normal es `CN=Oliver Orth,OU=HEF,...` (sede Hersfeld). Además tiene **cuentas admin
por niveles**: `Administrator0_OOrth`, `Administrator1_OOrth`, `Admin1_OOrth`, `Admin2_OOrth`
(modelo Tier-0 / Tier-1).

Esto es la **cara de seguridad** de su salida; la cara operativa (no hay traspaso, el usuario
asume su rol, no contactarle) está en [[oliver-left-maswer-no-handover]].

## CONFIRMADO 14-ago-2026 (lectura LDAP contra `intern.maswer.com`, sin cambios)

- **Cuatro cuentas admin, TODAS HABILITADAS**: `Administrator0_OOrth` (OU=adm0),
  `Administrator1_OOrth` (OU=adm1), `Admin1_OOrth` (OU=adm1), `Admin2_OOrth` (OU=adm2).
  La cuarta no estaba en la lista original.
- **`adm0-Administrators` es miembro de `Domain Admins`**, y `CN=Oliver Orth,OU=adm0,OU=Administratoren`
  es miembro de `adm0-Administrators` → **Oliver tiene Domain Admin efectivo hoy**. Otros
  miembros de adm0: `Alejandro Jasso`, `Conet Admin`, `localadmin`.
- `Enterprise Admins` = `ADMAdfs`, `Administrator`, `SVCAdfsProxy` (ningún humano nombrado).
  `Account Operators` está vacío.

## RE-CONFIRMADO 25-ago-2026 (caso Cardozo, LDAP + ACL del file server)

Sin cambios desde el 14-ago. Añadido a la superficie de exposición, ahora con evidencia directa:

- **`MASWER\Admin1_OOrth` tiene `FullControl` heredado sobre los datos del file server
  `MDERZFIL001`** (visto en la ACL de `D:\Shares\Maswer\maswerspainsl\Projects\...`). No es solo
  privilegio de directorio: es acceso efectivo a los ficheros de negocio.
- Vecinos en `BUILTIN\Administrators` del dominio: `conetadmin`, `admin`, `localadmin`,
  `Alejandro Jasso`, **`tplink`** (cuenta de dispositivo en `CN=Users`, además miembro directo de
  `Domain Admins`) y la cuenta de diario de Sebastian — ver [[sebastian-ad-privileges]].
- **ACE huérfana** con `FullControl` sobre las mismas carpetas: SID
  `S-1-5-21-3299855299-3994495266-3842713779-500` — Administrator integrado de **otro dominio**,
  resto de una migración.

## Alcance de la exposición

Llevaba **todo el IT de Maswer** antes que Sebastian, así que su acceso abarcaba todos los
sistemas documentados, no solo AD: Entra/M365 (posible Global Admin); RBAC de la suscripción
Azure ([[conet-de-administers-maswer-infra]]); admin de Sophos SSL VPN + SFOS
([[maswer-vpn-sophos]]); Exchange híbrido ([[maswer-exchange-hybrid]]); servidor AAD Connect
([[maswer-aad-connect-server]]); consola de backup M365 ([[maswer-m365-backup]]); file server y
admin local.

**Crítico:** deshabilitar sus cuentas no basta — conoce las contraseñas de cuentas compartidas y
de servicio (`conetadmin`, `admadfs`, `localadmin`, `SVCAdfsProxy`) y la estructura
`adm1-Administrators` / `MFA-Administrators` / `AzureFiles-Administrators` que él montó. Hay que
**rotarlas**.

**Sigue SIN comprobar:** `lastLogon` / `adminCount` de esas cuentas — es decir, si se están usando
de verdad. Esa es la siguiente lectura, y es la que convierte esto de higiene en posible
incidente.

**How to apply:** verificar el estado de TODAS las cuentas de Oliver (normal + `*OOrth*`):
`Enabled`, `adminCount`, `memberOf`, `LastLogonDate`; revisar roles de Entra + IAM de Azure +
admin de Sophos. Con cuentas privilegiadas aún habilitadas → tratarlo como **revisión de
seguridad/higiene de accesos (P1/P2)**, deshabilitar + rotar credenciales compartidas, coordinado
con conet.de. Mismo patrón de bajas que [[leaver-accounts-disable-not-delete]], pero con riesgo
mucho mayor. **Falta su fecha de salida para priorizar.** Su cuenta normal es además la causa del
error crónico de Export en [[maswer-aad-connect-server]].
