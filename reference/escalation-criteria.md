# Escalation Criteria

When a ticket leaves N1 and where it goes. When in doubt, escalate rather than risk it, especially with security.

---

## The escalation rule, in one sentence

> If I haven't resolved a similar case at least three times before with confidence, I escalate.

This avoids the "let me try and see" approach in the customer's production. Confidence is earned by resolving, not by improvising.

---

## Escalate to N2 - Systems

**When:**
- Anything requiring admin access to customer servers
- Configuration or modification of corporate Active Directory, GPO, DNS, DHCP
- Virtualization issues (VMware, Hyper-V, Proxmox)
- Backups failing repeatedly or that cannot be restored
- Corporate storage (NAS, SAN) with issues
- Service deployments or migrations
- Network outages affecting multiple users or an entire office
- VPN concentrator down

**What I attach when escalating:**
- Time of first symptom
- Scope (which users, which services affected)
- What I tried and result
- Relevant logs if I gathered them
- Whether there is an agreed maintenance window or it requires immediate action

---

## Escalate to N2 - Cybersecurity

**When (any of these = immediate escalation, P1):**
- Visible ransom note (active ransomware)
- Customer files encrypted or renamed with suspicious extensions
- Targeted advanced phishing email (BEC, executive impersonation, transfer requests)
- Suspicious mailbox rules (unauthorized auto-forward to externals, rules hiding emails)
- Successful login from a country we don't operate in
- Massive failed logins on any account
- Antivirus / EDR has blocked something with suspicious behavior
- Strange processes consuming resources without clear explanation
- Customer reports a user "entered credentials on a weird site"
- Any suspicion of data exfiltration
- Any suspicion of unauthorized access to systems

**What I attach when escalating:**
- Exact time of detection
- Affected user(s) and machine(s)
- Literal message of the possible incident (screenshots if possible)
- Current state: have I isolated? what did I touch? what did I NOT touch?
- State of backups (last one, online or offline)
- Whether the customer has already notified anyone internally

**What I do NOT do before escalating:**
- I do NOT power off the affected machine
- I do NOT try to recover files
- I do NOT respond to the attacker / pay / negotiate
- I do NOT run on-demand antivirus on the affected machine (it can destroy evidence)
- I do NOT restart services

---

## Escalate to N3 - Specialists

**When:**
- **Anything touching OT/ICS** (industrial automation systems, SCADA, PLC). No exceptions. CoolNetworks has a dedicated certified department for this.
- Cloud architecture (AWS / Azure / GCP) beyond basic operations
- Large migrations (to cloud, between datacenters, between providers)
- Big Data, IoT, complex integrations
- Cases where N2 has worked on it and marked as not resolvable on their end

**What I attach when escalating:**
- All the history the ticket already has
- Business context if I know it (project in progress, deadlines, criticality)
- If N2 already touched it: the summary of what they did and why they're escalating

---

## Escalate to Sales / Consulting

**When:**
- Any quote request
- Information request about services (ISO 27001, TISAX certifications, training, digital transformation)
- Contract renewal or upgrade
- Complaints related to billing, terms, contract scope
- "We want to start working on X" when X isn't in the contracted scope

**What I attach when escalating:**
- Customer company
- Contact person and role if I know it
- Service they're asking about
- Any context on urgency or competition

---

## Do NOT escalate (resolve at N1)

For clarity on what stays at N1:

- Standard password resets (with no security suspicion)
- Printer jams, driver issues, peripherals
- Outlook profile or cache problems on a single user
- User software that doesn't start (reinstallation)
- "How do I do X" queries on standard software (Office, Teams, OneDrive)
- Basic user add/removal (following the customer's standard procedure)
- Configuring new printers on a machine
- Basic single-user network issues (cable, WiFi, IP)

---

## Communication when escalating

**I always notify the customer when I escalate.** The message is the one in template 5 in `response-templates.md`. I don't tell them which specific group is taking it (they don't care) but I do tell them which area (systems, cybersecurity, cloud) and when they'll be contacted.

**To the technician receiving the escalation, I deliver a worked ticket.** My goal: that they open it and can decide their next step in 30 seconds. Not start from zero.

---

## Escalation antipatterns (things I don't do)

- ❌ Escalating without having read the entire ticket
- ❌ Escalating without having tried anything at N1
- ❌ Escalating to N2 when it's clearly N3 (wasting N2's time)
- ❌ Escalating to Systems something that's Cybersecurity (wasting critical time)
- ❌ Escalating without key information (time, scope, what I tried)
- ❌ Escalating and not notifying the customer
- ❌ Out of fear of being wrong, keeping a ticket at N1 when it's clearly not ours

The last one is the worst. Reasonable doubt is resolved by escalating, not by hanging on.
