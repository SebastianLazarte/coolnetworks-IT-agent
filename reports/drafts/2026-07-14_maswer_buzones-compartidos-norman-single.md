# Informe de caso — Maswer / Seis buzones compartidos para registros en portales (acceso solo Norman Single)

- **Cliente:** Maswer
- **Dominio:** intern.maswer.com (AD on-prem sincronizado a Entra ID / M365 `maswerag.onmicrosoft.com`; Exchange híbrido, servidor `meuazex001`)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Solicitante:** Vincenzo Valle (vía portal) · **Cc:** norman.single@maswer.com
- **Fecha:** 14-jul-2026
- **Estado actual:** **resuelto pendiente de confirmación del cliente** · seis buzones creados, delegados a Norman y verificados · cliente avisado (15-jul)

---

## Triaje del ticket

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (aprovisionamiento de correo) |
| Prioridad | P4 - Baja (alta programada, no bloqueante) |
| Grupo | N1 - Soporte General, con dependencia de Exchange en producción (ver final) |
| SLA inicial | Respuesta en 1 día laborable |
| Escalado | No escalado — resoluble en N1 si quien ejecuta domina el aprovisionamiento híbrido |

---

## Solicitud tal como llegó

Vincenzo pide **seis direcciones de correo** para seis empleados, para que estos se
registren en los portales de clientes. Condiciones expresas del solicitante:

- Las seis direcciones deben estar **bajo el control de Norman Single** (Norman.Single@maswer.com).
- **Solo Norman Single** debe tener acceso a ellas.
- **Aclaración posterior (14-jul):** *"It is better, if they can answer too"* → las
  direcciones también deben poder **enviar/responder**, no solo recibir.

Empleados indicados (Vorname / Nachname):

| # | Vorname | Nachname |
|---|---|---|
| 1 | Hazim Bin | Khalil |
| 2 | Juan Miguel | Kovacs Bustamante |
| 3 | Luis Alejandro | La Rosa Sanchez |
| 4 | Alejandro | Solis Cruz |
| 5 | Constantino | Vrizz |
| 6 | Kevin Paul | Velez Echeverria |

---

## Interpretación técnica y solución

La pregunta que definía el diseño era **¿solo recibir o también enviar?** Vincenzo
confirmó que necesitan **enviar además de recibir**. Eso descarta los alias (un alias
solo recibe) y fija la solución:

**Seis buzones compartidos (Shared Mailboxes), con acceso exclusivo de Norman Single.**

- Cada dirección es un **buzón compartido** independiente → puede **recibir y enviar**.
- Norman recibe **Full Access + Send As** sobre los seis → los ve en su Outlook
  (automapping), lee y **responde desde cada dirección**.
- **Nadie más** tiene permisos → cumple "solo Norman debe acceder".
- **Sin coste de licencia:** un buzón compartido <50 GB no necesita licencia (siempre que
  no lleve archivo/retención legal).

> **Por qué no alias:** un alias reparte varias direcciones sobre *un* buzón, pero **no
> permite enviar** desde ellas. Al necesitar respuesta, cada dirección tiene que ser su
> propio buzón.

---

## Método de ejecución (ejecutado — Exchange Online directo)

Los buzones se crearon **directamente en Exchange Online** como buzones compartidos
**cloud-only** (no vía on-prem `New-RemoteMailbox`). Es más simple y correcto para este
caso: son buzones que solo usa Norman y no necesitan objeto en el AD on-prem. La creación
directa en la nube es válida aunque el tenant sea híbrido (el buzón queda gobernado en la
nube, no sincronizado desde on-prem).

Ejecutado en **Exchange Online PowerShell** (`Connect-ExchangeOnline`):

```powershell
$norman  = "Norman.Single@maswer.com"
$buzones = @(
  @{ Name="Hazim Bin Khalil";              Alias="HazimBinKhalil";            Smtp="HazimBin.Khalil@maswer.com" },
  @{ Name="Juan Miguel Kovacs Bustamante"; Alias="JuanMiguelKovacsBustamante"; Smtp="JuanMiguel.KovacsBustamante@maswer.com" },
  @{ Name="Luis Alejandro La Rosa Sanchez";Alias="LuisAlejandroLaRosaSanchez"; Smtp="LuisAlejandro.LaRosaSanchez@maswer.com" },
  @{ Name="Alejandro Solis Cruz";          Alias="AlejandroSolisCruz";        Smtp="Alejandro.SolisCruz@maswer.com" },
  @{ Name="Constantino Vrizz";             Alias="ConstantinoVrizz";          Smtp="Constantino.Vrizz@maswer.com" },
  @{ Name="Kevin Paul Velez Echeverria";   Alias="KevinPaulVelezEcheverria";  Smtp="KevinPaul.VelezEcheverria@maswer.com" }
)

foreach ($b in $buzones) {
  New-Mailbox -Shared -Name $b.Name -DisplayName $b.Name -Alias $b.Alias -PrimarySmtpAddress $b.Smtp
  Add-MailboxPermission   -Identity $b.Smtp -User $norman -AccessRights FullAccess -InheritanceType All -AutoMapping:$true
  Add-RecipientPermission -Identity $b.Smtp -Trustee $norman -AccessRights SendAs -Confirm:$false
}
```
- `New-Mailbox -Shared` → sin licencia (quota compartida 49.5 GB confirmada en cada uno).
- `FullAccess -AutoMapping:$true` → los seis aparecen solos en el Outlook de Norman.
- `SendAs` → Norman **envía/responde como** cada dirección.

### Resultado de la ejecución (15-jul)

Los seis buzones creados y delegados a Norman (mismo SID en Full Access y Send As en los
seis, `IsValid: True`):

| Buzón | Creado | Full Access | Send As |
|---|---|---|---|
| Hazim Bin Khalil | ✅ | ✅ | ✅ |
| Juan Miguel Kovacs Bustamante | ✅ | ✅ | ✅ |
| Luis Alejandro La Rosa Sanchez | ✅ | ✅ | ✅ |
| Alejandro Solis Cruz | ✅ | ✅ | ✅ |
| Constantino Vrizz | ✅ | ✅ | ✅ |
| Kevin Paul Velez Echeverria | ✅ | ✅ | ✅ |

> **Los WARNING de la salida son benignos**, no fallos: `Failed to replicate` /
> `prepopulate … Error: 0x8004010F` es el mensaje normal de EXO para un buzón recién
> creado que aún no ha replicado por el servicio ("available for logon in approximately
> 15 minutes"). Los objetos existen (todos con `ExternalDirectoryObjectId` y quota de
> buzón compartido).

### Verificar y probar (tras ~15 min de replicación)
- Confirmar en el Exchange admin center que los seis figuran como **Shared** y sin licencia.
- En el Outlook de Norman deben aparecer solos (automapping).
- Prueba real: enviar a un buzón y **responder desde él** como Norman → confirmar entrada y salida.

---

## Estado actual y siguiente paso

**Estado:** ejecutado y verificado · **resuelto pendiente de confirmación del cliente**.

**Hecho:**
1. Los seis confirmados como **SharedMailbox** con la dirección correcta (`Get-Mailbox`).
2. Full Access + Send As de Norman verificados; prueba de envío/recepción con cuenta admin
   (acceso temporal auto-asignado y retirado al terminar — ver [[prefer-admin-self-test]]).
3. Aviso enviado a Vincenzo (cc Norman): direcciones operativas y listas para registrar.

**Para cerrar:**
4. Cerrar el ticket tras confirmación del cliente (no antes). Si no responde en 48 h tras
   el "resuelto", cerrar con aviso.

**Gobernanza:** Norman Single en **Cc** del ticket → consentimiento del titular registrado.
Acceso limitado a Norman por diseño (solo él con Full Access / Send As); ningún otro
permiso asignado.

---

## Nota de gobernanza (para respaldo del técnico)

**Hecho según lo solicitado por Vincenzo Valle (solicitante autorizado), con Norman
Single —titular del acceso— en copia del ticket.** La solución técnica (buzones
compartidos delegados) es correcta y estándar. Se deja constancia, no obstante, de que
la configuración pedida conlleva implicaciones que **exceden el alcance de N1** y que el
cliente debería revisar:

1. **Rendición de cuentas / suplantación.** Las direcciones llevan nombres de empleados
   reales que no tienen acceso a ellas; Norman actúa "como" cada uno. La traza de
   "quién hizo qué" queda difusa.
2. **Términos de uso de los portales.** Muchos portales de cliente asumen que quien se
   registra es la persona nombrada; usar su identidad sin que la controle puede
   incumplir sus condiciones.
3. **Punto único de fallo.** Todo depende de Norman. Ausencia, baja o salida de la
   empresa deja seis identidades de portal (y sus flujos de verificación/reseteo)
   huérfanas; su offboarding requiere reasignar los seis buzones.
4. **Protección de datos (GDPR).** Hay datos personales de esos empleados entrando en
   sistemas de terceros gestionados por otra persona. Si el cliente lo cuestiona, es
   materia de Consulting, no de soporte técnico.

**Recomendación:** valorar buzones **funcionales** (no con nombre de persona) si el
objetivo es gestión centralizada, y definir un plan de traspaso si Norman deja de estar.
Decisión del cliente; CoolNetworks ejecuta y deja el riesgo señalado.

---

## Cronología

| Fecha | Evento |
|---|---|
| 13-jul | Ticket recibido vía portal (Vincenzo Valle, cc Norman Single): seis direcciones bajo Norman, acceso solo Norman. |
| 13-jul | Triaje inicial. Pregunta decisiva planteada: ¿solo recepción o también envío? (alias vs. buzones compartidos). |
| 14-jul | Vincenzo confirma: *"It is better, if they can answer too"* → también deben enviar. |
| 14-jul | Solución fijada: **seis buzones compartidos** con Full Access + Send As para Norman. |
| 15-jul | **Ejecutado** en Exchange Online (`New-Mailbox -Shared` + permisos a Norman). Los seis creados; warnings de replicación benignos. |
| 15-jul | Verificado: los seis como SharedMailbox, permisos de Norman OK, prueba de envío/recepción con cuenta admin. |
| 15-jul | Cliente avisado (Vincenzo, cc Norman): direcciones operativas. **Resuelto pendiente de confirmación.** |
