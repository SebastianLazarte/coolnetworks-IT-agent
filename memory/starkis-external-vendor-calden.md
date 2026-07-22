---
name: starkis-external-vendor-calden
description: "STarkis" = STAkis Profi by STAHLGRUBER, a 3rd-party workshop/auto-parts app used at Maswer's Calden site. STAkis issues are resolved by opening a support case with STAHLGRUBER (not an internal N2/N3 escalation), after ruling out our-side causes (network drive, client version, AD-group access, UAC elevation).
metadata:
  type: project
---

"STarkis" (as spelled in Maswer Calden tickets) is **STAkis Profi**, the workshop-management and auto-parts software from **STAHLGRUBER** — a third-party vendor. Confirmed across prior cases (05-jun, 23-jun-2026) and reaffirmed by the user (2026-07-21). The STAkis **client is already provisioned on Maswer's network drive** (`KWB_STAKIS_NET_CLIENT.EXE`, source "Netzwerklaufwerk") — so installer/licence are usually NOT the blocker; per-machine config is.

**Vendor channels (STAHLGRUBER):** portal `kunden.stahlgruber.de` · support `stakis.support@stahlgruber.de` · hotline `0800 5782-547`.

**Why:** STAkis is not our software. Beyond confirming it isn't a Maswer-side problem (network-drive mapping, client version, per-user access via AD security group — see [[maswer-access-via-ad-security-groups]], or UAC elevation — the 23-jun case blocked on `MASWER\localadmin` error 1385), the fix depends on the vendor.
**How to apply:** N1 pre-checks on the affected PCs → collect exact errors/versions per machine → open a vendor case with STAHLGRUBER in **English** (user does not speak German — see [[user-does-not-speak-german-use-english]]). This is vendor coordination, NOT an internal N2/N3 escalation.

Recurring topic at **Calden** (already flagged as an "old, separate" issue in Joachim's 18-may-2026 ticket; three-machine case on 21-jul-2026: OK on the central computer, partial on Joachim, none on Jan Lukas). Still to confirm: whether the client connects to a central instance/DB on the Calden "central computer" (LAN 192.168.3.0/24 — see [[maswer-network-topology]]). Site contacts in [[maswer-calden-contacts]].
