# CONTEXT — Reports

Where ticket work becomes written deliverables for CoolNetworks management and
clients (e.g. Maswer). Reports are written in **Spanish** (client-facing); internal
triage stays in English per core/rules.md.

## Structure
- `drafts/` — case reports in Markdown, one per incident/ticket
- `final/` — approved deliverables exported to `.docx` (and `.pdf` when needed)
- reports/ root — executive summaries spanning a period

## Naming
`YYYY-MM-DD_client_topic.md` — date first, then client, then short kebab-case topic.

## Build pipeline
- `gen_word*.py` / `build_word_report.py` — generate `.docx` from a report
- `convert_to_pdf.ps1 -DocxPath <in> -PdfPath <out>` — `.docx` → `.pdf` via Word COM

## What good looks like
Executive tone, factual, no alarmism. Distinguish routine support from real
incidents. State clearly when there is no data loss / no breach / no SLA breach.
