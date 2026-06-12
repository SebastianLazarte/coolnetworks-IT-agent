# Case report — Maswer / New user provisioning (gabrera)

- **Client:** Maswer (Maswer Spain — Barcelona)
- **Domain:** intern.maswer.com (on-prem AD synced to Entra ID / M365; Exchange likely hybrid via `meuazex001`)
- **Technician assigned:** Sebastian Lazarte Castellón (CoolNetworks)
- **Trigger:** "Alta de usuario" form requesting a new account with the same access as an existing employee
- **Date:** 03-Jun-2026
- **Current status:** in progress · account + mailbox created, **login/UPN pending**

---

## Ticket triage

| Field | Value |
|---|---|
| Category | Accounts and Access (user provisioning) |
| Priority | P4 - Low (non-blocking add request) |
| Group | N1 - General Support |
| Initial SLA | Reply within 1 business day |
| Escalation | Not escalated (standard provisioning at N1) — flagged 1 dependency, see below |

---

## Request as received (form)

| Field | Value |
|---|---|
| Prename | gestamp |
| Surname | Abrera |
| Mailaddress | *(blank)* |
| Company | Maswer Spain |
| Location | Barcelona |
| Access | "The same folders as the employee silvia.rosales" |

**Two gaps flagged at intake (rule: never make up information):**
1. **Mailaddress blank** → no email/UPN supplied. Address later defined as `gabrera@maswer.com`.
2. **"gestamp / Abrera" does not parse as a personal name** — Gestamp is a company (automotive) and Abrera a town in Barcelona. Likely a site/functional account for the Gestamp-Abrera project, or fields filled in wrong. **Person-vs-functional account still unconfirmed.**

---

## Work done

### Active Directory
- New user object created in on-prem AD (`intern.maswer.com`).
- Access replicated from **silvia.rosales** by copying her **security group memberships** (group-based folder access — new user not added directly to folder ACLs, silvia's mailbox not reused).
- Object confirmed **synced** to M365 (appeared in the admin center on its own after creation → directory sync / Azure AD Connect in place).

### Licensing & mailbox (M365)
- Same license SKU as silvia.rosales assigned via M365 admin center.
- Cloud mailbox auto-provisioned by the Exchange Online license (no separate "activate mail" step).

### Email addressing
- Working address set to **`gabrera@maswer.com`** (initial + surname).
- **`gestamp.abrera@maswer.com`** kept as a secondary **alias** (receive-only).
- Correct path for a synced/hybrid mailbox documented: change the primary on-prem with
  `Set-RemoteMailbox -Identity gabrera -PrimarySmtpAddress gabrera@maswer.com`
  (run in the on-prem Exchange Management Shell), **not** by hand-editing `proxyAddresses`
  (risk of dropping the `…@maswer.mail.onmicrosoft.com` routing address and breaking mail flow).

### Communication
- Drafted customer "ready to verify" reply (Spanish). Temporary password to be delivered through a **separate secure channel**, never in the ticket; account set to force password change at first sign-in.

---

## Naming / login clarification (root of the friction)

- **Login uses the UPN, not the email address.** An SMTP **alias never works for sign-in**.
- For sign-in with an `@maswer.com` identity to work, the **UPN must be that address**, which requires:
  - `maswer.com` **verified** as a domain in M365, and
  - `maswer.com` added as a **UPN suffix** in *Active Directory Domains and Trusts*.
- Decision pending: pick **one** address as the UPN (login); the other stays as a mail alias.

---

## Timeline

| Date | Event |
|---|---|
| 03-Jun | Form received. Intake gaps flagged (blank email, ambiguous name). |
| 03-Jun | User created in AD; silvia.rosales group memberships replicated. |
| 03-Jun | Object confirmed synced — appeared in M365 admin center. |
| 03-Jun | M365 license assigned (parity with silvia); cloud mailbox provisioned. |
| 03-Jun | Email addressing defined: `gabrera@maswer.com` primary, `gestamp.abrera@maswer.com` alias. |
| 03-Jun | Sign-in failing with the email address → identified as UPN vs alias mismatch. **Open.** |

---

## Current status & pending

**Status:** in progress · account live, sign-in not yet working

**To close this ticket:**
1. **Set the UPN** to the intended login address and confirm `maswer.com` is verified + added as a UPN suffix:
   - `Set-ADUser gabrera -UserPrincipalName <login>@maswer.com`
   - then `Start-ADSyncSyncCycle -PolicyType Delta`, wait a few minutes, test at office.com using the **UPN**.
2. **Confirm the Exchange model** (hybrid via `meuazex001` vs pure cloud) — decides whether address changes go through `Set-RemoteMailbox` on-prem or the cloud admin center.
3. **Verify with the customer:** sign-in OK, folder access matches silvia.rosales, send/receive mail test.
4. Deliver the temporary password via a secure channel (not the ticket).

**To confirm with the requester (governance):**
5. **Person or functional/shared account?** If several people will use the Gestamp-Abrera mailbox, a **Shared Mailbox** (no license, up to 50 GB) is cheaper and more correct than a licensed user. If it's a real person, set the primary to their real `firstname.lastname` and keep `gabrera` / `gestamp.abrera` as aliases.

**Dependency that could move this to N2 Systems:**
6. Editing a **hybrid** mailbox's primary address is production mail flow — if `Set-RemoteMailbox` is not a confident, repeated operation, confirm with N2 Systems before running it.
