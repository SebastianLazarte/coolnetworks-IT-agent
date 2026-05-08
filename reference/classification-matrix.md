# Ticket Classification Matrix

Reference table for classifying every incoming ticket. The specialist consults it to assign **category, priority, and group**.

---

## Categories

| Category | What it includes | Typical examples |
|---|---|---|
| **Hardware** | Customer's physical equipment | "The printer won't print", "My laptop won't turn on", "The keyboard is acting up" |
| **Software / Applications** | OS and installed software | "Excel is closing on its own", "Windows won't update", "Outlook is super slow" |
| **Accounts and Access** | Identity, authentication, permissions | "I forgot my password", "I can't log into the ERP", "I need access to folder X" |
| **Network and Infrastructure** | Connectivity and internal services | "We have no internet", "The VPN won't connect", "The shared server isn't responding" |
| **Cybersecurity** | Incidents, alerts, suspicious behavior | "Ransom message", "Weird email asking for data", "Antivirus throwing alerts" |
| **Cloud** | Cloud services (M365, AWS, Azure, GCP) | "OneDrive isn't syncing", "Teams isn't working", "I need a new VM in Azure" |
| **Request / Inquiry** | Not an incident: information or service request | "How much does an extra license cost?", "We want phishing training", "Info about ISO 27001" |

---

## Priorities + SLA

| Priority | When it applies | Initial response | Target resolution |
|---|---|---|---|
| **P1 - Critical** | Service down affecting multiple users or the business. Active security incident (ransomware, intrusion, data breach). Ongoing data loss. | **15 min** | 4 h |
| **P2 - High** | A key user blocked. Critical function degraded. Service works but at risk (e.g. failing backup). | **1 h** | 8 business hours |
| **P3 - Medium** | One user affected, workaround exists. Annoying but not urgent. Most tickets land here. | **4 h** | 2 business days |
| **P4 - Low** | Inquiry, non-blocking request, improvement, scheduled add/remove. | **1 business day** | 5 business days |

### Rules for assigning priority

- **If the customer says "URGENT" but technically it isn't** → I assign by real impact, not by capital letters. But in the reply I confirm I've seen it and explain why I'm treating it as P3 if that's the case.
- **When in doubt between two priorities** → I go with the higher one. The SLA is easier to meet from above than from below.
- **Any suspicion of active security** → automatically P1. No exceptions.
- **"It's slow" complaints** without further context → P3 until scope is confirmed.

---

## Assignment groups

| Group | What it resolves | When I send a ticket here |
|---|---|---|
| **N1 - General Support** | Basic hardware, passwords, user software, inquiries, M365 user level, first touch on everything | By default, everything comes here. It's where I am. |
| **N2 - Systems** | Windows/Linux servers, AD, GPO, corporate network, virtualization, backups, storage | When the issue touches customer infrastructure or requires admin access to servers |
| **N2 - Cybersecurity** | Confirmed incidents, EDR, perimeter firewall, phishing, basic forensics | Any suspicion or confirmation of a security incident |
| **N3 - Specialists** | Advanced cloud (AWS/Azure/GCP architecture), industrial OT/ICS, problems N2 can't resolve, migrations | OT always. Cloud when it's architecture. Anything N2 marks as unsolvable on their end. |
| **Sales / Consulting** | Quotes, contracts, certifications (ISO 27001, TISAX), training, digital transformation | Any non-technical request. Any quote request. Anything that's "we want to start working on X". |

### The escalation rule

When I escalate a ticket, **I NEVER hand it off "clean"**. I always attach:

1. What I tried (with results)
2. What hypotheses I ruled out
3. What key info I already have (logs, screenshots, time of incident, affected users)

The goal is for the N2 technician to open the ticket and know where to continue in 30 seconds. Not start from zero.

---

## Common edge cases

| Situation | How I classify it |
|---|---|
| Customer opens a "nothing works" ticket without further detail | P3, Request / Inquiry initially. I ask for concrete information before classifying properly. |
| Ticket that looks like P1 but only affects the user who opened it | P2 (one user blocked), not P1. P1 only if it affects multiple users. |
| Multiple tickets from the same customer reporting the same issue | The first stays as the main one, the rest I mark as duplicates and link them. Priority goes up if it's confirmed to affect several users. |
| Customer requests a config change with no incident | P4, category by area. Goes to N1 or N2 depending on complexity. |
| A ticket arrives by mistake from someone who isn't our customer | I reply politely that they're not in our database and ask them to verify the right contact. No diagnosis. |
