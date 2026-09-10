---
name: maswer-access-via-ad-security-groups
description: Access to Maswer folders/resources/apps is controlled by AD security groups (MaswDEAG_*, Masw*, Nexpro*, naming _R = read / _RW = read-write), NOT by editing per-folder ACLs. Grant access by adding users to the right group.
metadata:
  type: project
---

En Maswer el acceso a carpetas, recursos y apps se controla con **grupos de seguridad de Active Directory**, no editando ACLs carpeta por carpeta. Confirmado en el token (`whoami /groups`) de la cuenta del técnico `MASWER\IT-Support-Germany`, que es miembro de grupos como:

- `MaswDEAG_Schulungsliste_RW` ← el folder Schulungsliste del ticket 18-jun (Valle + Stangenberg)
- `MaswDEAG_Profi_Cash_RW` ← ProfiCash (caso Maurizio Carroccia)
- `MaswDEAG_ALL_R`, `Masw_ALL_Intranet_R`, `MaswES_QM_RW`
- `NEXPROES_ALL_R` / `_RW`, `NexproES_Accounting_RW`
- `AzureFiles-Administrators` (sugiere Azure Files en uso → "Drive" puede ser Azure Files, no Google Drive)
- Admin/infra: `adm1-Administrators`, `MFA-Administrators`, `MFA-MASWER`, `SSL_VPN`, `Webfilter_Standard`, `SophosUser`

**Patrón de nombres:** `<entidad>_<recurso>_<R|RW>`. Sufijo `_R` = solo lectura, `_RW` = lectura-escritura. Prefijos por entidad: `MaswDEAG` (Maswer DE), `MaswES`/`NexproES` (ES), `NEXPROES`, etc. — ver [[freshworks-entity-structure]].

## Convención carpeta → grupo (verificada 25-ago-2026)

El árbol de carpetas y el árbol de grupos son **espejo 1:1**:
`<Entidad>_<Nivel1>_<Nivel2>_<Código>_<Subcarpeta>_<R|RW>`

- `R:\Projects\Operations\102030202\01 Proyectos` → `MaswES_Projects_Operations_102030202_1_Proyectos_RW`
- La subcarpeta pierde el cero y el espacio: **`01 Proyectos` → `_1_Proyectos`**
- Grupos `DomainLocal` en `OU=<Entidad>,OU=<País>,OU=Groups,OU=Office365`
- **Anidamiento:** el grupo hoja es miembro del `_R` del nivel superior → el *traverse* de las
  carpetas padre se hereda solo. **Un único `Add-ADGroupMember` basta.**
- **Hoja vs. padre:** el grupo del padre llega a la subcarpeta por herencia y da acceso a *todo*
  el proyecto. Si el ticket nombra una sola carpeta, usa el **hoja** (mínimo privilegio).
- El grupo correcto se confirma leyendo la ACL **en el file server** y quedándose con la ACE
  de `IsInherited = False`. `Get-Acl` sobre la ruta UNC devuelve "Acceso denegado" aunque tengas
  privilegio de dominio → hay que ir por `Invoke-Command` a `MDERZFIL001` y la ruta local
  `D:\Shares\Maswer\<share>\…`.

**Procedimiento completo, comandos y errores conocidos:** `reference/runbook-acceso-carpetas-red-maswer.md`.

**How to apply:**
- Para conceder acceso a una carpeta/recurso → **añadir al usuario al grupo `*_R` o `*_RW` correspondiente** en AD, NO tocar la pestaña Seguridad. Es la razón por la que en el caso HR (10-jun) editar la ACL directamente fue tan difícil: el diseño es por grupo.
- Schulungsliste (ticket abierto): añadir Valle + Stangenberg a `MaswDEAG_Schulungsliste_RW`.
- HR: buscar el grupo equivalente (`*HR*` / `*Personal*`) y añadirlos ahí.
- **RESUELTO 25-ago-2026:** el técnico **sí puede gestionar estos grupos**. `Add-ADGroupMember`
  ejecutado con éxito sobre `MaswES_Projects_Operations_102030202_1_Proyectos_RW` (caso Cardozo).
  El privilegio no viene de los grupos `adm*` sino de que la cuenta de diario `IT-Support-Germany`
  es miembro **directo de `BUILTIN\Administrators` del dominio** — ver [[sebastian-ad-privileges]].
  **No hay que escalar las peticiones de acceso a carpetas a
  [[conet-de-administers-maswer-infra]] por falta de permisos.**
- **Para comprobar que el permiso ha entrado** sin cerrar sesión ni tocar el equipo del usuario:
  `klist purge` + acceso por nombre corto del servidor → [[test-token-refresh-without-logoff]].
  Antes, replicar el cambio a los DCs de Azure ([[maswer-replicacion-dcs-azure-altas]]) o darás
  falsos negativos.
- Distinto del problema de **admin local para elevar UAC en máquinas de otros** ([[oliver-left-maswer-no-handover]]) — ese es local Administrators por GPO/Restricted Groups, no un grupo de recurso.
