---
name: maswer-exchange-hybrid
description: "Maswer es Exchange híbrido — displayName/alias/proxyAddresses se masterizan en el AD on-prem y NO se pueden editar desde M365; se cambian en ADUC + sync"
metadata:
  type: reference
---

Maswer corre **Exchange híbrido**. Los buzones viven en Exchange Online pero sus objetos de
directorio se **sincronizan desde el AD on-premises** (`intern.maswer.com`). Atributos como
`displayName`, `mailNickname` (= "Alias" de Exchange), `mail` y `proxyAddresses` están
**masterizados on-prem** y NO se pueden editar desde el centro de administración de M365 /
Exchange — al intentarlo salta *"out of the current user's write scope… the object is being
synchronized from your on-premises organization."*

**Para cambiar el nombre/alias de un buzón:** editar el objeto en AD (ADUC → Editor de
atributos: `displayName`, `mailNickname`) contra un DC on-prem — `MDERZADC003` /
`MDERZADC004`, que son el master de identidad ([[maswer-ad-domain-infra]]) — y después forzar
el sync en [[maswer-aad-connect-server]].

**Direcciones de correo:** editar `proxyAddresses` con `-Add` / `-Remove`, **nunca `-Replace`**
de la colección entera. No tocar `mail` ni `targetAddress` salvo que sepas exactamente qué
haces.

⚠️ **El servidor `MEUAZEX001` NO tiene Exchange instalado**, pese a la etiqueta "ExchangeServer"
de Defender — verificado en la máquina el 22-jul-2026. Los cmdlets `*-RemoteMailbox` no existen
ahí. Detalle en [[maswer-servers-inventory]].

Tenant M365 = `maswerag.onmicrosoft.com`. La capa de servidor la gestiona
[[conet-de-administers-maswer-infra]].
