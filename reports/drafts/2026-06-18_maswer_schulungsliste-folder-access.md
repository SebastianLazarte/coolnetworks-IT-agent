# Case report — Maswer / Access to Schulungsliste folder

- **Client:** Maswer AG (Maswer Germany)
- **Requester:** Valle & Stangenberg (likely Vincenzo Valle, vincenzo.valle@maswer.com — opener of the HR-folder ticket 644)
- **End users:** Vincenzo Valle, Angelika Stangenberg
- **Technician assigned:** Sebastian Lazarte Castellón (CoolNetworks)
- **Date opened:** 18-Jun-2026
- **Current status:** OPEN — awaiting requester info (folder location + access level)

---

## Ticket triage

| Field | Value |
|---|---|
| Category | Accounts and Access (folder permissions) |
| Priority | P4 - Low (non-blocking access request) |
| Group | N1 (client-side config) → conet.de if the folder ACL is locked server-side |
| Initial SLA | Reply within 1 business day |
| Escalation | Not escalated yet — gather info and attempt at N1 first. Contingency to conet.de flagged below. |

---

## Request as received

> "Hello IT Team,
> Can you give us (Valle & Stangenberg) please the access to the folder of Schulungsliste. This order is to be placed by Drive ;P Maswser AG.
> Please let me know if you have any questions!"

Folder-access request for the **Schulungsliste** (training list) folder, for two users. Same request pattern and same two users as the HR-folder case (ticket 644).

**Gaps flagged at intake (rule: never make up information):**
1. **Location unspecified** — "to be placed by Drive" is ambiguous: a mapped network drive / file-server share (`\\server\...`) vs. a Google Drive shared folder. The exact path is unknown.
2. **Access level unspecified** — read-only vs. read/write not stated.

---

## Initial diagnosis

- NTFS/share permission grant for two named users on the Schulungsliste folder.
- Sensitivity: lower than HR (training list, no obvious personal/GDPR data) — no special authorization gate expected. Re-check if it turns out to hold personal data.
- Likely blocker (from ticket 644): if Schulungsliste sits on the same Maswer file server, its ACL may have inheritance disabled / the Security tab may not be reachable from the N1 account (owner: Oliver Orth). Server-side ACL changes on Maswer are made by **conet.de**, not CoolNetworks N2. See [[conet-de-administers-maswer-infra]].

---

## Steps for the technician

1. **Locate the folder.** Resolve "Drive": is Schulungsliste on a mapped network drive / file-server share (`\\server\...`) or on Google Drive? Get the exact path before touching anything.
2. **Confirm requested access level** (view only vs. also edit) — needed to set the right NTFS right (Read vs. Modify).
3. **If on the file server:** check current permissions with **Effective Access** for both users (Properties → Security → Advanced → Effective Access). Note inheritance state and owner. If the Security tab isn't visible, browse the server's **local** path (not `\\server\share`) and/or disable the sharing wizard (Folder Options → View).
4. **Grant** NTFS (and Share if applicable) permissions for Valle and Stangenberg at the confirmed level. Have both users **log off/on** to rebuild the security token, then confirm access.
5. **If the ACL is locked** (inheritance off, Security tab not reachable from N1) → do NOT force it. Escalate to **conet.de** (`conetadmin`) with: real UNC path, the two users, access level, and what was already tried.
6. **If "Drive" = Google Drive:** share the folder to both users from the Drive owner / Workspace admin instead — different flow, no file-server ACL.

---

## Customer reply (EN — ticket came in English)

```
Hi Vincenzo,

Got it — happy to set up access to the Schulungsliste folder for you and
Ms. Stangenberg.

Two quick things so I grant the right access in the right place:
1. Where exactly is the folder? A full path or a screenshot of the address
   bar with the folder open is perfect (and let me know if it's on the
   shared network drive or on Google Drive).
2. Should both of you have view-only access, or also edit?

As soon as I have those, I'll set it up and let you know when it's ready.

Best,
Soporte CoolNetworks
```

---

## Escalate?

**No** — handle at N1 first touch: acknowledge + gather the two operational details, then grant.

**Contingency:** if Schulungsliste is on the file server and its ACL is locked (as the HR folder was in ticket 644), route to **conet.de** (`conetadmin`) — they hold the privileged accounts over Maswer's servers/ACLs. Attach: UNC path, users (Valle + Stangenberg), access level, and steps already tried.

---

## Current status & pending

**Status:** OPEN — customer reply sent (info request), awaiting response.

**To progress:**
1. Receive folder location/path + access level from the requester.
2. Grant permissions at N1; have both users log off/on and confirm access.
3. If the ACL is locked → escalate to conet.de with the package above.
4. Close on customer confirmation that both users have access.
