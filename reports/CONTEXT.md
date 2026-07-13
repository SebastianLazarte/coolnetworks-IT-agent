# CONTEXT — Reports

Where ticket work becomes written deliverables for CoolNetworks management and
clients (e.g. Maswer). Reports are written in **Spanish** (client-facing); internal
triage stays in English per core/rules.md.

## Structure
- `drafts/` — case reports in Markdown, one per incident/ticket
- `final/` — approved deliverables exported to `.docx` (and `.pdf` when needed)
- `especiales/` — **reportes especiales**: análisis transversales que no están atados a
  un ticket ni a un periodo (p. ej. el patrón de arquitectura de infraestructura, un
  insight de seguridad, una comparativa de proveedores). Se diferencian de `final/`
  (cierre de un caso puntual) y de los resúmenes ejecutivos en la raíz (periodo de
  actividad): aquí van entregables de análisis/estrategia, con el mismo Markdown en
  `drafts/` como fuente y el `.docx`/`.pdf` ya compilado en `especiales/`.
- reports/ root — executive summaries spanning a period

## Naming
`YYYY-MM-DD_client_topic.md` — date first, then client, then short kebab-case topic.

## Build pipeline
No Python/pandoc available in this environment — the pipeline is PowerShell + Word COM:
- `build_word_report.ps1 -MdPath <in.md> -DocxPath <out.docx>` — generate `.docx` from a report (parses `#`/`##`/`###` headings, `**bold**`, `- ` bullets and `| … |` tables; built-in style indices are used instead of style names so it works regardless of the installed Word's UI language)
- `convert_to_pdf.ps1 -DocxPath <in> -PdfPath <out>` — `.docx` → `.pdf` via Word COM

## What good looks like
Executive tone, factual, no alarmism. Distinguish routine support from real
incidents. State clearly when there is no data loss / no breach / no SLA breach.
