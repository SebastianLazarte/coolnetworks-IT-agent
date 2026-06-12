---
name: customer-reply-only-ask-operational-info
description: In customer replies, ask only the operationally required info — not the customer's purpose/context
metadata:
  type: feedback
---

When drafting the CUSTOMER REPLY for a ticket, ask the customer ONLY the information the technician strictly needs to execute the work. Do not ask about what the customer intends to do, why they need it, or how a third party (e.g. their bank) will use it.

Example: for a "create folder X with full access on the Remote Desktop" request, ask only (1) which server and (2) which path. Do NOT ask how/when the bank connects or what they'll do with the app.

**Why:** The user (CoolNetworks technician) stated explicitly: "No nos importa qué harán con la app del banco, solo saber en qué servidor y en qué carpeta se crean." Extra questions slow the customer down and add noise to the ticket.

Related correction: also do NOT override what the ticket explicitly states with our own security model. When the customer explicitly specifies the scope (e.g. "Netzwerkberechtigung mit Vollzugriff" = full-access network permission for the requesting users, on the Remote Desktop), execute exactly that. Do not downgrade it to a least-privilege group or ask for a nominal user list — the "who" and the access type were already given. Least-privilege stays only as an optional, non-blocking note for N2, never a condition or a question.

**How to apply:** Keep customer-facing questions minimal and operational, and limited to what the ticket genuinely leaves unspecified (e.g. server + path). Honor explicit instructions in the ticket as-is. Permission scoping / best-practice opinions stay as optional internal notes for N2/N3 — never as conditions or questions to the customer. See [[freshworks-entity-structure]].
