# Sebastián Lazarte Castellón

**Systems & Infrastructure Engineer · AI Automation**

<!-- Fill in before sending: -->
`[City, Country]` · `[Phone]` · `[Email]` · `[LinkedIn]` · `[GitHub]`

---

## Profile

Systems engineer running the IT service for an automotive-sector industrial client single-handed
across 14 sites in four countries — the full stack, from end-user support through hybrid Active
Directory, Azure, Exchange Online and Sophos perimeter security. I took the account over after my
predecessor left with no access handover and no documentation, and rebuilt it into a documented,
auditable operation. Alongside that, I design and ship AI agents applied to real IT operations.

---

## Experience

### CoolNetworks — Systems & IT Support Engineer
**May 2026 – present** · Spanish IT and cybersecurity managed service provider (MSP) ·
Assigned account: automotive-sector industrial client (Germany, Spain, Mexico, USA)

#### Infrastructure and systems
- **Sole owner** of the account's IT service, covering L1, L2 and L3 with no internal escalation
  tier above me; the only genuine handoffs are vendor support (Sophos, Microsoft), the ISP, and
  the client's own on-site IT.
- Inherited the account after my predecessor left **without an access handover or documentation**.
  Rebuilt the server inventory and WAN topology from scratch by cross-referencing Microsoft
  Defender for Endpoint, the Azure Portal and the client's official network diagram, then turned
  it into reusable operational documentation — host inventory, task-to-server index and runbooks.
- Administer a **hybrid Active Directory / Microsoft 365** estate: domain controllers on-premises
  and in Azure (West Europe and South Central US), Entra Connect, high-availability Pass-Through
  Authentication agents and Seamless SSO.
- Run the monthly patching and reboot cycle across the Windows Server 2019/2022 fleet.

#### Networking and perimeter security
- Traced a **full site outage** at a German location (**P1, first response inside the 15-minute
  SLA**) to root cause: a down IPsec site-to-site tunnel on a Sophos XGS firewall **with no
  failover group configured**. Wrote the recovery runbook and specified the missing preventive
  controls — failover group, tunnel-down alerting and root-cause analysis of the link.
- Manage the client's **Sophos Central** estate: 3 XGS firewalls, remote-access SSL VPN and
  site-to-site tunnels in a hub-and-spoke topology, with two Azure regions joined by native
  VNet peering.
- Found that a **production firewall in the European region was not enrolled in Sophos Central**,
  leaving it outside centralised management, inventory and reporting.

#### Identity, mail and Microsoft 365
- Found a leaver's account still **live for roughly six weeks and in use by a different person**.
  Ran the controlled handover — object backup via `Export-Clixml`, rename preserving the SID so
  the Windows profile survived, mailbox and group reassignment — against a rollback procedure
  written in advance.
- Diagnosed an **Azure AD Connect stall that had gone ~18 hours without syncing** and raised no
  alert, and restored it. Also documented the Microsoft Defender for Cloud alert (*Potential Entra
  Connect Sync tampering*) triggered by the service restart, classifying it as a true positive on
  a benign action.
- Established that a server tagged **ExchangeServer** in Defender for Endpoint **had no Exchange
  installed** — verified against binaries, registry and services. The finding corrected the
  client's mail-address procedure, which moved to incremental `proxyAddresses` edits in AD.
- Provisioned and delegated **6 shared mailboxes** in Exchange Online (Full Access + Send As, no
  licence consumed) and documented the governance risks that came with them: impersonation, single
  point of failure and personal-data handling.
- Ruled out a reported outbound mail problem by verifying **SPF, DKIM and ten days of message
  trace with zero delivery failures**; identified the **missing DMARC record** on the corporate
  domain and recommended publishing it.

#### Data, access and compliance
- Recovered **100 % of the ISO 14001 management-system documentation** deleted from a file server,
  pinpointing the last valid **VSS** snapshot by comparing successive copies and restoring from the
  shadow copy's `DeviceObject` — **no data loss and no impact on the rest of the share**.
- Off the back of that case, identified two traceability gaps — no delete auditing configured and a
  **security log retaining only ~6 days** — and wrote the corrective action plan and technical
  runbook: delete SACL applied by subcategory GUID, security log expansion, and correlation of
  events 4660/4663/4656 by Handle ID.
- Prepared the evidence pack for a remote **ISO/IEC 27001:2022 and ENS (Spanish Royal Decree
  311/2022)** audit across 9 in-scope systems, mapping Annex A controls and rehearsing 8 live
  scenarios: offboarding, ransomware, stolen laptop, critical firewall CVE, sensitive-folder access
  and impossible travel in Entra ID.
- **Stopped** an access grant to a departmental share on finding its groups were segmented by end
  automotive customer: granting them as a batch would have created cross-access between competing
  manufacturers, against the need-to-know segregation **TISAX** requires.
- Own the security-alert lifecycle across a Sophos Central → SIEM (Wazuh/Elastic) → ticketing
  chain. At the last review I triaged **16 open alerts, 100 % network-operational and none a
  threat detection**.
- Halted a user-provisioning request showing **business email compromise (BEC)** signals: signed by
  a third party, credentials requested for the requester rather than the account holder, and no
  identified approver.
- Verified **Microsoft 365 backup coverage** (Hornetsecurity 365 Total Backup) and documented the
  difference between native M365 retention and a real backup, as audit evidence.
- Manage file-server permissions through **AD security groups** rather than per-folder ACLs — 31
  groups applied to two users in one intervention — deliberately holding back global-scope groups
  until their effective ACL was validated.

#### Support, documentation and communication
- Own the full ticket lifecycle in **Freshdesk**: triage, priority, SLA, diagnosis, customer reply
  and closure. Logged first-response times of **11, 37 and 42 minutes** on software, connectivity
  and access incidents.
- Write the case and executive reports the MSP delivers to the client's management, using a
  Markdown → Word/PDF pipeline I built in PowerShell.
- Work in a trilingual environment: tickets in Spanish, English and German, with internal
  documentation in English and client deliverables in Spanish.

---

## Selected project

### Level 1 IT support agent — design and production rollout
*Personal project, applied to CoolNetworks' live operation · Public repository, MIT licence*

- Designed and shipped an **AI agent that triages Freshworks tickets**: it classifies them
  (7 categories, P1–P4 priority, assignment group and SLA), proposes an initial diagnosis, drafts
  the customer reply in the customer's own language ready to send, and decides whether to escalate
  and with what supporting information.
- Context architecture built on **Interpretable Context Methodology (ICM)**: the folder structure
  *is* the agent's architecture. Each file does one job, so a security ticket loads the escalation
  criteria and diagnostic trees rather than the commercial templates. That keeps the model's
  attention focused and context costs low, and it stays maintainable with a text editor — no code,
  no framework.
- Knowledge base: an SLA-bearing classification matrix, **7 diagnostic trees anchored to the real
  infrastructure** (named hosts, AD groups and runbooks, never boilerplate), **22 bilingual
  ES/EN reply templates**, escalation criteria, and a persistent memory layer holding the client's
  operational facts.
- Safety rules encoded into the agent itself: never request passwords, never touch production
  without an agreed maintenance window, never improvise on a possible security incident.
- Also produces the case and executive reports, exported to Word and PDF through PowerShell
  automation.

---

## Technical skills

| Area | Technologies |
|---|---|
| **Identity and directory** | Active Directory, ADUC/RSAT, Group Policy, Entra ID, Entra/Azure AD Connect, Pass-Through Authentication, Seamless SSO, MFA, Kerberos, tiered administration model |
| **Microsoft 365** | Exchange Online and hybrid, shared mailboxes and delegation, SharePoint, OneDrive, Teams, Outlook, Intune, Microsoft Purview, SPF/DKIM/DMARC |
| **Cloud and virtualisation** | Azure (VMs, VNet peering, UDR, multi-region), Azure Virtual Desktop |
| **Networking and security** | Sophos XGS and Sophos Central, IPsec site-to-site and SSL remote-access VPN, hub-and-spoke topology, Microsoft Defender for Endpoint and for Cloud, Wazuh/Elastic (SIEM) |
| **Backup and recovery** | Shadow Copies (VSS), Hornetsecurity 365 Total Backup, data recovery and integrity verification |
| **Scripting and automation** | PowerShell (ActiveDirectory module, Exchange Online, `Invoke-Command`/WinRM, ACLs and `icacls`, `auditpol`, `wevtutil`, Word COM) |
| **Compliance** | ISO/IEC 27001:2022, ENS (RD 311/2022), TISAX, GDPR, NIST CSF 2.0 |
| **Service and tooling** | Freshdesk/Freshworks (SLA, groups, automations), Git, Markdown, technical writing |
| **Applied AI** | Domain-knowledge agent design, context engineering (ICM), Claude / Claude Code |

---

## Languages

- **Spanish** — native
- **English** — professional; my working language for technical and internal documentation
- **German** — German-speaking working environment; I process German tickets and reply in English

---

<!--
=====================================================================
FOR YOU TO COMPLETE — not present in the repository
=====================================================================

## Education
- [Degree, institution, years]

## Certifications
- [e.g. AZ-900, MS-900, SC-900, MD-102, Sophos certifications]

## Earlier experience
- [Roles before CoolNetworks: company, title, dates, 2-3 achievements]
  Note: the "5+ years in IT support" profile in core/identity.md is the
  agent's fictional persona, NOT your biography. Fill this section with
  your actual track record.

=====================================================================
NAMED-CLIENT VARIANT
=====================================================================
If CoolNetworks authorises naming the account, replace in the
Experience header:

  "Assigned account: automotive-sector industrial client
   (Germany, Spain, Mexico, USA)"

with:

  "Assigned account: Maswer Group (Maswer AG / GmbH / Spain S.L.),
   automotive-sector industrial supplier"

Never add hostnames, IP addresses, appliance serials, or client
employee names and email addresses.
-->
