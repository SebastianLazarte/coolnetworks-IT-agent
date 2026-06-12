---
name: freshworks-entity-structure
description: CoolNetworks Freshdesk setup — companies, single shared portal, enabled languages
metadata:
  type: project
---

CoolNetworks' Freshdesk instance is `coolnetworkssoporte.freshdesk.com` ("Coolnetworks s,coop").

- Companies are just groupings inside ONE shared portal — there are no separate per-company portals. Companies seen: Alcautech, Maswer Alemania (~11 contacts), Maswer spain (~13 contacts).
- Help Desk languages: primary = Spanish; supported = English, German; both English and German visible in the widget. So German is fully supported account-wide already.
- Consequence: when a German user "sees everything in Spanish and only Maswer Spain," the root cause is the contact's Company association (e.g. assigned to Maswer spain instead of Maswer Alemania) and/or the contact's own language setting — NOT a missing portal/language config. This type of ticket is resolvable at N1 (reassign contact Company + set contact language), no escalation.

Contact's Company and Language are edited on the contact record (Contacts → open contact → Edit), not in Admin → Companies. Helpdesk languages live in Admin → Cuenta (Account) → Help Desk → Idiomas.
