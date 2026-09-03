# Case report — Maswer / Acceso y envío desde los buzones HR y Einkauf

- **Cliente:** Maswer Deutschland
- **Solicitante:** Vincenzo Valle (vía portal, en alemán)
- **Usuarios finales:** Angelika Stangenberg, Vincenzo Valle, Franziska Hilger
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha de apertura:** 31-ago-2026 09:30
- **Fecha de ejecución:** 3-sep-2026
- **Estado:** EJECUTADO — permisos aplicados y verificados en consola. Pendiente: prueba de
  envío real, comprobación de DKIM y confirmación de los usuarios tras reabrir Outlook.

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (delegación de buzones, M365) |
| Prioridad | P4 - Baja (concesión programada; nadie bloqueado, ya recibían correo) |
| Grupo | N1 — resuelto en primer toque, sin escalado |
| SLA inicial | Respuesta en 1 día hábil |
| Escalado | No. Todo en Exchange Online con la cuenta `IT-Support-Germany@maswer.com`; conet.de no interviene |

---

## Petición recibida

> "Könnt ihr bitte den Zugang zum Postfach HR für folgende Mitarbeiter freischalten:
> (HR@Maswer.com) — Angelika Stangenberg, Vincenzo Valle, Franziska Hilger.
> Bitte stelle es auch zusätzlich ein, dass wir von dem Postfach HR@Maswer.com &
> Einkauf@maswer.com nicht nur emails empfangen sondern auch emails aus dem Postfach
> schreiben können."

Dos peticiones distintas en un mismo mensaje:

1. **Acceso** al buzón `HR@maswer.com` para los tres nombres.
2. **Enviar como** `HR@maswer.com` **y** `Einkauf@maswer.com` — "no solo recibir, también
   escribir desde el buzón".

**Resolución de la ambigüedad:** el segundo párrafo dice "wir" sin repetir nombres. Se
interpreta como los tres del párrafo anterior — el "quién" ya estaba dado en el mismo mensaje,
así que no se devolvió la pregunta al cliente.

---

## Diagnóstico (verificado, no inferido)

El síntoma "recibimos pero no podemos escribir desde el buzón" tiene dos causas posibles con
soluciones distintas: **grupo de distribución** (los miembros reciben, nadie puede enviar como
él) o **buzón compartido con FullAccess pero sin SendAs**. Se comprobó antes de tocar nada:

```powershell
"HR@maswer.com","Einkauf@maswer.com" | % { Get-Recipient $_ } |
  ft DisplayName,PrimarySmtpAddress,RecipientTypeDetails
```

| DisplayName | PrimarySmtpAddress | RecipientTypeDetails |
|---|---|---|
| HR | hr@maswer.com | **SharedMailbox** |
| Einkauf | einkauf@maswer.com | **SharedMailbox** |

Los dos son buzones compartidos en la nube. Eso descarta la rama on-prem: **no** hay que tocar
grupos en `MDERZADC003` ni forzar `Start-ADSyncSyncCycle` en `MEUAZAC011`. Todo se resuelve en
Exchange Online.

**Limitación honesta:** no se capturó el estado previo de permisos de `einkauf@maswer.com`. Que
ya recibieran correo consta solo por lo que dice el ticket, no por medición propia.

---

## Acción ejecutada — 3-sep-2026

Exchange Online PowerShell desde el equipo del técnico (no hay servidor Exchange que tocar: se
verificó el 22-jul-2026 que `MEUAZEX001` no tiene binarios ni servicios de Exchange).

```powershell
Connect-ExchangeOnline -UserPrincipalName IT-Support-Germany@maswer.com

$users = Get-Recipient -Filter "DisplayName -like '*Stangenberg*' -or DisplayName -like '*Valle*' -or DisplayName -like '*Hilger*'" |
         ? RecipientTypeDetails -eq 'UserMailbox' | select -Expand PrimarySmtpAddress

foreach ($u in $users) {
  Add-MailboxPermission   -Identity hr@maswer.com      -User $u -AccessRights FullAccess -InheritanceType All -AutoMapping:$true
  Add-RecipientPermission -Identity hr@maswer.com      -Trustee $u -AccessRights SendAs -Confirm:$false
  Add-RecipientPermission -Identity einkauf@maswer.com -Trustee $u -AccessRights SendAs -Confirm:$false
}

Set-Mailbox hr@maswer.com      -MessageCopyForSentAsEnabled $true -MessageCopyForSendOnBehalfEnabled $true
Set-Mailbox einkauf@maswer.com -MessageCopyForSentAsEnabled $true -MessageCopyForSendOnBehalfEnabled $true
```

Sobre `Einkauf` se concedió **solo SendAs**, no FullAccess: ya reciben el correo y ampliar el
acceso habría cambiado lo que ven en Outlook sin que lo pidieran.

**Sin ventana de mantenimiento:** son permisos sobre tres usuarios, sin impacto en servicio y
reversibles con `Remove-MailboxPermission` / `Remove-RecipientPermission`.

---

## Resultado verificado

`Get-MailboxPermission hr@maswer.com` (explícitos, sin heredados ni `NT AUTHORITY`):

| User | AccessRights | IsValid |
|---|---|---|
| oorth@maswer.com | FullAccess | True |
| SZimmermann@maswer.com | FullAccess | True |
| FHilger@maswer.com | FullAccess | True |
| AStangenberg@maswer.com | FullAccess | True |
| VValle@maswer.com | FullAccess | True |

`Get-RecipientPermission` — **SendAs** en `hr@maswer.com` y en `einkauf@maswer.com`:
`FHilger`, `AStangenberg`, `VValle` en ambos buzones.

`Get-Mailbox` — copia de lo enviado:

| Buzón | MessageCopyForSentAsEnabled | MessageCopyForSendOnBehalfEnabled |
|---|---|---|
| hr@maswer.com | True | True |
| einkauf@maswer.com | True | True |

Sin ese ajuste, lo que respondan como HR quedaría solo en su propio "Enviados" y no en el del
departamento — trazabilidad rota en un buzón compartido.

---

## Pendiente

1. **Prueba de envío real.** La verificación anterior demuestra que la configuración existe, no
   que funcione de extremo a extremo. Auto-test sin depender de los usuarios: SendAs temporal
   para el técnico → enviar desde `outlook.office.com` con `HR@maswer.com` en el campo **De** →
   `Get-MessageTrace` con `Status: Delivered` → retirar el permiso.
2. **DKIM.** `Get-DkimSigningConfig -Identity maswer.com` antes de que escriban a destinatarios
   externos. En el caso service.calden (21-jul-2026) el envío desde una dirección compartida se
   filtraba de forma intermitente por alineación SPF/DKIM/DMARC.
3. **Confirmación de los usuarios.** El buzón se monta solo (automapping) al cerrar y reabrir
   Outlook; hasta ~60 min de propagación. Un "acceso denegado" en los primeros minutos es
   tiempo de propagación, no un error de permisos (documentado en el caso del 23-jul-2026).

---

## Decisión de alcance registrada

Se planteó exigir **aprobación registrada de un responsable** antes de abrir el buzón de RR.HH.,
por la lección del caso de la carpeta HR (10-jun-2026): datos de personal, RGPD. El técnico
confirmó que la autorización ya estaba cubierta, y se ejecutó sin condicionar el ticket a una
aprobación adicional. Queda constancia aquí de que la decisión se tomó de forma explícita.

---

## Hallazgos colaterales (fuera del alcance de este ticket)

Detectados al leer la lista de permisos del buzón de RR.HH. **Requieren ticket propio.**

1. **`oorth@maswer.com` tiene FullAccess sobre `hr@maswer.com`.** Observado en la salida del
   3-sep. Oliver Orth es el responsable de IT anterior, que salió sin handover; el 14-ago-2026
   se confirmó que cuatro de sus cuentas seguían habilitadas. Un buzón de personal accesible por
   alguien que ya no está en la empresa. **Artefacto que lo resuelve:**
   `Get-User oorth@maswer.com | fl DisplayName,AccountDisabled,WhenChanged`. Si la cuenta está
   habilitada, es acceso vivo. Tratamiento: igual que Rohner/Conow — retirar con fecha de corte
   comunicada, no borrar por iniciativa propia.
2. **`SZimmermann@maswer.com` tiene FullAccess** sobre el mismo buzón. Puede ser perfectamente
   legítimo (personal de RR.HH.); queda anotado porque el resumen ejecutivo del 11-jun-2026
   señalaba justamente que no había inventario de quién accede a los recursos de HR. Ahora, para
   el buzón, lo hay.

---

## Nota de entorno (operativa)

El equipo del técnico no tenía el módulo `ExchangeOnlineManagement` y la directiva de ejecución
de scripts estaba en `Restricted`. Secuencia que lo desbloquea:

```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force -AllowClobber
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force   # o RemoteSigned -Scope CurrentUser, permanente
Import-Module ExchangeOnlineManagement
```

Conviene dejar `RemoteSigned -Scope CurrentUser` para no repetirlo en cada ventana nueva.

---

## Comunicación con el cliente

**Acuse de recibo (EN, enviado el 3-sep):**

```
Hi Vincenzo,

Got your ticket — I'm setting it up now: access to the HR mailbox for
Angelika, you and Franziska, and sending from HR and Einkauf for the
three of you.

I'll confirm here as soon as it's active. You'll need to close and
reopen Outlook for it to show up.

Best,
CoolNetworks Support
```

**Cierre (EN, a enviar tras la prueba de envío):**

```
Hi Vincenzo,

Done — Angelika, you and Franziska now have access to the HR mailbox, and
all three of you can send from HR and Einkauf.

Close and reopen Outlook: the HR mailbox shows up in your folder list on
its own, and you pick the sender address in the From field when writing.
It can take up to an hour to appear.

Let me know if it isn't there for someone after that.

Best,
CoolNetworks Support
```

Idioma: el ticket llegó en alemán, así que la respuesta va en inglés — nunca en alemán
inventado (core/rules.md).

---

## Lecciones para casos similares

- **Comprobar el tipo de objeto antes de conceder.** Un `Get-Recipient` de cinco segundos
  decide entre concesión directa en la nube y una rama completamente distinta (SendAs sobre el
  grupo + miembros en `MDERZADC003` + sync en `MEUAZAC011`). Ejecutar `Add-MailboxPermission`
  contra un grupo de distribución falla y hace perder el viaje.
- **`MessageCopyForSentAsEnabled` no es opcional en buzones de departamento.** Es la diferencia
  entre tener el histórico de lo enviado en el buzón o repartido por los "Enviados" de cada uno.
- **Una lista de permisos es también un inventario.** Los dos hallazgos colaterales salieron de
  la propia salida de verificación, no de una auditoría aparte.
- Un buzón compartido de menos de 50 GB **no consume licencia** — mismo modelo que los seis
  buzones creados para Norman Single (14-jul-2026).
