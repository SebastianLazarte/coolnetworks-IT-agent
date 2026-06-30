# Memory Index

- [User is the whole IT stack](user-is-whole-it-stack.md) — N1+N2+N3 is one person; "escalate to N2" means user continues with deeper diagnostic
- [User prefers terse output, no preamble](user-prefers-terse-no-preamble.md) — when asked for an artifact, deliver only the artifact; no framing, no fill-in instructions, no variant offers
- [Customer replies: ask only operational info](customer-reply-only-ask-operational-info.md) — don't ask the customer their purpose, only what's needed to execute
- [Customer replies are non-technical by default](customer-replies-non-technical-by-default.md) — no firewall/HA/IPsec terms; frame in plain business outcomes (e.g. Maswer contact "barely uses Excel")
- [Availability vs security language](availability-vs-security-language.md) — don't use "harden / mitigate / attack" for uptime incidents; say "improve redundancy / add failover" instead
- [Freshworks entity structure](freshworks-entity-structure.md) — one shared portal, company groupings, ES primary + EN/DE supported
- [Maswer Vaihingen S2S VPN runbook](maswer-vaihingen-s2s-vpn-runbook.md) — total site outage = S2S_Vaihingen tunnel down; bounce to recover, no failover
- [Oliver left Maswer, no handover](oliver-left-maswer-no-handover.md) — Oliver is gone; do NOT contact him; user now owns Maswer IT; get admin access via own creds or conet.de
- [conet.de administers Maswer infra](conet-de-administers-maswer-infra.md) — "conet" is an external company (NOT CoolNetworks); holds admin accounts over Maswer's servers/ACLs — server-side access requests go here; contact Kevin Pütz-Kurth
- [User does not speak German — use English](user-does-not-speak-german-use-english.md) — all vendor/customer comms (conet.de, Maswer) drafted in English, never German
- [Remote access: TeamViewer fails → AnyDesk fallback](remote-access-teamviewer-fails-fallback-anydesk.md) — ad-hoc remote support tooling on Maswer; goal is to standardize on one licensed unattended tool
- [Maswer access via AD security groups](maswer-access-via-ad-security-groups.md) — folder/resource access = membership in Masw*/Nexpro* groups (_R/_RW), NOT per-folder ACLs; grant by adding to the group
- [Maswer AD domain infra](maswer-ad-domain-infra.md) — domain intern.maswer.com, DC MDERZADC003, hybrid Entra, OU + network-drive map; no Restricted Groups GPO for local admin
