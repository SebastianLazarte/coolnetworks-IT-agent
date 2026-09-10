import sys,os,importlib.util
from pathlib import Path
skill=Path('C:/Users/sebaa/.codex/plugins/cache/openai-primary-runtime/documents/26.909.12148/skills/documents')
os.environ['PATH']='C:/Users/sebaa/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/Library/bin'+os.pathsep+os.environ['PATH']
spec=importlib.util.spec_from_file_location('render_docx',skill/'render_docx.py');renderer=importlib.util.module_from_spec(spec);spec.loader.exec_module(renderer)
for kind,file in [('executive','reports/final/2026-09-09_maswer_it-executive-report-en.docx'),('audit','reports/especiales/2026-09-09_maswer_unused-accounts-and-devices-audit-en.docx')]:
 out=Path('reports/.translation-qa')/(kind+'-final3')
 renderer.convert_to_pdf=lambda *args,**kwargs:(str((out/'render.pdf').resolve()),'Native Word export; bundled LibreOffice unavailable on Windows.')
 pages=renderer.rasterize(file,str(out),72,False,False)
 print(kind,len(pages),flush=True)
