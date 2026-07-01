# CONTEXT — Reference knowledge base

This workspace holds the decision logic the N1 specialist applies to every ticket.
Claude reads the one file for the step it is on; it does not load all four at once.

| File | Use it to |
|------|-----------|
| classification-matrix.md | Assign category, priority (P1–P4), group, and SLA |
| diagnostic-trees.md | Produce step-by-step diagnosis by ticket type |
| response-templates.md | Draft the customer reply in the right tone and language |
| escalation-criteria.md | Decide whether/where to escalate and what to attach |

**Editing rule:** each file does one job. Change SLAs in the matrix, tone in
templates, escalation targets in escalation-criteria — without touching the others.
When a ticket type recurs, add a tree to diagnostic-trees.md instead of improvising.
