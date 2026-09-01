# CONTEXT — Reference knowledge base

This workspace holds the decision logic the N1 specialist applies to every ticket.
Claude reads the one file for the step it is on; it does not load all four at once.

| File | Use it to |
|------|-----------|
| classification-matrix.md | Assign category, priority (P1–P4), group, and SLA |
| diagnostic-trees.md | Produce step-by-step diagnosis by ticket type |
| response-templates.md | Draft the customer reply in the right tone and language |
| escalation-criteria.md | Decide whether/where to escalate and what to attach |
| runbook-altas-usuarios-y-permisos.md | Comandos para crear usuarios, dar acceso a carpetas y forzar sync a M365 (AD híbrido Maswer) |
| runbook-acceso-carpetas-red-maswer.md | **Acceso a carpetas de red (M/O/P/R): mapa unidad→UNC→ruta local, convención carpeta→grupo AD, comandos verificados y errores conocidos. Empieza por aquí en cualquier ticket de "dame acceso a la carpeta X"** |
| maswer-servers-inventory.md (en memory/) | Elegir el host donde actuar (task→servidor): ver la tabla "Qué servidor para qué tarea" |

**Server-targeted steps:** cuando un paso para el técnico actúa sobre un servidor concreto (RDP,
sync, DC, Exchange, VPN, file server), nombra el host desde `memory/maswer-servers-inventory.md`
en vez de dejarlo genérico.

**Editing rule:** each file does one job. Change SLAs in the matrix, tone in
templates, escalation targets in escalation-criteria — without touching the others.
When a ticket type recurs, add a tree to diagnostic-trees.md instead of improvising.
