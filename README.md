# CoolNetworks — N1 Support Specialist

A specialist that acts as a **Level 1 Support Technician for CoolNetworks**. It receives a Freshworks ticket (pasted text or screenshot), classifies it, proposes a diagnosis, drafts the customer reply, and decides whether to escalate.

**Bilingual:** automatically detects whether the customer wrote in Spanish or English and replies in their language. Internal work (triage, diagnosis, escalation) is always in English, for the CoolNetworks team.

Works cold, with no configuration, in under five minutes.

---

## What this specialist does

For each ticket you give it, it returns:

1. **Triage:** category, priority (P1–P4), assignment group, and SLA
2. **Initial diagnosis** and verifiable steps for the human technician
3. **Ready-to-send customer reply**, in the customer's language, ready to paste into Freshworks
4. **Escalation decision** and, if applicable, the destination group and the information to attach

---

## How to use it

1. Create a new Project on Claude.ai (or open any conversation)
2. Upload this entire folder to the Project (Knowledge / Project Files)
3. Start the conversation with one of these two prompts:

### Short prompt

```
You are the N1 technician at CoolNetworks. Read identity.md, rules.md and
examples.md before replying. Here is the ticket:

[paste the Freshworks ticket here]
```

### Prompt without Project (pasting files in a single conversation)

If you don't use Projects, paste this and then the contents of `identity.md`, `rules.md`, and `examples.md` (in that order), followed by the ticket:

```
You will act as the N1 support technician at CoolNetworks. I'm passing
you three documents that define your role, your rules, and examples.
Read them and reply using the format you'll see in the examples. Then
I'll send you the ticket.
```

---

## What to expect as output

You'll see a triage block with this shape:

```
═══════════════════════════════════════
TICKET TRIAGE
═══════════════════════════════════════
Category:    ...
Priority:    ...
Group:       ...
Initial SLA: ...

INITIAL DIAGNOSIS
- ...

STEPS FOR THE TECHNICIAN
1. ...
2. ...
3. ...

CUSTOMER REPLY
[text ready to paste into Freshworks]

ESCALATE?
[Yes/No + reason and which group if applicable]
═══════════════════════════════════════
```

See `examples.md` for three real tickets processed end-to-end: a simple one resolved at N1, one with a security-incident smell escalated as P1, and a commercial one routed to Consulting.

---

## Folder structure

```
coolnetworks-tecnico-n1/en/
├── identity.md           Who the specialist is, what it covers and what it does NOT
├── rules.md              How it replies, output format, what it never does
├── examples.md           Three tickets resolved end-to-end
├── reference/
│   ├── classification-matrix.md   Categories, priorities, groups, SLA
│   ├── diagnostic-trees.md        Step-by-step diagnosis by type
│   ├── response-templates.md      Standard customer messages
│   └── escalation-criteria.md     When to escalate and to whom
└── README.md             This file
```

Each file does one job. If you want to change the tone → `rules.md`. If you want to add a ticket type you see often → a new tree in `reference/diagnostic-trees.md`. If SLAs change → `reference/classification-matrix.md`. Editing one doesn't break the others.

---

## How to customize it for your company

This folder is built for CoolNetworks (a Spanish IT/cybersecurity company serving mid-sized businesses with on-prem servers), but the pattern works for any MSP. To adapt it:

- **`identity.md`** → change company name, technician profile, language, customer type
- **`reference/classification-matrix.md`** → adjust categories, priorities, SLAs, and groups to yours
- **`reference/escalation-criteria.md`** → adapt the groups to your organization
- **`reference/response-templates.md`** → change the tone to your brand voice
- **`examples.md`** → replace the three examples with three of your own real tickets (anonymized)

`rules.md` should survive most customizations: the operational rules (don't ask for passwords, don't touch production without a maintenance window, escalate before improvising) are the same in any serious support practice.

---

## Why it's organized this way

This follows **Interpretable Context Methodology (ICM)**: the folder structure *is* the specialist's architecture. Each file does a single job. When Claude is processing a security ticket, it needs `escalation-criteria.md` and `diagnostic-trees.md`; it doesn't load the commercial templates. That keeps the model's attention focused and context costs low.

If you need to change how the specialist replies, you edit a markdown file. No configuration, no code, no framework. It's a folder. Anyone with a text editor can maintain it.

---

## Status and known limitations

- **Built for Freshworks (Freshdesk/Freshservice).** Categories, priorities, and group names follow that model. Adaptable to Zendesk, Jira Service Management, etc., by editing `classification-matrix.md`.
- **Does not connect to Freshworks automatically.** You paste the ticket, it returns the triage. API integration is the next iteration.
- **Does not replace the human technician.** It's an assistant that prepares triage and the reply. The final decision (especially around escalation and touching production) belongs to the person.
- **Built for mid-sized companies with on-prem infrastructure.** If your customer profile is very different (micro SMB, large enterprise with internal SOC, pure OT), adjust `identity.md` and the diagnostic trees.

---

## License

MIT.
