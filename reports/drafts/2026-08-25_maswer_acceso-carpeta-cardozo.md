# Case report — Maswer / Acceso a carpeta de proyectos para Nicolas Cardozo

- **Cliente:** Maswer Spain SL
- **Solicitante:** Stefania Steccanella (Operation Manager) — en copia: Patricia Gimeno, Miriam Juan Vega, Kriss Sotelo
- **Usuario final:** Nicolas Cardozo (supervisor)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha de apertura:** 24-ago-2026 15:20
- **Fecha de resolución:** 25-ago-2026
- **Reapertura:** 27-ago-2026 — el usuario sigue sin ver la carpeta
- **Estado:** REABIERTO — causa confirmada por auto-test: token de sesión obsoleto en el puesto.
  El permiso es correcto y suficiente. Pendiente: que el usuario cierre sesión y vuelva a entrar.

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (permisos de carpeta) |
| Prioridad | P3 - Media |
| Grupo | N1 — resuelto en primer toque, sin escalado |
| SLA inicial | Respuesta en 4 h |
| Escalado | No |

---

## Petición recibida

> "Por favor gestionar el acceso al sharepoint al trabajador arriba mencionado.
> Sólo a las carpetas de acceso del supervisor: `R:\Projects\Operations\102030202\01 Proyectos`"

**Dos ambigüedades detectadas en la entrada:**
1. La petición dice "SharePoint", pero la ruta es una **letra de unidad de red**. No es SharePoint.
2. "Las carpetas de acceso del supervisor" + "Sólo" + una única ruta → alcance contradictorio:
   el nivel de supervisor es más amplio que la carpeta indicada.

---

## Diagnóstico (verificado, no inferido)

- **`R:` = `\\MDERZFIL001.intern.maswer.com\maswer\maswerspainsl`** (Maswer Spain SL).
  Ruta local en el servidor: `D:\Shares\Maswer\maswerspainsl\Projects\Operations\102030202\01 Proyectos`.
  No interviene SharePoint ni M365 en ningún punto.
- La ACL de esa carpeta, leída en el propio file server, tiene **una sola ACE explícita
  (`IsInherited = False`)**: `MASWER\MaswES_Projects_Operations_102030202_1_Proyectos_RW`,
  con permiso *Modify*.
- El resto de grupos con acceso lo tienen **por herencia** de la carpeta padre:
  `..._102030202_RW`, `..._Operations_RW`, `MaswES_Projects_RW`, `MaswES_ALL_RW`.
- El grupo del **nivel supervisor** (`MaswES_Projects_Operations_102030202_RW`) contiene a la
  propia solicitante, a Kriss Sotelo y a Miriam Juan Vega — las tres personas del hilo del
  correo. Ese grupo da acceso a **todo** el proyecto 102030202, no solo a `01 Proyectos`.
- **No existe** un grupo `_R` propio de `01 Proyectos`. El único grupo con ACE explícita sobre
  esa carpeta es de lectura-escritura → no había opción de solo lectura sin crear un grupo nuevo.

**Resolución de la ambigüedad de alcance:** se aplicó el grupo **hoja** (solo `01 Proyectos`),
no el de supervisor, por el "Sólo" explícito de la petición y por mínimo privilegio. La
alternativa se ofreció al cliente en la respuesta para que decida.

---

## Acción ejecutada

1. Cuenta verificada: `NCardozo` — `CN=Nicolas Cardozo,OU=BCN,OU=ES,OU=User Accounts,OU=Office365`, habilitada.
2. Delta calculado contra dos pares con el acceso ya concedido (Sara Lopez Campos, Silvia Rubio):
   base de grupos **idéntica** a la de Cardozo **+ un único grupo**. Confirmó que no faltaba
   ninguna pertenencia previa.
3. `Add-ADGroupMember -Identity "MaswES_Projects_Operations_102030202_1_Proyectos_RW" -Members NCardozo` → **OK**.
4. Verificado: el grupo pasó de **16 a 17 miembros**.
5. Replicación confirmada en `MDERZADC003`, `MDERZADC004` y `MEUAZDC011`.
6. Sin sincronización a M365 — recurso NTFS on-prem, no aplica.

**Sin ventana de mantenimiento:** el cambio es una pertenencia de grupo sobre un único usuario,
sin impacto en servicio ni en terceros, y es reversible con `Remove-ADGroupMember`.

---

## Observación sobre el usuario

La cuenta de Nicolas Cardozo se creó el **25-feb-2026** y su último inicio de sesión registrado
es del **16-abr-2026** — más de cuatro meses sin actividad. Se comunicó al cliente: el permiso
no produce efecto hasta que el usuario inicie sesión, y conviene revisar el estado de la cuenta
o del equipo antes de su incorporación.

---

## Respuesta al cliente (ES)

```
Hola Stefania,

Hecho. Nicolás ya tiene acceso a esa carpeta, con permiso para abrir, crear,
editar y borrar. Tiene que cerrar sesión y volver a entrar para que le aparezca.

Dos cosas que debes saber:

1. Le he dado acceso solo a la carpeta que me indicaste, no al resto de
   carpetas del proyecto 102030202. Tú, Kriss y Miriam sí tenéis el proyecto
   entero. Si Nicolás también lo necesita, dímelo y lo amplío.
2. En esa carpeta no existe la opción de "solo lectura": quien entra, entra
   con permiso de edición. Si necesitas que solo pueda consultar sin
   modificar, hay que montarlo aparte — dímelo y lo preparo.

Un apunte: su cuenta no registra ningún inicio de sesión desde el 16 de abril.
Si el equipo o la cuenta llevan parados, avísame y lo reviso antes de que se
ponga.

Un saludo,
Soporte CoolNetworks
```

---

## Reapertura 27-ago-2026 — "le sigue sin aparecer la carpeta"

### Observado (verificado en servidor, 27-ago)

| # | Comprobación | Resultado |
|---|---|---|
| 1 | Token efectivo de `NCardozo` (`tokenGroups` por LDAP en el DC) | Contiene el grupo hoja **y**, por anidamiento, `..._102030202_R`, `..._Operations_R`, `MaswES_Projects_R`, `MaswES_ALL_R` |
| 2 | Anidamiento del grupo hoja (`memberOf` leído en AD) | Está anidado **directamente** en `MaswES_ALL_R`, `MaswES_Projects_Operations_R` y `..._102030202_R` |
| 3 | Comparativa con Silvia Rubio (`SRubio`) | Conjunto de grupos de acceso a ficheros **idéntico**; la única diferencia es `MFA-MASWER` (él) frente a `test_group` (ella). ⚠️ Ver "Comparación con el resto del grupo": esto **no** demuestra que ella use el acceso |
| 3b | Cadena NTFS completa, leída en el servidor | Recurso `Maswer`: `Jeder`=Full (el nivel de recurso no restringe, gobierna NTFS — modelo correcto). Raíz `maswerspainsl`: `MaswES_ALL_R`=RX. `Projects`: `MaswES_Projects_R`=RX. `Operations`: `MaswES_Projects_Operations_R`=RX. `102030202`: `..._102030202_R`=RX. `01 Proyectos`: grupo hoja=Modify. **Los cinco niveles están en su token.** |
| 4 | Existencia de la carpeta en `MDERZFIL001` | `01 Proyectos` existe, última modificación 21-ago-2026 |
| 5 | Enumeración del recurso `Maswer` | `FolderEnumerationMode = AccessBased` (ABE activo) |
| 6 | Montaje de `R:` | GPO **`Laufwerk-R-SpainSL`**, enlazado en la raíz del dominio, filtrado por `MaswES_ALL_R` → grupo que el usuario ya tiene |
| 7 | Actividad de autenticación | 9 TGT en 3 días; inicios de sesión de red contra `MDERZFIL001` el 26-ago (×3) y el 27-ago a 09:41, 09:46 y 09:57 |
| 8 | Cuentas duplicadas del usuario | Ninguna — sólo existe `NCardozo` |
| 9 | Auditoría de acceso a recursos compartidos en `MDERZFIL001` | **Desactivada** (sin eventos 5140/5145) → una denegación no dejaría rastro |

**Corrección de una hipótesis intermedia:** durante el análisis se supuso que el usuario carecía
de permiso de recorrido en las carpetas padre, porque `Get-ADPrincipalGroupMembership` sólo
devolvía el grupo hoja. Es falso: ese cmdlet no expande el anidamiento. El token real (punto 1)
demuestra que la cadena de lectura está completa. **La configuración de permisos es correcta.**

### Comparación con el resto del grupo (lo que sí y lo que no demuestra)

Los **17 miembros** del grupo hoja tienen exactamente la misma configuración que Cardozo:
ninguno posee además el grupo supervisor `..._102030202_RW`. No hay ningún compañero con un
montaje "más ancho" que explique por qué a ellos les funciona y a él no.

**Pero el acceso por la vía del grupo hoja no está observado funcionando.** De los 16
compañeros, sólo 3 se han conectado al file server en 7 días (`JGuerra` 25-ago, `SRosales`
26-ago, `SLopez` 25-ago) y, con la auditoría de recursos compartidos desactivada, no consta
qué carpeta abrieron. Las personas que **ahora mismo** tienen ficheros abiertos bajo
`01 Proyectos` (`msantiago`) y bajo `102030202` (`MJuan`, `KSotelo`) **no** pertenecen al
grupo hoja: entran por la vía ancha. Silvia Rubio, citada el 25-ago como par con el acceso
concedido, **no se ha conectado al file server en 7 días** — estaba en el grupo, que no es
lo mismo que usarlo.

Conclusión honesta: la configuración es correcta y está verificada nivel por nivel, pero
**nadie ha sido observado usando esta ruta concreta**. Por eso el auto-test del técnico
(paso 1) no es opcional.

### Origen de las conexiones

El usuario se ha conectado en 48 h desde **tres orígenes distintos**:

- `10.242.1.5` → `MESZAZCLI21478` (26-ago)
- `10.242.1.7` y `10.242.1.8` (27-ago) → **pool de VPN**: el rango `10.242.1.0/24` tiene 48
  registros DNS con varias máquinas compartiendo la misma IP, de España, Alemania y México
  (p. ej. `10.242.1.2` = `MDERUMCLI025` + `MMXAGUCLI0005` + `MESZAZCLI2679` + …). Firma
  inequívoca de direcciones recicladas, no de una LAN.
- `192.168.4.47` → `DESBCNCLI0019`, LAN de la oficina de Barcelona (99 registros, uno por
  equipo), 27-ago 09:57

Además pidió ticket de servicio **hacia** `MESBCNCLI2987$`, lo que indica que se conecta en
remoto a ese equipo desde otro puesto.

**Hallazgo menor:** `192.168.4.0/24` **no está dada de alta** en AD Sites and Services (sólo
constan `192.168.0-3.0/24`, `172.30.0.0/16` y `172.20.0.0/16`). Los equipos de esa red no se
asocian a ningún sitio, lo que afecta a la localización de controlador de dominio.

### Hipótesis (no verificada — falta el artefacto del puesto)

**Token de sesión obsoleto.** La pertenencia se aplicó el 25-ago a las 18:42. Tanto el permiso
NTFS como el montaje de `R:` dependen de que el grupo esté en el **token de la sesión
interactiva**, que se construye en el momento del inicio de sesión y **no se refresca** después.
Si inicia sesión sin línea con un controlador de dominio (credenciales en caché, y la conexión
remota se establece después), arrastra los grupos antiguos: no se le monta `R:` y, con ABE
activo, la carpeta ni siquiera aparece.

**Alternativa igual de viva:** está mirando donde no es. La petición original decía "SharePoint"
y aquí no interviene SharePoint en ningún punto.

**Artefacto que lo resuelve:** `whoami /groups` en la sesión que está usando — si `MaswES_ALL_R`
no aparece, es token obsoleto. (No aplica aquí la limitación conocida del comando: sólo oculta
los alias `BUILTIN` del dominio, no los grupos globales como estos.)

**No verificable desde el servidor:** `MESBCNCLI2987` y `DESBCNCLI0019` no exponen WinRM.

### Auto-test del técnico — 27-ago-2026 (CONCLUYENTE)

Para no depender del usuario ni abrir sesión remota en su puesto, se reprodujo su configuración
exacta sobre la cuenta del técnico (`IT-Support-Germany`).

| Fase | Acción | Resultado |
|---|---|---|
| Baseline | Estado previo del técnico | Ya tenía `MaswES_ALL_R` y `R:` montada, **pero la ruta objetivo daba DENEGADO** → confirma que `MaswES_ALL_R` sólo abre la raíz, no `Projects` |
| Alta | `Add-ADGroupMember` del grupo hoja + `Sync-ADObject` a los 3 DCs | 18 miembros en `MDERZADC003`, `MDERZADC004`, `MEUAZDC011` |
| Prueba | `klist purge` + acceso por **nombre corto** (sesión SMB nueva), **sin cerrar sesión de Windows** | **ACCESIBLE — 3889 elementos** |
| Contraste | Misma cuenta, mismo segundo, dos sesiones SMB | `R:` (sesión antigua, FQDN) = **DENEGADO** · nombre corto (sesión nueva) = **26 carpetas visibles, `01 Proyectos` entre ellas** |
| Reversión | `Remove-ADGroupMember` + replicación forzada + cierre de sesión SMB | 17 miembros en los 3 DCs; ruta objetivo denegada de nuevo |

**Qué demuestra, sin margen de duda:**

1. El **grupo hoja por sí solo es suficiente** para llegar a `01 Proyectos` atravesando toda la
   cadena. La configuración aplicada el 25-ago es correcta y completa.
2. La causa del síntoma es el **token de sesión obsoleto**: la misma cuenta, en el mismo
   instante, tiene acceso denegado en la sesión SMB antigua y acceso concedido en una nueva.
   Ya no es hipótesis.
3. El efecto es **simétrico al revocar**: tras quitar la pertenencia en los tres DCs, el acceso
   siguió funcionando hasta cerrar la sesión SMB. Relevante para futuras bajas de permisos.

**Efecto secundario observado durante la reversión:** al cerrar sesiones SMB en `MDERZFIL001`
aparecieron **9 sesiones abiertas** de `IT-Support-Germany` desde `172.30.1.7-10` (sitio Azure),
`192.168.0.9-10` y `10.242.1.5`. La cuenta de diario del técnico está siendo usada desde nueve
máquinas, varias de ellas servidores. Refuerza el hallazgo colateral nº 1.

### Hallazgo colateral de la reapertura

La auditoría de acceso a recursos compartidos está **desactivada** en `MDERZFIL001`. Cualquier
incidencia de permisos en el file server se diagnostica a ciegas. Merece ticket propio.

---

## Revisión de equipos e inicios de sesión — 27-ago-2026

Barrido de 10 días sobre los cuatro DC (`MDERZADC003/004`, `MEUAZDC011`, `MUSAZDC011`) y sobre
`MDERZFIL001`, vía WinRM (RPC directo está filtrado; `Get-WinEvent -ComputerName` falla).

### Estado de la cuenta (observado)

| Atributo | Valor |
|---|---|
| SamAccountName / UPN | `NCardozo` / `NCardozo@maswer.com` |
| DN | `CN=Nicolas Cardozo,OU=BCN,OU=ES,OU=User Accounts,OU=Office365` |
| Habilitada / bloqueada | Sí / No |
| Creada | 25-feb-2026 16:37 |
| `PasswordLastSet` | 25-feb-2026 16:37 — **nunca cambiada** |
| `userAccountControl` | `66048` = cuenta normal + **contraseña que no caduca** |
| `userWorkstations` | vacío (sin restricción de equipos de inicio de sesión) |
| Intentos fallidos (`badPwdCount`, 4771/4776) | **0 en los 4 DC** |
| Grupos directos | `MaswES_Projects_Operations_102030202_1_Proyectos_RW`, `Masw_ALL_Intranet_R`, `MFA-MASWER`, `SSL_VPN`, `TPLINK_User`, `Webfilter_Standard` |

`lastLogon` por DC: `MDERZADC003` 27-ago 10:58 · `MEUAZDC011` 27-ago 09:42 · `MDERZADC004`
26-ago 12:29 · `MUSAZDC011` 26-feb 12:57 (sin uso desde el alta).

### Actividad de autenticación (observado)

**22 TGT (evento 4768), todos con estado 0 (éxito), concentrados en 26 y 27-ago.**
Cero eventos entre el 17 y el 25-ago. La cuenta pasó de inactiva desde abril a activa el
**26-ago, el día siguiente a la concesión del permiso** (25-ago 18:42).

| Día | Origen | TGT | Observaciones |
|---|---|---|---|
| 26-ago 10:50–12:53 | `10.242.1.5` | 13 | pool SSL VPN de Azure Alemania |
| 26-ago 11:06 | `172.30.1.7` (`MEUAZAC011`) | 1 | validación de inicio de sesión **en la nube** (Entra) |
| 27-ago 09:41–10:58 | `10.242.1.7`, `10.242.1.8` | 7 | pool SSL VPN |
| 27-ago 09:42 | `172.30.1.10` (`MEUAZPTA012`) | 1 | validación de inicio de sesión **en la nube** (Entra) |

**Todos los inicios de sesión de red proceden del rango `10.242.1.0/24` = pool SSL VPN de Azure
Alemania** (confirmado en [[maswer-network-topology]]). El usuario trabaja **en remoto por VPN**,
no desde la LAN de la oficina.

Tickets de servicio (4769) — a qué recursos accede:

| Servicio | Veces | Qué significa |
|---|---|---|
| `MDERZADC003$` / `ADC004$` / `MEUAZDC011$` / `MUSAZDC011$` | 31 | tráfico normal de directorio/GPO |
| `MDERZFIL001$` | 4 | acceso al file server |
| **`MESBCNCLI2987$`** | 4 | **se conecta a ese equipo** (26-ago ×2, 27-ago ×2) |
| `MEUAZAC011$` / `MEUAZPTA012$` | 2 | autenticación pass-through a M365 |

Accesos al file server (4624, tipo 3 Kerberos, **todos con éxito**):
26-ago 10:50 · 10:56 · 12:30 (desde `10.242.1.5`) — 27-ago 09:41 (`10.242.1.7`) · 09:46
(`10.242.1.8`) · 09:57 (`192.168.4.47`).

### Equipos

| Equipo | OS | Ubicación en AD | Último inicio (cuenta de equipo) | Relación con el usuario |
|---|---|---|---|---|
| `MESBCNCLI2987` | Windows 11 Business | `OU=BCN,OU=ES,OU=Clients` | 26-ago 10:50 | **Su equipo**: es el único al que pide ticket de servicio |
| `MESZAZCLI21478` | Windows 11 Pro | `CN=Computers` | 26-ago 15:31 | Tenía la IP VPN `10.242.1.5` el 26-ago |

Ninguno de los equipos candidatos expone WinRM (`MESBCNCLI2987`, `MESZAZCLI21478`,
`MESBCNCLI5672`, `MESZAZCLI9000`, `MESZAZCLI898` → 5985 cerrado). **No se puede inspeccionar el
puesto en remoto desde el servidor.**

⚠️ `MESZAZCLI21478` y el resto de equipos vistos están en `CN=Computers`, no en una OU
gestionada — las GPO enlazadas a OU no les llegan. `MESBCNCLI2987` sí está en `OU=BCN`.

### Corrección a la sección anterior de este informe

1. **`192.168.4.47` NO es `DESBCNCLI0019`.** El PTR es obsoleto. En la zona `intern.maswer.com`
   el registro A vivo de esa IP es **`MESBCNCLI5672`** (sello 12-jun-2026); el de
   `DESBCNCLI0019` data de 2022 y su cuenta de equipo **no autentica desde el 6-mar-2025**.
2. **El pool `10.242.1.0/24` no es resoluble por DNS.** Cada IP arrastra 2–5 registros A de
   equipos distintos (p. ej. `10.242.1.7` → `MESZAZCLI9000`, `it-support-Germany`,
   `MDEBERCLI002`, `DESBCNCLI030`, `MDEHEFCLI010`). Es un rango reciclado: **identificar un
   equipo por su IP de VPN no es fiable**, sólo lo es el ticket de servicio a `MESBCNCLI2987$`.
3. **La actividad no fue "9 TGT en 3 días"** sino 22 TGT en 2 días, sin nada previo.

### Efecto sobre la hipótesis de token obsoleto

**Queda debilitada.** Los 22 TGT son todos posteriores a la concesión del permiso (25-ago 18:42),
y un TGT nuevo lleva el grupo en su PAC. Los seis accesos a `MDERZFIL001` son **exitosos**.
Lo que no se puede saber, por estar la auditoría de objetos desactivada, es **qué carpeta** abrió.

### Hipótesis viva (no verificada)

**Enrutado partido.** El 27-ago a 09:46 accede al file server desde `10.242.1.8` (túnel VPN) y
once minutos después, a 09:57, desde `192.168.4.47` (LAN de Barcelona, ver
[[maswer-network-topology]]). Dos caminos distintos al mismo servidor en la misma mañana →
compatible con un portátil **en la oficina de Barcelona con el cliente SSL VPN conectado** y
split-tunneling. El montaje de `R:` se hace una sola vez al iniciar sesión; si en ese momento el
camino activo no era el correcto, la unidad no se monta y, con ABE activo, la carpeta no aparece.

**Alternativa igual de viva, ya señalada:** está mirando en SharePoint / OneDrive, donde este
recurso no existe.

**Artefacto que lo resuelve** (hay que pedirlo al usuario, no es obtenible desde el servidor):
en la sesión que está usando, la salida de `whoami /groups` y de `net use`.

### Pendiente

- **Dispositivos e inicios de sesión en Entra ID sin revisar.** No hay sesión de Graph en este
  equipo y la consola requiere autenticación interactiva. Queda pendiente comprobar en
  Entra ID → Usuario → Dispositivos / Inicios de sesión si arrastra objetos duplicados u
  obsoletos (mismo patrón que el caso de Mara Ramos, 17-ago-2026).
- **Contraseña sin caducidad y sin cambiar desde el alta** (25-feb-2026). No es un incidente,
  pero contradice la política habitual. Merece revisión aparte.

---

## Hallazgos colaterales (fuera del alcance de este ticket)

Detectados al verificar permisos. **Requieren ticket propio.**

1. **La cuenta de diario del técnico es administradora de dominio.**
   `MASWER\IT-Support-Germany` (`CN=Sebastian Lazarte`) es miembro **directo** de
   `BUILTIN\Administrators`, además de `adm1-Administrators` y `adm2-Administrators`. Es el
   único administrador humano del dominio sin cuenta `adm*` dedicada — todos los demás
   (Alejandro Jasso, Miguel Rubira, conet) operan con cuentas separadas bajo `OU=Administratoren`.
   Contradice el modelo de tiers implantado (`adm0` → `Domain Admins`, `adm1` servidores,
   `adm2` puestos). Petición de cuentas nominales redactada para conet.de.

2. **Cuatro cuentas de Oliver Orth (ex-responsable de IT) siguen habilitadas:**
   `Administrator0_OOrth`, `Administrator1_OOrth`, `Admin1_OOrth`, `Admin2_OOrth`.
   La `adm0` pertenece a `adm0-Administrators`, anidado en **`Domain Admins`**.
   `Admin1_OOrth` mantiene además **`FullControl` heredado** sobre los datos del file server
   `MDERZFIL001`.

3. **`CN=tplink,CN=Users` es miembro directo de `Domain Admins`.** Cuenta de servicio de
   dispositivo con privilegio máximo, en el contenedor por defecto.

4. **ACE huérfana:** el SID `S-1-5-21-3299855299-3994495266-3842713779-500` (Administrator
   integrado de **otro dominio**) conserva `FullControl` sobre las carpetas del file server.

---

## Corrección de conocimiento previo

La auditoría del **14-ago-2026** concluyó que la cuenta del técnico era de **solo lectura en
todo el directorio**. Esa conclusión era **falsa** y estuvo vigente 11 días. Causa: se enumeró
el token con `whoami /groups` en la estación de trabajo, que **no muestra los alias BUILTIN del
dominio** — la pertenencia a `BUILTIN\Administrators` la construye el DC al autenticar y nunca
aparece ahí. Método correcto: leer el atributo `member` del alias directamente en el DC vía LDAP.

Impacto operativo: durante esos días se asumió que altas, bajas, resets y cambios de grupo
debían escalarse a conet.de por falta de permisos, cuando podían ejecutarse en local.
