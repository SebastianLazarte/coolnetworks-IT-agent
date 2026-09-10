# AUDIT OF UNUSED ACCOUNTS AND DEVICES — MASWER

**Client:** Maswer (Maswer AG)
**Scope:** `intern.maswer.com` domain — all user accounts and all computer objects
**Source:** read-only LDAP queries against all four domain controllers
**Reporting cut-off:** 9 September 2026
**Prepared by:** Sebastian Lazarte Castellon — CoolNetworks

---

## Summary

Maswer's directory contains **322 user accounts** and **513 computer objects**. Of the **241 enabled accounts, 82 have no recorded logon for more than a year**, or have never recorded one. Of the 512 enabled computer objects, **344 have not been seen for more than a year**, and **282 of those for more than two years**.

However, 82 is not the answer to "how many accounts should be deleted?" When the accounts are separated according to what they actually represent, **only 22 belong to individuals**. The rest are shared mailboxes, department or site accounts, service accounts and administrative accounts: **inactive by design, and deleting them would break services that are running**. Making that distinction is the purpose of this report, and it was missing from the previous review.

Three conclusions for management:

**01 — There are 22 individuals with enabled accounts and no activity for more than a year.** Twenty of them retain a licensed mailbox, and all twenty-two retain network access through VPN. None can be deprovisioned yet: the directory tells us when an account was last used, never whether the person is still employed.

**02 — The previous administrator's credentials remain enabled and in use.** Three of Oliver Orth's accounts show authentication within the last three days, one with domain administrator privileges. This is the issue requiring immediate action, detailed below.

**03 — Two thirds of the computer inventory consists of stale directory objects.** There are 344 obsolete objects, including six servers that have already been replaced and ten machines with unsupported operating systems. Cleaning them up will not save licences, but it will reduce the attack surface and restore a trustworthy inventory.

---

## Background

This review did not originate from a ticket. It arose from two outstanding issues:

- The Jewgenij Schachow offboarding case (2 September) exposed the pattern and left a written recommendation that had not been implemented: of 217 accounts with VPN access, 64 were enabled with no logon in 90 days, and the oldest dated back to 2020.
- Preparations for the ISO 27001 and ENS audit still include an outstanding corrective action: a periodic access review that is "completed and dated", together with the requirement that no former employees retain an active licence.

There is also a date that determines the financial implications: **Microsoft 365 Business Premium and Basic subscriptions renew on 17 September 2026**. Microsoft's contracting rules only allow seat counts to be reduced at renewal; outside that window, any surplus seats remain committed for another twelve months.

---

## Key environment facts

| Item | Value |
|---|---|
| Domain | `intern.maswer.com` (NetBIOS `MASWER`), single forest and single domain |
| Domain controllers | `MDERZADC003`, `MDERZADC004` (Frankfurt), `MEUAZDC011` (Azure EU), `MUSAZDC011` (Azure US) |
| Hybrid identity | Synchronisation to Microsoft 365 from `MEUAZAC011`, pass-through authentication |
| User accounts | 322 objects — 241 enabled, 81 disabled |
| Computer objects | 513 objects — 512 enabled, 1 disabled |
| Base licensing | Microsoft 365 Business — 218 seats purchased, 180 assigned (export dated 31 Aug 2026) |

---

## Method and calculation basis

**What was queried.** The `lastLogon` and `lastLogonTimestamp` attributes of every account and computer were queried on **all four** domain controllers, retaining the most recent date from the four. All queries were read-only LDAP queries: no object was modified, disabled or deleted.

**Why all four, rather than just one.** `lastLogon` is not replicated between controllers, and the Azure controllers replicate in a chain rather than a mesh. Querying just one produces false "inactive" results: a documented example showed an account as active on 27 August on `MDERZADC003`, while `MUSAZDC011` still showed February. The comparison confirms the effect: querying a single controller produced 83 unused accounts and 345 unused computers; querying all four reduced those figures to 82 and 344.

**Thresholds.** The population is divided into less than 90 days, 90 to 180 days, 180 days to one year, one to two years, more than two years, and no recorded logon. The **one-year** threshold is used for the headline figure.

**What is verified and what is not.**

- **Verified:** whether the account is enabled, its organisational unit, mailbox type, group memberships and most recent authentication date.
- **Not verified:** whether the person has left the company. The directory does not know. Logon activity alone can mistake maternity leave, sick leave, extended leave and occasionally used accounts for abandoned accounts.
- **What would resolve this:** the HR list of active employees. Only Maswer can fill in that column.

**A margin to bear in mind.** `lastLogonTimestamp` is replicated with a delay of up to 14 days, so dates may lag by that amount. This is immaterial for a one-year threshold, but matters if the threshold is ever reduced to 30 days.

**How each account is classified.** The main criterion is the mailbox type assigned by the directory, rather than the name. A user mailbox indicates an individual or a licensed seat; a shared mailbox never represents an individual; no mailbox indicates a technical account. Names are used only to distinguish individuals from department accounts within the first group, using an explicit list that can be reviewed.

---

## User accounts

### Overview by time since last logon

Of the 241 enabled accounts:

| Time since last logon | Accounts |
|---|---|
| Less than 90 days | 128 |
| 90 to 180 days | 16 |
| 180 days to 1 year | 15 |
| 1 to 2 years | 22 |
| More than 2 years | 26 |
| No recorded logon | 34 |
| **Total unused for more than a year** | **82** |

### The breakdown that changes the answer

The 82 unused accounts do not represent 82 leavers. Broken down by what they actually are:

| Account type | Enabled | Unused > 1 year | Can be deprovisioned |
|---|---|---|---|
| Individual | 161 | 23 | Yes, after confirmation from Maswer |
| Department, role or site | 20 | 19 | Not without checking: these accounts are used occasionally |
| Shared mailbox | 16 | 13 | No: these are correctly processed leavers |
| Service and technical | 15 | 11 | Only after identifying what uses them |
| Administrative | 18 | 7 | Yes, as a priority — see the dedicated section |
| System and Exchange | 11 | 9 | No: managed by the product itself |
| **Total** | **241** | **82** | |

Of the 23 unused individual accounts, **one was created yesterday and has not yet been used** (Erik Esau Guillermo Valencia, created on 8 September). This is not a leaver. That leaves **22 actual candidates**.

The 13 accounts in the "shared mailbox" row deserve a positive note: most belong to former employees whose mailboxes were converted to shared mailboxes when they left. This is exactly the correct treatment and confirms that the offboarding procedure works when applied.

### The 22 individual candidates

None of these accounts is being deprovisioned through this report. Maswer must complete the right-hand column.

| Account | Name | Last logon | Days | Site | Licence | VPN | Still in use? / confirmed by |
|---|---|---|---|---|---|---|---|
| RGallardo | Rocio del Carmen Gallardo Villanueva | 2024-05-07 | 855 | Puebla | Yes | Yes | |
| CKnoll | Christoph Knoll | 2024-10-11 | 698 | Tuscaloosa | Yes | Yes | |
| VVega | Virginia Vega Nieto | 2024-10-15 | 694 | Zaragoza | Yes | Yes | |
| ERamirez | Eduardo Isaac Ramirez Sanchez | 2025-02-04 | 582 | Puebla | Yes | Yes | |
| KBillingsley | Keambria Billingsley | 2025-03-06 | 552 | Tuscaloosa | Yes | Yes | |
| LMendoza | Luis Alberto Mendoza Jaimes | 2025-04-28 | 499 | Puebla | Yes | Yes | |
| LLopez1 | Leopoldo Lucero Lopez | 2025-05-22 | 475 | Puebla | Yes | Yes | |
| AGarcia | Adriana Garcia Medina | 2025-06-11 | 455 | San Luis Potosí | Yes | Yes | |
| MInal | Mehmet Inal | 2025-06-25 | 441 | Rüsselsheim | Yes | Yes | |
| IJuarez | Isaias Juarez Andrade | 2025-06-26 | 440 | Aguascalientes | Yes | Yes | |
| ELuna | Erik Joel De Luna Gómez | 2025-07-10 | 426 | Aguascalientes | Yes | Yes | |
| GVerdad | Gerardo Verdad | 2025-07-16 | 420 | Puebla | No | Yes | |
| IMartinez | Ilse Martinez | 2025-08-15 | 389 | Aguascalientes | Yes | Yes | |
| HOrtiz | Horacio Ortiz, Jr. | 2023-10-23 | 1,052 | Tuscaloosa | No | Yes | |
| JTeomitzi | Jose Eulalio Teomitzi Carbajal | Never | — | Puebla | Yes | Yes | |
| JSoriano | Jessica Soriano Trujillo | Never | — | Puebla | Yes | Yes | |
| JRosales | Jose Alfredo Rosales Lozano | Never | — | Puebla | Yes | Yes | |
| DEspinosa | Dulce Espinosa | Never | — | Puebla | Yes | Yes | |
| IChakrane | Ibtissam Chakrane | Never | — | Zaragoza | Yes | Yes | |
| GRosales | Cristian Gabriel Rosales Arellano | Never | — | Aguascalientes | Yes | Yes | |
| NDCMarques | Niklas da Costa Marques | Never | — | Vaihingen | Yes | Yes | |
| AdVita | Alessio di Vita | Never | — | Vaihingen | Yes | Yes | |

Two patterns should be highlighted to Maswer:

- **Eight accounts have never been used**, and they are not recent: three were created in April 2024 and two in December 2025. An account that is never used usually means that the person never actually joined, or works without a computer. If the former applies, the licence has been paid for since the account was created.
- **The concentration is geographical.** Fourteen of the twenty-two are in Mexico and three in the United States. Only three are in Germany and two in Spain. This suggests that leaver notifications from the sites in the Americas are not reaching the support service.

### Accounts that must NOT be treated as leavers

Nineteen department, role or site accounts show no use for more than a year, and eighteen consume a licence: `Finanzas MX`, `Compras MX`, `Purchasing USA`, `Payroll USA`, `Finance USA`, `HR Connect`, `Quejas Sugerencias`, `Team Leader`, `Team Leader USA`, `Tech Reporting2 MBUSI`, `Transporte Saltillo`, `IT Support AM`, `Social Networks`, `ADMIN VISADOS`, `CR Zaragoza2`, `Gößnitz`, `Hemau`, `PMX 001` and `replay`.

These are not leavers, but **they are not free either**. Each is a paid seat that nobody opens. The right question is not "who was this?" but "is this mailbox still needed, and who is responsible for it?"

Eleven service accounts have not authenticated for more than a year, five of them for more than five years: `AAD_1f80425d3c6a` (2016), `LDAP_Service2` (2016), `swyx` (2020), `LDAP_Service` (2021) and `LDAP LDAP` (2023), plus `ldap-maswer` and `ldap-service`, which have never been used. These are remnants of retired integrations. **Before changing any of them, the process that used it must be identified**, not afterwards.

### Privileged accounts — the finding that requires action

The domain has **18 enabled administrative accounts**. Seven have not been used for more than a year:

| Account | Owner | Last logon | Days unused |
|---|---|---|---|
| tplink | Device account, direct member of Domain Admins | 2017-03-01 | 3,479 |
| admin | Generic | 2017-03-01 | 3,479 |
| admadfs | ADFS service | 2020-12-08 | 2,100 |
| Admin2_MRGarcia | Miguel Rubira Garcia | 2021-01-07 | 2,071 |
| Administrator1_OOrth | Oliver Orth | 2021-02-10 | 2,037 |
| adm0_conet | Conet Admin | 2025-01-13 | 604 |
| Administrator0_OOrth | Oliver Orth | 2025-05-27 | 470 |

In the case of `tplink`, nine years of inactivity with domain administrator privileges.

**What changes the picture is what is still being used.** Until now, it had not been checked whether the previous administrator's accounts were active or merely still present. This has now been verified:

| Oliver Orth account | Status | Last logon | Privilege |
|---|---|---|---|
| oorth (standard account) | Enabled | 2026-09-08, on three controllers | 18 data access groups, VPN, Backup Operators |
| Admin2_OOrth | Enabled | 2026-09-08, on all four controllers | adm2-Administrators |
| Admin1_OOrth | Enabled | 2026-09-06 | Domain's Administrators group, AzureFiles-Administrators |
| Administrator0_OOrth | Enabled | 2025-05-27 | adm0-Administrators, effective Domain Admins privileges |
| Administrator1_OOrth | Enabled | 2021-02-10 | adm1-Administrators |

**Verified:** the first three have authenticated within the last three days, and `Admin1_OOrth` belongs to the domain's Administrators group.

**Inferred, not confirmed:** that these accounts are not being used by a person. `Admin2_OOrth` records logons **at exactly 12:10 on all four controllers**, on different dates. That regularity is characteristic of a scheduled task or service, rather than someone entering a password.

**What is unknown:** which process it is, which machine it runs on and what logon type it uses. Only the domain controllers' security logs (events 4624 and 4768) can establish this, by filtering for these accounts and examining the source computer and logon type.

**Why this matters either way.** Whether used by a person or a process, credentials belonging to an administrator who no longer works for the company are actively in use today. This has an immediate practical consequence: **simply disabling them would break whatever is using them.** The correct order is therefore to identify first and disable afterwards, never the reverse.

An additional finding answers an outstanding question: a shared mailbox in Oliver Orth's name was created on **1 October 2025**. Converting a mailbox to shared is what happens when someone leaves, so this is very likely to be his departure date.

---

## Devices

### Overview

| Time since last seen | Computers |
|---|---|
| Less than 90 days | 109 |
| 90 to 180 days | 23 |
| 180 days to 1 year | 36 |
| 1 to 2 years | 59 |
| More than 2 years | 282 |
| No record at all | 3 |
| **Total not seen for more than a year** | **344** |

Only **168 of 512 computers have shown activity in the last year**. The breakdown by year of last contact shows an accumulation over a decade rather than a recent spike: 6 computers were last seen in 2016, 16 in 2017, 17 in 2018, 29 in 2019, 28 in 2020, 49 in 2021, 49 in 2022, 53 in 2023, 51 in 2024 and 43 in 2025.

### Replaced servers still present in the directory

| Server | System | Last contact |
|---|---|---|
| MDERZADC001 | Windows Server 2012 R2 | 2023-11-21 |
| MDERZADC002 | Windows Server 2012 R2 | 2023-11-21 |
| MEUAZDC001 | Windows Server 2012 R2 | 2023-11-13 |
| MEUAZPTA001 | Windows Server 2019 | 2023-05-26 |
| MEUAZPTA002 | Windows Server 2019 | 2023-05-24 |
| MDERZAXX03 | Windows Server 2012 R2 | 2021-08-31 |

These are the predecessors of the domain controllers and authentication agents now in service with identifiers ending in 003, 004 and 011. The migration was completed; the directory clean-up was not.

### Unsupported operating systems

Ten obsolete computers run systems that no longer receive security updates: five Windows 8.1 machines in Barcelona and Zaragoza, four Windows Server 2012 R2 machines (those in the preceding table), and one Windows 7 machine (`XEROXFBH`, with no contact since January 2017). None has been seen for years, so they most likely no longer exist physically. Confirming this closes an audit finding at no cost.

### Computers that do not follow the corporate naming convention

Fifteen objects do not follow the site-and-number pattern: `MAGDA`, `MASWER-SBUESA`, `LAPTOP-B33DD389`, `LAPTOP-BISDDK0P`, `XEROXFBH`, `mwsgeu1premium`, `mwsgus2premium`, `mwsgus3premium` and seven others with mixed prefixes. This is the same pattern as the `OORTH` laptop: computers reassigned or provisioned outside the procedure that were never renamed. Each represents a computer whose current owner is not recorded anywhere.

### A warning before clean-up

The **`AZUREADSSOACC` object has no recorded logons and must not be changed.** This is the account that enables automatic sign-in to Microsoft 365 for the entire workforce. By design, it never signs in. Deleting it because it "has been inactive for five years" would leave all users without seamless access to Microsoft 365. It is the clearest example of why "inactive means delete" cannot be applied automatically.

---

## Licensing impact

There are **218 user mailboxes** in the directory: 171 on enabled accounts and **47 on accounts that are already disabled**. Maswer has purchased exactly **218 Microsoft 365 Business seats**, of which 180 were shown as assigned in the latest available billing extract, dated 31 August.

The match between these figures is striking and **must not be accepted without verification**: a disabled account retaining its mailbox in the directory does not prove that it still has an assigned Microsoft 365 licence. The portal's billing extract establishes that, not the directory.

With that qualification, the scope for review before renewal is:

| Item | Seats |
|---|---|
| Difference between purchased and assigned seats (31 Aug) | 38 |
| Disabled accounts retaining a user mailbox | 47 |
| Enabled, licensed accounts unused for more than a year | 40 |
| — of which, individuals | 21 |
| — of which, department or site accounts | 18 |
| — of which, technical accounts | 1 |

**The window closes on 17 September.** The task is not to decide within eight days what to deprovision: it is to decide within eight days **how many seats to renew**, which is a number rather than a list. Everything else can continue afterwards.

One qualification has already caused a support case: **do not remove the licence from a mailbox that someone else has taken over.** If a successor is using the mailbox of someone who has left, the correct approach is to convert it to a shared mailbox, rather than release the seat.

---

## What this report cannot answer

The question "which users left Maswer more than a year ago" **cannot be answered from the systems**. This report provides the closest available information: a list of those who have not used their accounts, with names, dates and sites. Only Maswer can confirm who is still employed.

Three specific gaps, and who can close them:

- **HR's list of active employees.** Request it through Vincenzo Valle. No implementation date can be committed to without it.
- **Actual Microsoft 365 activity.** Someone who only uses email on a mobile phone or in a browser may appear inactive in the directory while working normally. The admin centre usage report can disprove that apparent inactivity immediately, and it must be cross-checked before any list of named individuals is sent.
- **Who uses each computer.** The directory shows when a machine was last seen, never who has it. Only the client can complete that column.

---

## Deprovisioning plan

Nothing is deleted. Accounts are disabled and retained, and no change is made without written management authorisation attached to the ticket, with a date and sender. Deleting an account also deletes its mailbox and files and cannot be undone.

### 1. Close the exposure from privileged accounts

Use the controllers' security logs to identify what is using Oliver Orth's accounts, disable all five once the process has been identified and replaced, and rotate the passwords of the shared and service accounts he knew. Disable `tplink` and `admin`, unused since 2017.

- **Benefit:** closes administrator-level access belonging to an employee who has left.
- **Scope:** five `*OOrth` accounts, plus `tplink`, `admin`, `admadfs` and `Admin2_MRGarcia`.
- **Service impact:** none if the process is identified first; disruption to that process if the order is reversed. This is why the sequence is non-negotiable.
- **Coordination:** conet.de also knows the shared and service accounts; password rotation must be agreed with them.

### 2. Request the list of active employees

Ask Maswer, through Vincenzo Valle, for the list of current employees and cross-check it against the 22 candidates in this report.

- **Benefit:** turns a list of inactive accounts into a list of confirmed leavers.
- **Service impact:** none.

### 3. One confirmation round with a single deadline

Send the tables in this report as a confirmation sheet, leaving the "Still in use? / confirmed by" column blank, with **one shared deadline** for all groups: individuals, department accounts, service accounts and computers. Silence at the deadline is not approval: accounts remain disabled and the matter stays open until written confirmation arrives.

- **Benefit:** a single point of coordination instead of chasing separate responses.
- **Service impact:** none.

### 4. Decide the seat count before 17 September

Cross-check the updated billing extract against the 47 disabled accounts that retain mailboxes, and agree with conet.de (Patrick Kuhlmann) how many seats to renew. Before releasing any, verify what the Microsoft 365 backup actually retains.

- **Benefit:** avoids committing to another twelve months of seats that nobody uses.
- **Service impact:** none, provided no mailbox taken over by a successor is affected.

### 5. Clean up the computer inventory

First retire the six replaced servers and the ten computers with unsupported operating systems, after confirming that they no longer exist physically. Then address the 282 objects with no contact for more than two years. Exclude `AZUREADSSOACC`.

- **Benefit:** a trustworthy inventory and a smaller attack surface.
- **Service impact:** none for computers that no longer exist.

### 6. Close the gap that caused the accumulation

The concentration of inactive accounts in Mexico and the United States indicates that leaver notifications from those sites are not reaching support. Agreeing a leaver notification process for each site with Maswer will prevent this audit from needing to be repeated in a year's time.

- **Benefit:** prevents the problem from recurring.
- **Service impact:** none.

---

## Action summary

| # | Action | Benefit | Service impact |
|---|---|---|---|
| 1 | Identify and disable the previous administrator's accounts | Closes active privileged access | None if identified first |
| 2 | Request the list of active employees via Vincenzo Valle | Enables decisions on confirmed leavers | None |
| 3 | Confirmation sheet with a single deadline | One round instead of several | None |
| 4 | Set the seat count for renewal before 17 Sep | Avoids 12 months of unused seats | None |
| 5 | Retire replaced servers and unsupported computers | Reliable inventory, smaller attack surface | None |
| 6 | Leaver notifications from sites in the Americas | Prevents recurrence | None |

---

## Assessment

| Item | Status |
|---|---|
| Data loss | None |
| Changes made to the directory | None — read-only audit |
| Accounts disabled or deleted in this review | None |
| Confirmed security incident | No |
| Open security exposure | Yes — previous administrator's credentials in use |
| Service interruption | None |

The directory reflects a company that has grown and changed administrators without access removal keeping pace with account creation. There is no evidence of misuse, and none of the findings points to an attack. What exists is a ten-year accumulation that reduces inventory reliability and leaves more access paths open than necessary.

The previous administrator's accounts are the issue that cannot wait. The rest is routine housekeeping, to be addressed through a well-organised confirmation round and a deadline.

---

## Appendix — data scope

The complete account-by-account and computer-by-computer list, including last logon, organisational unit, mailbox type, groups and VPN membership, is available as a data file to attach to the confirmation sheet. This document includes the 22 individual account candidates and the priority subsets of computers; the complete list of 344 computer objects is not reproduced here because of its length.

---

*Document prepared by CoolNetworks · 9 September 2026.*
