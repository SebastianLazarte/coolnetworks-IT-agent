---
name: maswer-info-mailbox-bilingual-de-es
description: Maswer shared mailbox "Info" is used by DE and ES staff; ES team speaks neither English nor German, so the mailbox locale stays es-ES
metadata:
  type: project
---

Maswer's shared mailbox **"Info"** (`info@maswer.com` — **to confirm**) is worked daily by
colleagues in **both Germany and Spain**. The Spanish users **do not speak English or German**;
Spanish is the only language they work in.

A mailbox has **one regional configuration** — default folder names (`Get/Set-MailboxRegionalConfiguration`,
`-LocalizeDefaultFolderName`) are stored in the mailbox itself, so there is **no per-user view**.
Whoever opens the mailbox sees its labels, regardless of their own Outlook language.

**Decision (29-jul-2026): leave the mailbox at `es-ES`.** Do not "standardize" it to `de-DE` or
`en-US`. The Spanish team has no fallback language; the German requester (Angelika Stangenberg,
board profile) writes fluent English and can work around it. Changing it would trade a cosmetic
annoyance for an operational block.

**Why:** raised when Angelika opened a ticket asking why the Info account showed Spanish folder
names inside her German Outlook. First instinct was `de-DE` (all custom folders — `AU Rückmeldung`,
`ERLEDIGT`, `Deutschland` — are already German), then `en-US` as neutral. Both were wrong once the
Spanish team's language limitation surfaced. The custom work folders stay German whatever locale is
set, so locale choice never fixes them — it only decides who loses.

**How to apply:**
- The per-user fix is **Favorites**: drag the shared folder into the Favoriten/Favoritos pane and
  rename the shortcut there. That label is **local to the user's Outlook profile**; the mailbox is
  untouched and nobody else sees the change. Outlook classic desktop only — not Outlook (new) or
  webmail. Angelika already has the Favoriten pane in use.
- Before reopening the locale question, run `Get-MailboxPermission -Identity <smtp>` for the real
  DE/ES headcount split. A clear German majority would change the calculus.
- Same root cause pattern as the Nave 4 - Abrera mailbox: shared mailboxes inherit the locale of
  whoever created/initialized them. Set the locale deliberately at creation, per site.
- Related: [[user-does-not-speak-german-use-english]] · [[customer-replies-non-technical-by-default]] ·
  [[no-remote-sessions-endusers]] · [[maswer-calden-contacts]]
