---
name: conet-de-administers-maswer-infra
description: "conet" = conet.de, an external company (NOT CoolNetworks) that administers Maswer's infrastructure; gatekeeper for server/ACL access
metadata:
  type: project
---

**conet** is a separate external company — **conet.de** — NOT CoolNetworks. Easy to confuse because the admin account `conetadmin` appears with Vollzugriff on Maswer's folder ACLs.

conet.de administers Maswer's infrastructure (file servers, folder permissions/ACLs). When CoolNetworks N1 needs server-level or ACL-level access that it cannot perform itself — e.g. granting access to a locked-down folder like HR where the Security tab is not visible to the N1 account — the request goes to **conet**, not to CoolNetworks N2.

**Why:** Maswer's servers are not administered by CoolNetworks. CoolNetworks handles client-side support; conet.de holds the privileged accounts over the actual infrastructure.

**How to apply:** For any request touching server-side ACLs / file-server permissions on Maswer (e.g. the HR folder access for Vincenzo Valle + Angelika Stangenberg), the escalation path is a request to conet.de with: real UNC path (`\\server\HR`), users, access level, and what was already tried. Note [[oliver-owns-admin-install-accounts.md]] — Oliver Orth is the folder *owner* (Besitzer) on the Maswer side; conet holds the admin accounts.
