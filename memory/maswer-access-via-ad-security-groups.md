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

**How to apply:**
- Para conceder acceso a una carpeta/recurso → **añadir al usuario al grupo `*_R` o `*_RW` correspondiente** en AD, NO tocar la pestaña Seguridad. Es la razón por la que en el caso HR (10-jun) editar la ACL directamente fue tan difícil: el diseño es por grupo.
- Schulungsliste (ticket abierto): añadir Valle + Stangenberg a `MaswDEAG_Schulungsliste_RW`.
- HR: buscar el grupo equivalente (`*HR*` / `*Personal*`) y añadirlos ahí.
- **Pendiente confirmar:** el técnico es *miembro* de estos grupos, pero falta verificar si puede **gestionarlos** (añadir miembros con `Add-ADGroupMember`) o si eso requiere delegación vía [[conet-de-administers-maswer-infra]].
- Distinto del problema de **admin local para elevar UAC en máquinas de otros** ([[oliver-left-maswer-no-handover]]) — ese es local Administrators por GPO/Restricted Groups, no un grupo de recurso.
