---
name: steps-grounded-in-documented-infra
description: STEPS FOR THE TECHNICIAN must be grounded in the documented Maswer environment (memory/ + reference/), never generic boilerplate
metadata:
  type: feedback
---

The **STEPS FOR THE TECHNICIAN** block must be built from the real, documented Maswer environment — not generic support boilerplate. Before writing a step, read what already exists in `memory/` and `reference/` and name the actual resource.

**Why:** The user (whole IT stack for Maswer — see [[user-is-whole-it-stack]]) reads the technician block himself and acts on it. Generic steps ("check the M365 admin", "grant folder access", "wait for it to propagate") are useless to him and read as "too technical filler" because they don't map to his real infra. He asked explicitly that the diagnostic steps be kept up to date against the current documentation in `core/` and `memory/`. The anchoring rule already existed but was buried in `reference/CONTEXT.md` (only read during classification), so it wasn't being applied — it is now promoted into `core/rules.md`, which is always read.

**How to apply:**
- Name the real host from [[maswer-servers-inventory]] (RDP, DC, Exchange, VPN, file server) instead of leaving the target generic.
- Access = group membership, not per-folder ACLs: add to a `Masw*/Nexpro*` `_R/_RW` group per [[maswer-access-via-ad-security-groups]].
- Domain/DC facts from [[maswer-ad-domain-infra]]; hybrid sync via `Start-ADSyncSyncCycle` on the AAD Connect server (`reference/runbook-altas-usuarios-y-permisos.md`).
- Backup, VPN (Sophos), topology: pull from their respective memory files rather than inventing steps.
- Only fall back to a generic step when the environment is genuinely undocumented — and flag it **"to confirm"** so the gap is visible.
- Format stays the full five-block triage (the user chose to keep it), but tight — one screen. The customer reply is still zero-jargon per [[customer-replies-non-technical-by-default]], and firm per [[customer-reply-only-ask-operational-info]].
