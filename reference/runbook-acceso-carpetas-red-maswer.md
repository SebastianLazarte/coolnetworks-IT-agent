# Runbook — Acceso a carpetas de red (Maswer)

Receta verificada de punta a punta el **25-ago-2026** (caso Nicolas Cardozo, ticket
"NICOLAS CARDOZO / supervisor"). Tipo de ticket recurrente: ver también los casos
`2026-06-10_maswer_hr-folder-access`, `2026-06-18_maswer_schulungsliste-folder-access`,
`2026-07-09_maswer_folder-access-p-q`.

**Regla base:** el acceso se concede **añadiendo el usuario a un grupo de seguridad de AD**,
nunca editando la pestaña Seguridad. Ver `memory/maswer-access-via-ad-security-groups.md`.

> **Este runbook lo puedes ejecutar tú.** La cuenta de diario `IT-Support-Germany` es
> miembro directo de `BUILTIN\Administrators` del dominio → escribe en AD sin pedir nada
> a conet.de. Confirmado empíricamente el 25-ago-2026. Ver `memory/sebastian-ad-scope-readonly.md`
> (en la memoria de usuario, corregida).

---

## 0. Mapa de unidades → UNC → ruta local en el servidor

Verificado con `Get-PSDrive` / `net use` en el puesto del técnico:

| Unidad | UNC | Entidad |
|---|---|---|
| **M:** | `\\MDERZFIL001.intern.maswer.com\maswer\NEXPRO` | NEXPRO |
| **O:** | `\\MDERZFIL001.intern.maswer.com\maswer\intranet` | Intranet |
| **P:** | `\\MDERZFIL001.intern.maswer.com\maswer\maswerag` | Maswer AG |
| **R:** | `\\MDERZFIL001.intern.maswer.com\maswer\maswerspainsl` | **Maswer Spain SL** |
| S: | `\\MDEKASCLI003\STAkis_Profi` | STAkis — **no** es el file server |

**Ruta local dentro de `MDERZFIL001`:** `D:\Shares\Maswer\<carpeta-del-share>\...`
Ej.: `R:\Projects\Operations\102030202\01 Proyectos`
→ `D:\Shares\Maswer\maswerspainsl\Projects\Operations\102030202\01 Proyectos`

> Si el usuario dice "SharePoint" pero da una ruta con letra de unidad (`R:\…`), **no es
> SharePoint**: es el file server. No busques nada en M365.

---

## 1. Convención de nombres: el grupo se deduce de la ruta

`<Entidad>_<Nivel1>_<Nivel2>_<Código>_<Subcarpeta>_<R|RW>`

- **Entidades:** `MaswES`, `MaswDEGMBH`, `MaswMon`, `MaswMex`, `MaswUS`, `MaswTaller`,
  `MaswTestDrive`, `NexproES`
- Los números de proyecto van literales (`102030202`)
- Las subcarpetas pierden el cero inicial y el espacio: **`01 Proyectos` → `_1_Proyectos`**
- Los grupos son `DomainLocal` y viven en `OU=<Entidad>,OU=<País>,OU=Groups,OU=Office365`

Ejemplo real: `R:\Projects\Operations\102030202\01 Proyectos`
→ `MaswES_Projects_Operations_102030202_1_Proyectos_RW`

**Anidamiento (importante):** el grupo hoja `_RW` es miembro del `_R` del nivel superior, que
a su vez es miembro del `_R` del nivel de encima. El *traverse* de las carpetas padre se hereda
solo. **Un único `Add-ADGroupMember` basta** — no añadas grupos de recorrido a mano.

**Hoja vs. padre (least privilege):** el grupo del nivel padre (`..._102030202_RW`) llega a la
subcarpeta **por herencia** y da acceso a *todas* las subcarpetas del proyecto. Si el ticket
nombra una sola carpeta ("Sólo a…"), usa el grupo **hoja**, no el del padre.

---

## 2. Procedimiento

Todos los comandos con `-Server` explícito (ver Errores conocidos, punto 1).

```powershell
$dc  = "MDERZADC003.intern.maswer.com"
$sam = "NCardozo"
$grp = "MaswES_Projects_Operations_102030202_1_Proyectos_RW"
```

**2.1 — Confirmar la cuenta del usuario**
```powershell
Get-ADUser -Filter "Surname -like '*Cardozo*'" -Server $dc `
  -Properties DisplayName,Enabled,LastLogonDate,whenCreated |
  Select DisplayName,SamAccountName,Enabled,LastLogonDate,DistinguishedName
```
Mira `LastLogonDate`: si lleva meses sin iniciar sesión, avísalo en la respuesta — el
permiso no servirá de nada hasta que entre.

**2.2 — Localizar el grupo por nombre**
```powershell
Get-ADGroup -Filter "Name -like '*Operations*'" -Server $dc | Select Name | Sort Name
```

**2.3 — Confirmar el grupo contra la ACE real de la carpeta** *(el paso que elimina la suposición)*
```powershell
Invoke-Command -ComputerName MDERZFIL001.intern.maswer.com -ScriptBlock {
  $lp = "D:\Shares\Maswer\maswerspainsl\Projects\Operations\102030202\01 Proyectos"
  (Get-Acl -LiteralPath $lp).Access |
    Where { "$($_.IdentityReference)" -notmatch 'BUILTIN|NT AUTHORITY|CREATOR' } |
    Select @{n='Who';e={"$($_.IdentityReference)"}},FileSystemRights,IsInherited
}
```
El grupo correcto es el que aparece con **`IsInherited = False`** (ACE explícita de esa carpeta).
Los `IsInherited = True` vienen de carpetas padre → dan más de lo pedido.

**2.4 — Calcular el delta contra un par que ya tiene el acceso**
```powershell
Get-ADGroupMember $grp -Server $dc | Select Name
(Get-ADUser <par-existente> -Server $dc -Properties MemberOf).MemberOf |
  % { ($_ -split ',')[0] -replace '^CN=','' } | Sort
```
Compara con los grupos del usuario nuevo. Si la única diferencia es el grupo objetivo, el
cambio es **un solo add** y no falta ninguna pertenencia de base.

**2.5 — Aplicar y verificar la replicación**
```powershell
Add-ADGroupMember -Identity $grp -Members $sam -Server $dc

foreach($d in @("MDERZADC003","MDERZADC004","MEUAZDC011")){
  $m = Get-ADGroupMember $grp -Server "$d.intern.maswer.com" |
       Where { $_.SamAccountName -eq $sam }
  "{0} : {1}" -f $d, $(if($m){"PRESENT"}else{"pending"})
}
```

**2.6 — Cierre**
- El usuario debe **cerrar sesión y volver a entrar** (el token Kerberos solo recoge grupos al login).
- **No hace falta sync a M365** — es un recurso NTFS on-prem, no se replica a Entra.

---

## 3. Errores conocidos (todos encontrados el 25-ago-2026)

1. **`No se pudo encontrar ningún servidor predeterminado que ejecutara ADWS`** — intermitente
   al localizar DC. **Siempre pasa `-Server MDERZADC003.intern.maswer.com`.**
2. **`Get-Acl AD:\...` → "No existe ninguna unidad con el nombre 'AD'"** — cada llamada de
   PowerShell es una sesión nueva; el PSDrive `AD:` exige `Import-Module ActiveDirectory`.
   Alternativa sin módulo: `System.DirectoryServices.DirectorySearcher`.
3. **`Get-Acl` sobre la ruta UNC → "Acceso denegado"**, incluso con privilegio de dominio
   (`BUILTIN\Administrators` del dominio **no** es admin local en un servidor miembro).
   → Lee la ACL **desde el servidor** con `Invoke-Command` sobre la ruta local `D:\Shares\...` (paso 2.3).
4. **`Test-Path` lanza excepción** en vez de devolver `$false` si el acceso está denegado →
   envuélvelo en `try/catch`.
5. **Replicación desigual:** `MDERZADC003`/`MDERZADC004` son inmediatos; **`MEUAZDC011`
   (Azure EU) tarda minutos**. Los usuarios de ES (BCN) pueden autenticar contra el DC de
   Azure EU → **verifica en los tres DCs** antes de decirle al usuario que entre.
6. **`whoami /groups` NO muestra los alias BUILTIN del dominio** — solo los de la máquina
   local. Para saber quién es admin de dominio hay que leer el atributo `member` del alias
   en el DC vía LDAP. Este error causó una conclusión falsa ("no tengo escritura") que estuvo
   activa 11 días.

---

## 4. Checklist

1. [ ] Traducir letra de unidad → UNC → ruta local (`D:\Shares\Maswer\…`)
2. [ ] Deducir el grupo por convención de nombres
3. [ ] **Confirmarlo con la ACE `IsInherited = False`** vía `Invoke-Command` al file server
4. [ ] Delta contra un par que ya tiene el acceso
5. [ ] `Add-ADGroupMember` + verificar en los 3 DCs
6. [ ] Responder: hoja vs. padre aplicado, si existe o no variante `_R`, y que cierre sesión
