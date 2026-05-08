# Customer Response Templates

Standard messages, ready to adapt.

This file has **two sections**:

- **English Templates** (EN-1 to EN-11) → for clients writing in English (most German clients of CoolNetworks fall here)
- **Spanish templates** (1–11) → for customers who write in Spanish

Same order, same intent in each pair. Choose based on the language of the incoming ticket (see the rule in `rules.md`, section "Detecting the customer's language").

**Important:** these are templates, not final responses. The specialist must **always personalize them** with the customer's name, ticket data, and case nuances. A template pasted verbatim is obvious from a mile away.

---

# English Templates

## EN-1. Acknowledgment + asking for info

```
Hi [Name],

Got it, looking into this now.

To move faster, can you confirm:
1. [specific question 1]
2. [specific question 2]

I'll get back to you as soon as I've checked.

Best,
Soporte CoolNetworks
```

## EN-2. Acknowledgment, no extra info needed

```
Hi [Name],

Got it. I'm on it and will get back to you within [realistic time
based on SLA].

Best,
Soporte CoolNetworks
```

## EN-3. "Working on it" update

```
Hi [Name],

Quick update: I'm currently [concrete action, e.g. "checking the
server logs"]. I'll let you know as soon as I have something.

Best,
Soporte CoolNetworks
```

## EN-4. Resolved

```
Hi [Name],

This is resolved.

[1-2 lines explaining what it was and what was done, no jargon]

If you see anything unusual again, just reply here and I'll pick it
back up. I'll close the ticket in 48h if I don't hear back.

Best,
Soporte CoolNetworks
```

## EN-5. Escalating to another team (visible to client)

```
Hi [Name],

This is best handled by our [Systems / Cybersecurity / Cloud] team.
I'm passing the ticket along with all the context we have so far so
they don't start from scratch.

They'll reach out within [time based on priority]. If you don't hear
back in that window, let me know and I'll push it.

Best,
Soporte CoolNetworks
```

## EN-6. Security incident — first message

Critical tone: clear, calm, with immediate instructions. NO panic.

```
Hi [Name],

I'm marking this as critical priority and routing it to our
cybersecurity team right now. In the meantime, I need you to do the
following NOW, in this order:

1. Disconnect the affected machine from the network (cable and WiFi).
   Do NOT shut it down.
2. Tell the user not to touch anything else on that machine.
3. [case-specific actions, e.g. ask the team not to open files on the
   shared server]

Within [time, usually 15 min] a cybersecurity colleague will contact
you to take control of the situation.

Important: do not shut down machines, do not try to recover files,
and do not respond to anything the attackers are asking for.

Any action right now could destroy information we need.

Best,
Soporte CoolNetworks
```

## EN-7. Commercial / consulting request (handing off)

```
Hi [Name],

Thanks for reaching out. This one is handled by our [Commercial /
Consulting] team — they're the people who [brief explanation, e.g.
"manage the full ISO 27001 certification process"].

I'm passing the ticket along. They'll contact you within one
business day.

Best,
Soporte CoolNetworks
```

## EN-8. Client insists on P1 when it's not

Validate without giving in on real priority.

```
Hi [Name],

Got it. I understand this matters to you and I'm taking it
seriously.

Based on what you're describing, I'm treating it as priority
[P2/P3], which means you'll get a concrete answer within
[SLA time]. If anything changes (for example, [a P1-level scenario]),
just let me know and I'll bump it up.

[Then: the question or next step that applies]

Best,
Soporte CoolNetworks
```

## EN-9. Second attempt, missing info

```
Hi [Name],

I still need the following before I can move forward:
- [item 1]
- [item 2]

Got a minute to send those over? If you'd rather have me call,
share a number and a good time.

Best,
Soporte CoolNetworks
```

## EN-10. Closing due to no response

```
Hi [Name],

I'm closing this ticket since we couldn't keep moving forward. If
the issue comes back or you have more info, just reply here and
we'll reopen it without losing context.

Best,
Soporte CoolNetworks
```

## EN-11. Guided steps for end user

For non-technical end users. Maximum care with language.

```
Hi [Name],

Let's try a quick thing — [N] steps:

1. [very specific step, with exact menu/button names]
2. [step 2]
3. [step 3]

When you're done, let me know what you see on screen, or if it
worked. If you get stuck on any step, stop there and tell me.

Best,
Soporte CoolNetworks
```

---

## English-specific notes

- **No "Dear"** unless the client themselves writes "Dear". "Hi [Name]," is the default. If unsure of name, "Hi there," is acceptable but try to use the name.
- **No "Best regards" / "Kind regards" / "Sincerely".** Just "Best," followed by the signature.
- **Avoid British/American specifics** when possible. "Mobile" works in both; "cell phone" is too American. "Schedule" works in both; "diary" is too British. CoolNetworks is European, so neutral business English is the safest register.
- **Same zero-filler rule:** no "Please don't hesitate to reach out", no "I hope this email finds you well", no "Thanks in advance for your patience".
- **Same zero-apology rule:** if there was a real delay, acknowledge briefly and move on. No grovelling.

---

# Spanish templates

## 1. Acknowledgment + asking for info

```
Hola [Nombre],

He recibido tu aviso, lo miro ahora.

Para ir más rápido, ¿puedes confirmarme:
1. [pregunta 1 concreta]
2. [pregunta 2 concreta]

Te confirmo en cuanto lo revise.

Un saludo,
Soporte CoolNetworks
```

---

## 2. Acknowledgment, no extra info needed

```
Hola [Nombre],

Recibido. Lo estoy mirando, te confirmo en [tiempo realista según SLA].

Un saludo,
Soporte CoolNetworks
```

---

## 3. "Working on it" update

When you're already working on it and want to keep the customer informed.

```
Hola [Nombre],

Pequeña actualización: estoy [acción concreta, p.ej. "revisando los
logs del servidor"]. Te confirmo en cuanto tenga algo.

Un saludo,
Soporte CoolNetworks
```

---

## 4. Resolved, confirmed

```
Hola [Nombre],

Resuelto.

[1-2 frases explicando qué era y qué se ha hecho, sin jerga]

Si vuelves a ver algo raro, me avisas y lo retomo. Cierro el ticket
en 48 h si no hay novedades.

Un saludo,
Soporte CoolNetworks
```

---

## 5. Escalating to another group (visible to customer)

```
Hola [Nombre],

Esto lo ve mejor el equipo de [Sistemas / Ciberseguridad / Cloud].
Les paso el ticket con todo el contexto que ya tenemos para que no
empiecen de cero.

Te contactarán [tiempo según prioridad]. Si en ese plazo no has
sabido nada, me avisas y lo empujo.

Un saludo,
Soporte CoolNetworks
```

---

## 6. Security incident — first message

One of the most important. Tone: serious, clear, no alarmism, with immediate instructions.

```
Hola [Nombre],

Marco esto como prioridad crítica y lo paso al equipo de
ciberseguridad ahora mismo. Mientras tanto, necesito que hagas
esto YA, en este orden:

1. Desconecta el equipo afectado de la red (cable y WiFi). NO lo
   apagues.
2. Avisa al usuario de que no toque nada más en ese equipo.
3. [acciones específicas según el caso, p.ej. avisar al equipo de
   no abrir el servidor compartido]

En [tiempo, normalmente 15 min] te contacta un compañero de
ciberseguridad para tomar el control de la situación.

Importante: no apagues equipos, no intentes recuperar archivos por
tu cuenta, y no respondas a nada que pidan los atacantes.

Cualquier acción ahora puede destruir información que necesitamos.

Un saludo,
Soporte CoolNetworks
```

---

## 7. Commercial request (hand off)

```
Hola [Nombre],

Gracias por la confianza. Esto lo lleva nuestro equipo de
[Comercial / Consultoría], que es quien [explicación breve de qué
hacen, p.ej. "acompaña todo el proceso de certificación"].

Te paso el ticket a ellos. Te contactarán en menos de un día
laborable.

Un saludo,
Soporte CoolNetworks
```

---

## 8. Customer insists on P1 when it isn't

You must validate the customer without giving in on the real priority.

```
Hola [Nombre],

Recibido. Entiendo que es importante para ti y lo estoy tratando con
atención.

Por cómo me lo describes, lo trato como prioridad [P2/P3], lo que
significa que tendrás respuesta concreta en [tiempo del SLA]. Si en
algún momento la situación cambia (por ejemplo, [escenario que sí
sería P1]), me avisas y lo subimos.

[Y a continuación: la pregunta o el paso que toque]

Un saludo,
Soporte CoolNetworks
```

---

## 9. Not enough info, second attempt

When the customer didn't reply to the first information request.

```
Hola [Nombre],

Sigo sin poder avanzar hasta tener:
- [dato 1]
- [dato 2]

¿Tienes un momento para confirmármelo? Si prefieres que te llame,
dime el número y la hora que mejor te venga.

Un saludo,
Soporte CoolNetworks
```

---

## 10. Closing due to no response

```
Hola [Nombre],

Cierro este ticket porque no hemos podido seguir avanzando. Si el
problema vuelve o tienes más información, respóndeme a este mismo
hilo y lo reabrimos sin perder el contexto.

Un saludo,
Soporte CoolNetworks
```

---

## 11. Guided steps for end user

When you ask the user (not the customer's admin) to do something concrete. Technical level may be low, so maximum care with language.

```
Hola [Nombre],

Vamos a probar una cosa rápida, son [N] pasos:

1. [paso muy concreto, con nombres exactos de menús/botones]
2. [paso 2]
3. [paso 3]

Cuando termines, dime qué pone en pantalla o si funciona.
Si te quedas atascada en algún paso, paras ahí y me cuentas.

Un saludo,
Soporte CoolNetworks
```

---

## Rules for using templates

- **Always personalize the name.** No generic "Hola buenos días,".
- **Adapt the length to the ticket.** A simple incident does not deserve a 10-line response.
- **One question or one idea per message.** If you need to ask for many pieces of data, do it in a numbered list within a single message.
- **Zero excuses.** No "perdona la demora", "siento las molestias", "disculpa las molestias". If there was a real delay, acknowledge it briefly and move on. The less you apologize, the more professional you sound.
- **Zero filler.** "Quedo a tu disposición para cualquier consulta" adds nothing. The signature already says we're support.
- **Zero empty formulas.** No "esperando tu pronta respuesta", no "agradeciendo tu colaboración".
