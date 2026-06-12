---
name: maswer-vaihingen-s2s-vpn-runbook
description: Maswer Vaihingen total internet outage = S2S_Vaihingen IPsec tunnel down; recovery runbook
metadata:
  type: project
---

Maswer GmbH's Vaihingen an der Enz site routes its internet/traffic through a single **route-based (tunnel interface) site-to-site IPsec VPN** named **S2S_Vaihingen** on the Sophos XGS firewall (`admin@XGSDEVAI01`, company "Maswer Alemania", managed via Sophos Central, serial X125058C8GJ8H51, profile `S2SVaihingen`). There is **no failover group** configured, so if this one tunnel drops, the entire site loses internet on **both LAN and Wi-Fi** with no automatic backup. This is the most likely root cause whenever Maswer Vaihingen reports a total site outage but the firewall is still reachable via Sophos Central.

**Symptom signature:** whole site, wired + wireless, no internet, since a point in time; firewall console still reachable via Sophos Central; Site-to-site VPN → IPsec → S2S_Vaihingen shows Active 🟢 but Connection 🔴.

**Recovery (fastest-first):**
1. Confirm: firewall reachable via Sophos Central (device alive) + S2S_Vaihingen Connection = red (tunnel down).
2. Capture IPsec logs (page **Logs** / Log viewer → IPsec) BEFORE acting — they vanish once the tunnel is back. Note DPD/peer timeout, Phase 1/2 failure, rekey failure.
3. Quick fix: toggle the connection **Active OFF**, wait ~10s, **ON** → forces full renegotiation; Connection goes green in ~30–60s.
4. If it does not recover → it's the remote peer or WAN/ISP on one side → escalate **N2 Systems, P1** with the log excerpt + "bounce did not recover" + WAN interface status (Network → Interfaces).

**Authorization:** bouncing a production VPN is a production change → allowed at N1 only on a P1 with the customer's explicit "go ahead" recorded in the ticket. Get the line, act, log it.

**Permanent fix (hand to N2 Systems — first aid ≠ cure):** add a failover group / backup path; add Sophos Central / RMM alert on tunnel-down; root-cause recurring drops (unstable ISP on one side, dynamic peer WAN IP without DDNS, or DPD/rekey/lifetime mismatch in the `S2SVaihingen` profile).

Set up by previous IT ("Oliver"). See [[freshworks-entity-structure]] for the Maswer Alemania company mapping.
