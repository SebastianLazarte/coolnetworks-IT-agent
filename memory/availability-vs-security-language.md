---
name: availability-vs-security-language
description: Don't use security-loaded language (harden, mitigate, attack surface) for availability incidents; keep redundancy/resilience framing
metadata:
  type: feedback
---

When writing about an incident, separate **availability/redundancy** language from **security** language. Don't say "harden", "mitigate", "attack surface", "exposure", "compromise" unless there is actual confirmed security context (intrusion, malicious actor, data breach indicators per [reference/escalation-criteria.md](../reference/escalation-criteria.md) section "N2 - Cybersecurity"). For pure availability/uptime issues (link down, peer crash, ISP outage, cluster lockup), use: "improve redundancy", "add a backup path", "review failover", "increase resilience", "operational improvements".

**Why:** During the Maswer Vaihingen / Frankfurt cluster outage, I drafted a reply to CoNet asking if we needed "to harden anything on our side". The user pushed back: "Da a entender que fue un ataque o algo cuando pudo ser solo un fallo de ellos." Security-loaded terms for an availability event (1) misrepresent what happened, (2) put the other party on the defensive during RCA, and (3) can leak into customer-facing comms and falsely escalate the perceived nature of the incident.

**How to apply:**
- Default to availability/resilience framing for: tunnel down, link drop, ISP outage, hardware failure, software lockup, cluster split, power loss, DC issue.
- Reserve security framing for: confirmed intrusion, ransomware, unauthorized access, suspicious lateral movement, data exfiltration, BEC / advanced phishing, or any signal in [escalation-criteria.md](../reference/escalation-criteria.md) under "N2 - Cybersecurity".
- When uncertain, ask "do we have evidence of a malicious actor?" If no → availability framing. If unsure → neutral ("operational improvements", "post-incident review").
- Customer-facing messages especially: never use "harden", "compromise", "attack" unless it actually is one. Per [[customer-replies-non-technical-by-default]] this also keeps comms calm and accurate.
