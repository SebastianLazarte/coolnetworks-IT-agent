# Diagnostic Trees

Concrete steps for the most frequent incident types at N1. Each tree is designed so the specialist can translate it into a list of verifiable steps for the human technician.

**General rule:** stop the moment you find the cause. Don't run all steps out of inertia.

---

## 1. Sign-in / account problems

### Tree

1. **Can the user sign in from another device or from the web portal?**
   - Yes → local issue on the machine (credential cache, corrupt profile)
   - No → account issue

2. **If it's an account issue:**
   - Check in M365 admin / AD whether the account is locked or expired
   - Review the sign-in log: are there repeated failed attempts?
     - If the IPs are from the customer themselves → unlock, reset, notify the user
     - If the IPs are unusual or from other countries → ⚠️ possible unauthorized access attempt, escalate to N2 Cybersecurity

3. **If MFA is the problem:**
   - Did the user recently change phones?
   - Does the Authenticator app show codes but they don't work?
   - Reset MFA from admin and re-enroll the user in a guided session

### When to escalate
- Suspicion of compromised credentials
- Service or admin account affected
- Multiple accounts affected at the same time

---

## 2. Connectivity / network

### Tree

1. **Is it the user's problem or the whole office's?**
   - Just the user → their machine or cable/WiFi
   - The whole office → infrastructure issue

2. **If it's just the user:**
   - Do other machines on the same socket work? → cable
   - Connects to WiFi but doesn't browse? → DNS or proxy
   - `ping 8.8.8.8` → does it return? Yes but `ping google.com` fails → DNS
   - Restart network adapter, renew IP (`ipconfig /release` + `/renew`)

3. **If it's the whole office:**
   - Should I call the customer to confirm scope? Yes, before touching anything
   - Can the customer check router/firewall lights? (face-to-face, photos)
   - ⚠️ If the entire network is down → escalate to N2 Systems. P1 if it affects the business.

### When to escalate
- Whole office down
- VPN with many users affected at once
- Suspicion of an issue in the perimeter firewall or router

---

## 3. Microsoft 365 / Outlook

### Tree

1. **Key question: is it desktop Outlook or also the web version (outlook.office.com)?**
   - Only desktop → local client issue
   - Also web → account or service issue

2. **If only desktop:**
   - Online / offline mode: check
   - Repair profile: Control Panel → Mail → Profiles
   - Recreate the profile if it's corrupt
   - Last resort: Office Quick Repair, then Online Repair

3. **If also web:**
   - Check service status: status.office.com
   - If Microsoft reports an incident → tell the customer, wait
   - If there's no general incident → review the mailbox in admin (quotas, blocks, weird rules)

### When to escalate
- Massive service outage (multiple customers affected → N2 Systems checks if it's ours or Microsoft's)
- Suspicious mailbox rules (auto-forward to externals, rules hiding emails) → ⚠️ N2 Cybersecurity, possible compromise

---

## 4. Hardware (printers, peripherals)

### Tree

1. **Mechanical issue or network/driver?**
   - Jam, no toner, paper → mechanical, instructions to the user
   - Doesn't print even though the queue runs → driver / network

2. **If it's driver/network:**
   - Can other people print to the same printer? → user's PC issue
   - Reinstall print queue, remove and reinstall driver
   - If it's a network printer: ping the printer, check IP

3. **USB peripherals:**
   - Try another port, another cable
   - Try the same device on another PC → confirms whether it's the device or the PC
   - Drivers updated, Device Manager with no yellow marks

### When to escalate
- Print server with multiple printers down → N2 Systems
- Hardware under warranty with physical failure → route to Sales for RMA handling

---

## 5. User software that fails

### Tree

1. **Is it just this user or more?**
   - Just this one → their installation or profile
   - Several → possible bad update or application server issue

2. **If it's just the user:**
   - Restart the application
   - Restart the machine
   - Check for pending updates
   - Reinstall the application if previous steps don't work

3. **If it's several:**
   - Was there a recent deployment/update? → roll back if viable
   - Check the application server logs if there is one
   - Escalate to N2 if it affects production

### When to escalate
- ERP/CRM down → P2 minimum, N2 Systems
- Critical business application down → P1, N2 Systems

---

## 6. Possible cybersecurity incident

### Warning signs (any of them → P1, N2 Cybersecurity)

- Visible ransom note
- Files renamed with unusual extensions (.locked, .crypt, .[email]@…)
- Strange processes consuming CPU/disk at 100% with no explanation
- The user reports "your machine is infected" pop-ups not from the corporate antivirus
- Email received asking for credentials or urgent transfers (BEC / advanced phishing)
- Mailbox rules forwarding mail to externals without the user creating them
- Massive failed logins on any user account
- Successful login from a country we don't operate in
- Antivirus / EDR has blocked something and the user reports it

### Specialist action

**No standard triage. Jump to incident mode:**

1. Isolate the affected machine (network disconnected, do NOT power off)
2. Tell the customer no one is to touch anything related
3. Collect: time of detection, affected user, affected machines, literal message if any, screenshots
4. Escalate to N2 Cybersecurity immediately with all of the above
5. DO NOT try to recover files, DO NOT format, DO NOT pay

See example 2 in `examples.md` for the full pattern.

---

## 7. VPN won't connect

### Tree

1. **Is it just this user or more?**
   - Just this one → their VPN client or credentials
   - Several → issue with the VPN concentrator, escalate to N2 Systems

2. **If it's just the user:**
   - Does the user's internet work without VPN? If not → solve internet first
   - Check credentials (without asking for them) — ask the user to verify with admin if they recently changed them
   - Reinstall the VPN client if nothing works
   - If it's an expired VPN certificate → renew and reinstall

### When to escalate
- VPN concentrator down → N2 Systems, P1 if it affects mass remote work
- Suspicion of VPN misuse (VPN logins from unusual IPs) → N2 Cybersecurity

---

## When NOT to follow a tree

- When the customer has already done the basic steps. Jump to advanced ones.
- When there's a security smell. Go directly to section 6.
- When it's clearly outside N1 scope. Hand off without further diagnosis.
