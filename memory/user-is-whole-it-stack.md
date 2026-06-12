---
name: user-is-whole-it-stack
description: User is sole IT — N1+N2+N3, no real escalation path; treat "escalate to N2/N3" in runbooks as "user continues with deeper diagnostic"
metadata:
  type: user
---

The user at CoolNetworks works the entire IT stack — N1, N2, N3 — alone. There is no separate N2 Systems / N2 Cybersecurity / N3 Specialists colleague to escalate to. When a runbook or reference file says "escalate to N2 Systems P1", in practice the **same user** has to continue the work with the next level of diagnostic.

**Why:** Mid-incident on the Maswer Vaihingen S2S VPN, after I told them to escalate to N2 Systems per [[maswer-vaihingen-s2s-vpn-runbook]], they pushed back: "Yo soy n2 soy todo tengo que arreglarlo." The N1/N2/N3 split in [identity.md](../identity.md), [rules.md](../rules.md), and [reference/escalation-criteria.md](../reference/escalation-criteria.md) is the *role framing on paper* — the user actually wears every hat.

**How to apply:**
- Never end advice with "escalate to N2 / N3" as if the work hands off. Always provide the next level of concrete diagnostic / fix steps inline.
- Treat the reference files' escalation language as **mode switches** ("now move to deeper troubleshooting"), not handoffs.
- Real external boundaries still exist and are real handoffs: ISP support, vendor TAC (Sophos, Microsoft, etc.), the customer's on-site IT, and Sales/Consulting for non-technical asks. Those are not the user.
- Authorization rules, change-management caveats, and "notify the customer on every status change" still apply — what changes is who runs the next technical step (always the user).
- When drafting customer replies after a bounce/fix that didn't work, do **not** say "we're escalating to our systems team" — instead frame it as "we're continuing the investigation on the remote endpoint / line."
