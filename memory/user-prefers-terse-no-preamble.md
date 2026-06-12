---
name: user-prefers-terse-no-preamble
description: User wants the deliverable only — no preamble, no caveats, no "fill in X" instructions, no post-amble offers
metadata:
  type: feedback
---

When the user asks for a concrete artifact (an email, a message, a snippet, a config), deliver **only the artifact**. No framing sentence before, no instructions after, no offers for variants. If placeholders are needed, mark them inline (`[Name]`) without explaining what to fill in — they know.

**Why:** Mid-incident, after I delivered an email draft surrounded by a "Te lo dejo en EN porque…" intro, two paragraphs of "antes de enviarlo, rellena…" and an offer to do German, the user replied "mucha explicaicion al punto." They are working under heavy time pressure and the wrapping was friction. This pairs with the project rule in [rules.md](../rules.md): "Zero filler".

**How to apply:**
- Output: artifact, end. No "Te lo dejo en X", no "Pégate esto", no "¿Quieres que…?".
- Keep inline placeholders (`[Name]`, `[Ticket ref]`) — those are part of the artifact and don't count as instructions.
- Caveats / variants / alternatives → only if the user explicitly asks, or if **not** mentioning them is unsafe (e.g. an authorization warning before a destructive action).
- This is about deliverable-style requests. When the user is mid-diagnostic and asking what to do next, short explanations of *why* are still useful — the rule is "no padding around an artifact," not "never explain."
- Related: [[customer-reply-only-ask-operational-info]] and [[customer-replies-non-technical-by-default]] for the customer-facing equivalent of the same instinct.
