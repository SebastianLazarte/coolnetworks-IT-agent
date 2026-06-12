---
name: customer-replies-non-technical-by-default
description: Customer replies must be jargon-free by default — no firewall/HA/IPsec/node terms; frame in plain business outcomes
metadata:
  type: feedback
---

When drafting CUSTOMER REPLY, default to **zero technical jargon**. No mentions of: firewall, cluster, HA node, IPsec, tunnel, peer, IKE, gateway, interface, LED, route, BGP, NAT, etc. — even when the issue is technically about exactly that. Frame the situation in plain business terms: "the office there lost internet", "the connection between sites is down", "we need someone at that location to check".

**Why:** Mid-incident on Maswer Vaihingen, after I drafted a customer message mentioning "firewall cluster", "HA nodes" and "ISP outage", the user pushed back: "el cliente no sabe nada de eso, con dificultad usa Excel." [identity.md](../identity.md) already says "I adapt my reply without assuming knowledge" and [rules.md](../rules.md) says "Zero jargon" — this memory makes the default explicit: when in doubt, strip technical terms entirely. Re-add them only if the customer is confirmed technical (e.g., an internal IT lead who's using technical vocabulary themselves).

**How to apply:**
- In the customer reply, **never** mention specific device names (XGSDEFRA01, XGSDEVAI01), tunnel names (S2S_Vaihingen), IPs, or protocol names.
- Translate every technical fact into its business impact: "the tunnel is down" → "the connection between the two offices is down"; "the peer firewall cluster is offline" → "the equipment at the Frankfurt office is offline"; "we need to bounce IPsec on the remote side" → "we need someone at the other office to help us check it".
- Ask only operational, plain-language things — see [[customer-reply-only-ask-operational-info]]. "Give me a phone number for someone at the Frankfurt office" is fine. "Check the LEDs on the firewall" is not.
- **Process jargon is also out, not just device/protocol terms.** "SLA" especially: the customer doesn't know the acronym. Never put "SLA" in a customer message — say the plain benefit instead ("so nothing gets lost", "so we can get back to you faster"). "SLA" stays in the internal blocks only. The user flagged this directly: "no creo que el cliente sepa qué es SLA."
- The TRIAGE / DIAGNOSIS / STEPS / ESCALATE blocks (internal, for the CoolNetworks technician) keep full technical detail. Only the customer-facing block is sanitized.
- Exception: when the ticket itself uses technical vocabulary and is signed by someone clearly technical (e.g. "the BGP peer flapped this morning, can you check?") — match their level.
