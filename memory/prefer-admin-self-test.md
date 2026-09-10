---
name: prefer-admin-self-test
description: "Para pruebas que necesitan acceso que Sebastian no tiene, el default es autoconcederse acceso temporal y probarlo él — no encaminar la prueba por el usuario final o el dueño del recurso"
metadata:
  type: feedback
---

Cuando una prueba o verificación necesita acceso que Sebastian no tiene ahora mismo
(un buzón compartido, una carpeta, un recurso), el **default** es: **Sebastian, como
admin, se da acceso temporal, lo prueba él mismo, y se lo quita al terminar**. NO
encaminar la prueba por el usuario final ni por el dueño del recurso (p. ej. "que lo
haga Norman desde su Outlook") como opción principal.

Es admin (Global/Exchange, y [[sebastian-ad-privileges]] en el directorio) y puede validar
entrada y salida él solo con su propia cuenta de Maswer — sirviendo además de emisor/receptor
interno para la prueba.

**Why:** hacerle depender de un tercero es más lento y es justo lo que ya rechaza
en [[no-remote-sessions-endusers]] (usar rutas admin/server-side, no al usuario). Él
quiere poder cerrar la verificación por su cuenta.

**How to apply:** al proponer cómo probar algo, ofrecer PRIMERO el flujo de
autoservicio de admin: `Add-MailboxPermission`/`Add-RecipientPermission` (o el permiso
que aplique) a su cuenta → probar por OWA "Abrir otro buzón" / la vía que corresponda →
`Remove-…` para dejarlo como pedía el ticket. Dejar "que lo haga el dueño" solo como
alternativa secundaria. Para permisos NTFS, la mecánica exacta (purga de tickets, replicación,
revocación asimétrica) está en [[test-token-refresh-without-logoff]]. Ver [[user-identity]].
