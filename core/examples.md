# Examples — Three real tickets, end-to-end

These examples show how the specialist processes three different ticket types. Read them before using the specialist for the first time: they teach the tone and format better than any rule.

Note: Examples 1 and 2 show tickets written in Spanish (so the customer reply is in Spanish, internal work in English). Example 3 shows an English-speaking customer.

---

## Example 1 — Simple ticket, resolved at N1

### Input (Freshworks ticket)

> **Subject:** No puedo entrar al correo
> **From:** marta.gomez@cliente-ejemplo.es
> **Body:** Hola, llevo desde esta mañana sin poder entrar a Outlook. Me dice que la contraseña es incorrecta pero estoy segura de que es la buena. ¿Podéis mirarlo? Gracias.

### Specialist output

```
═══════════════════════════════════════
TICKET TRIAGE
═══════════════════════════════════════
Category:    Accounts and Access
Priority:    P2 - High (user blocked, critical function)
Group:       N1 - General Support
Initial SLA: Reply within 1 h

INITIAL DIAGNOSIS
- Main hypothesis: account locked from failed attempts or password
  expiration.
- Alternative hypothesis: MFA failing (phone change, app out of sync).

STEPS FOR THE TECHNICIAN
1. Check in Microsoft 365 admin → Users → marta.gomez whether the
   account is locked or the password has expired.
2. Review the sign-in log for the last 24 h. Look for suspicious
   patterns (unusual IPs, repeated lockouts).
3. If it's not security: reset password with forced change at next
   sign-in. Notify via an alternative channel, not the affected mailbox.
4. If failed attempts come from unknown IPs → ⚠️ escalate to N2
   Cybersecurity before touching anything.

CUSTOMER REPLY
Hola Marta,

He recibido tu aviso. Lo miro ahora mismo.

Para ir más rápido, ¿puedes confirmarme dos cosas?
1. ¿Te falla solo en Outlook escritorio o también si entras desde
   outlook.office.com?
2. ¿Has cambiado de móvil recientemente o te aparece algún aviso
   de verificación al intentar entrar?

Te confirmo en cuanto lo revise.

Un saludo,
Soporte CoolNetworks

ESCALATE?
No, unless the log shows attempts from suspicious IPs.
In that case → N2 Cybersecurity with the log capture attached.
═══════════════════════════════════════
```

---

## Example 2 — Ticket that IS escalated, with a security-incident smell

### Input (Freshworks ticket)

> **Subject:** URGENTE - el ordenador de un compañero está raro
> **From:** itadmin@cliente-ejemplo.es
> **Body:** Buenos días, un usuario nos avisa de que su PC va lentísimo desde ayer. Esta mañana le ha aparecido un mensaje raro pidiendo bitcoin para recuperar archivos. Algunos archivos del servidor compartido tampoco se abren, dan error. ¿Qué hacemos?

### Specialist output

```
═══════════════════════════════════════
TICKET TRIAGE
═══════════════════════════════════════
Category:    Cybersecurity
Priority:    P1 - Critical (active incident, possible ransomware,
             affects shared resources)
Group:       N2 Cybersecurity — immediate escalation
Initial SLA: Reply within 15 min

INITIAL DIAGNOSIS
- Main hypothesis: active ransomware. The user's machine is
  encrypting or has encrypted files on shared resources.
- Risk: spread to other machines via the network and to backups
  if they're online.

STEPS FOR THE TECHNICIAN (immediate action, BEFORE formal escalation)
1. ⚠️ Tell the customer to ISOLATE the affected PC from the network
   now: unplug the cable, turn off WiFi. DO NOT power it off.
2. Tell them NOBODY ELSE should touch files on the shared server
   until further notice.
3. Identify which folders on the server are affected and from what
   approximate time.
4. Check the state of backups: when was the last one, are they
   online or air-gapped.
5. DO NOT try to recover files. DO NOT pay anything. DO NOT reboot
   the PC.
6. Escalate immediately to N2 Cybersecurity with all of the above.

CUSTOMER REPLY
Hola,

Marco esto como prioridad crítica y lo paso al equipo de
ciberseguridad ahora mismo. Mientras tanto, necesito que hagas
esto YA, en este orden:

1. Desconecta el PC afectado de la red (quita el cable o apaga el
   WiFi). NO apagues el equipo.
2. Avisa al usuario de que no toque nada más.
3. Pide al resto del equipo que no abra archivos del servidor
   compartido hasta nuevo aviso.

En 15 minutos te llama un compañero del equipo de ciberseguridad
para tomar el control de la situación.

Esto es importante: no apagues el equipo y no intentes recuperar
archivos por tu cuenta. Cualquier acción puede destruir información
que necesitamos para resolverlo.

Un saludo,
Soporte CoolNetworks

ESCALATE?
YES — N2 Cybersecurity, top priority. Attach:
- Approximate time of first symptom
- User and machine name
- Ransom note (if captured)
- List of affected folders on the server
- State of backups
═══════════════════════════════════════
```

---

## Example 3 — Ticket that is NOT N1, route correctly (English-speaking customer)

### Input (Freshworks ticket)

> **Subject:** ISO 27001 certification inquiry
> **From:** management@example-client.de
> **Body:** Hello, we are considering starting the ISO 27001 certification process for next year. Could you share information on how you handle it, timelines, and rough pricing? Thanks.

### Specialist output

```
═══════════════════════════════════════
TICKET TRIAGE
═══════════════════════════════════════
Category:    Request / Inquiry
Priority:    P4 - Low (not an incident, commercial request)
Group:       Sales / Consulting — handover
Initial SLA: Reply within 1 business day

INITIAL DIAGNOSIS
- This is not a technical support ticket.
- It's a commercial opportunity for a differentiated service
  (ISO 27001 / TISAX certifications).

STEPS FOR THE TECHNICIAN
1. Do not open a technical investigation.
2. Reassign the ticket to the Sales / Consulting group.
3. Notify the customer of the handoff with a brief message.

CUSTOMER REPLY
Hi,

Thanks for reaching out. This one is handled by our Consulting
team — they manage the full ISO 27001 certification process, from
initial assessment through external audit.

I'm passing the ticket along. They'll contact you within one
business day to set up a first call and share timelines and a
ballpark quote.

Best,
Soporte CoolNetworks

ESCALATE?
YES — Reassign to Sales / Consulting.
Mark as "Qualified lead" if your Freshworks has that tag.
═══════════════════════════════════════
```

---

## What these examples teach

- **The format is always the same.** New customer, new technician, new ticket: the triage block has the same structure. That's what lets you read a hundred tickets in a morning without losing rhythm.
- **The customer reply NEVER contains triage jargon.** The customer never sees "P1" or "N2 Cybersecurity". They see a human, clear message in their language.
- **The specialist decides quickly whether it's N1 or not.** If it's not N1, it doesn't waste time diagnosing. It hands off.
- **When something smells like security, act before thinking.** Isolate first, escalate second, investigate last. That order is non-negotiable.
