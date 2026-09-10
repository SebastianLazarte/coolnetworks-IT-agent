from pathlib import Path
from zipfile import ZipFile
from copy import deepcopy
from lxml import etree
from docx import Document
from docx.text.paragraph import Paragraph
from docx.table import Table
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Pt
import re,json,hashlib
R=Path.cwd();Q=R/'reports/.translation-qa';Q.mkdir(exist_ok=True)
items=[('executive',R/'reports/final/2026-09-09_maswer_informe-ejecutivo-it-actualizaciones.docx',R/'reports/drafts/2026-09-09_maswer_it-executive-report-en.md',R/'reports/final/2026-09-09_maswer_it-executive-report-en.docx'),('audit',R/'reports/especiales/2026-09-09_maswer_auditoria-cuentas-y-dispositivos-sin-uso.docx',R/'reports/drafts/2026-09-09_maswer_unused-accounts-and-devices-audit-en.md',R/'reports/especiales/2026-09-09_maswer_unused-accounts-and-devices-audit-en.docx')]

def blocks(md):
 lines=md.splitlines();out=[];i=0
 while i<len(lines):
  line=lines[i].strip();i+=1
  if not line or line=='---':continue
  if line.startswith('|'):
   rows=[line]
   while i<len(lines) and lines[i].strip().startswith('|'):rows.append(lines[i].strip());i+=1
   out.append(('table',[[v.strip() for v in row.strip('|').split('|')] for row in rows if not re.fullmatch(r'[| :\-]+',row)]));continue
  m=re.match(r'^(#{1,3}) (.*)',line)
  if m:out.append(('Title' if len(m[1])==1 else 'Heading '+str(len(m[1])),m[2]));continue
  if line.startswith('- '):out.append(('List Bullet',line[2:]));continue
  while i<len(lines) and lines[i].strip() and not re.match(r'^(#|- |\|)',lines[i].strip()):line+=' '+lines[i].strip();i+=1
  # Metadata entries on adjacent Markdown lines are separate paragraphs.
  if '**Scope:**' in line and line.startswith('**Client:**'):
   out.extend(('Normal',p.strip()) for p in re.split(r'(?=\*\*(?:Client|Scope|Source|Reporting cut-off|Prepared by):\*\*)',line) if p.strip())
  else:out.append(('Normal',line))
 return out

def inline(p,text,size=None,header=False):
 p.clear()
 for token in re.split(r'(\*\*.*?\*\*|`[^`]+`|(?<!\*)\*[^*]+\*(?!\*))',text):
  if not token:continue
  bold=token.startswith('**') and token.endswith('**');italic=not bold and token.startswith('*') and token.endswith('*');code=token.startswith('`') and token.endswith('`')
  value=token[2:-2] if bold else token[1:-1] if italic or code else token
  value=value.replace('`','') if bold or italic else value
  r=p.add_run(value);r.bold=bold or header;r.italic=italic
  if size:r.font.size=Pt(size)
  lang=OxmlElement('w:lang');lang.set(qn('w:val'),'en-GB');r._r.get_or_add_rPr().append(lang)

def break_section(body,sect,landscape):
 p=OxmlElement('w:p');pr=OxmlElement('w:pPr');s=deepcopy(sect)
 typ=s.find(qn('w:type'))
 if typ is None:typ=OxmlElement('w:type');s.insert(0,typ)
 typ.set(qn('w:val'),'nextPage')
 pg=s.find(qn('w:pgSz'))
 if landscape:
  w,h=pg.get(qn('w:w')),pg.get(qn('w:h'));pg.set(qn('w:w'),h);pg.set(qn('w:h'),w);pg.set(qn('w:orient'),'landscape')
 pr.append(s);p.append(pr);body.append(p)

for key,src,md,dst in items:
 raw=md.read_text(encoding='utf-8-sig')
 raw=raw.replace('The server fleet is being brought up to date.','The server fleet is back up to date.').replace('Domain Administrators group, AzureFiles-Administrators',"Domain's Administrators group, AzureFiles-Administrators")
 md.write_text(raw,encoding='utf-8')
 d=Document(src);body=d._element.body;sect=deepcopy(d.sections[-1]._sectPr)
 ps={s:deepcopy(next(p._p for p in d.paragraphs if p.style.name==s)) for s in ['Title','Normal','Heading 2','Heading 3','List Bullet']}
 tables=[deepcopy(t._tbl) for t in d.tables];bs=blocks(raw)
 inventory={n:hashlib.sha256(b).hexdigest() for n,b in ((n,ZipFile(src).read(n)) for n in ZipFile(src).namelist())}
 (Q/f'{key}-artifact.md').write_text(f'''# Translation layout contract\n\nReference: {src}\nSHA256: {hashlib.sha256(src.read_bytes()).hexdigest()}\nSource pages: {8 if key=='executive' else 18}\nSource section count: 1. A4 portrait, margins top/bottom 1417 twips and left/right 1701 twips.\nKeep original package parts byte-for-byte except word/document.xml. Preserve original styles, theme, numbering, metadata and relationships. No images, fields, headers, footers or content controls occur in the source body.\nEditable slots: ordered body paragraphs and all table cells, from the translated Markdown. Paragraph roles use original Title, Heading 2, Heading 3, List Bullet and Normal components. Consolidate line-wrapped source prose into logical paragraphs, retaining emphasis and list grouping.\nTables: clone every original table in order; retain every row and column. Use repeated header rows, allow row height to expand, keep rows together, and size columns by content. Wide ticket, server and individual-account tables use landscape pages for legibility; portrait text pages retain source geometry. This is a pagination adjustment for translated content, with no change to semantic structure. Source typography and title/heading hierarchy remain authoritative.\nValidation: compare table dimensions, section-heading counts, numeric values and identifiers with source; verify translated Markdown against final Word; render every final page using Word PDF export and packaged render_docx rasterizer with an adapter because bundled LibreOffice is unavailable.\n''',encoding='utf-8')
 (Q/f'{key}-source-parts.json').write_text(json.dumps(inventory,indent=2))
 for child in list(body):body.remove(child)
 ti=0;land=False
 for bi,(kind,text) in enumerate(bs):
  # Put heading and introductory paragraph on the same landscape page as each wide table.
  startwide=(kind.startswith('Heading') and (text=='Details of tickets closed during the quarter' or text=='Scope of the cycle' or text=='The 22 individual candidates'))
  if startwide and not land:break_section(body,sect,False);land=True
  if key=='executive' and kind=='Heading 3' and text=='MEUAZAC011 — two blocked update cycles' and land:
   break_section(body,sect,True);land=False
  if kind!='table':
   e=deepcopy(ps[kind]);body.append(e);p=Paragraph(e,d._body);inline(p,text)
   p.paragraph_format.keep_with_next=kind in ['Title','Heading 2','Heading 3']
   p.paragraph_format.widow_control=True
   if key=='executive' and kind in ['Normal','List Bullet']:
    p.paragraph_format.space_after=Pt(5);p.paragraph_format.line_spacing=1.05
    for run in p.runs:run.font.size=Pt(10.5)
   if key=='audit' and kind in ['Normal','List Bullet']:
    p.paragraph_format.space_after=Pt(6);p.paragraph_format.line_spacing=1.05
   if key=='audit' and text=='The breakdown that changes the answer':p.paragraph_format.page_break_before=True
   if bi+1<len(bs) and (bs[bi+1][0]=='table' or (text.endswith(':') and bs[bi+1][0]=='List Bullet')):p.paragraph_format.keep_with_next=True
   continue
  t=Table(deepcopy(tables[ti]),d._body);body.append(t._tbl);ti+=1
  assert len(t.rows)==len(text) and len(t.columns)==len(text[0]),(key,ti,'table structure mismatch')
  cols=len(t.columns); total=13465 if land else 8504
  widths={('executive',5):[500,860,3000,1500,1900,1400,1100,1050,1050],('executive',6):[450,2100,2100,1450,3000,1400,1865],('audit',4):[1750,2850,1550,650,1850,850,650,2515]}.get((key,ti))
  if widths is None:
   proportions=([0.33,0.67] if ti==1 and key=='audit' else [0.72,0.28] if cols==2 else [0.32,0.22,0.46] if cols==3 else [0.25,0.31,0.20,0.24] if cols==4 else [1/cols]*cols)
   if key=='audit' and ti==3:proportions=[.26,.13,.15,.46]
   if key=='audit' and ti==10:proportions=[.055,.42,.30,.225]
   widths=[round(total*v) for v in proportions]
  factor=total/sum(widths);widths=[round(v*factor) for v in widths]
  grid=t._tbl.find(qn('w:tblGrid'))
  for col,width in zip(grid,widths):col.set(qn('w:w'),str(width))
  pr=t._tbl.tblPr
  tw=pr.find(qn('w:tblW'));tw.set(qn('w:type'),'dxa');tw.set(qn('w:w'),str(total))
  for i,row in enumerate(t.rows):
   rp=row._tr.get_or_add_trPr()
   for height in list(rp.findall(qn('w:trHeight'))):rp.remove(height)
   if rp.find(qn('w:cantSplit')) is None:rp.append(OxmlElement('w:cantSplit'))
   if i==0 and rp.find(qn('w:tblHeader')) is None:rp.append(OxmlElement('w:tblHeader'))
   for j,cell in enumerate(row.cells):
    cell._tc.get_or_add_tcPr().find(qn('w:tcW')).set(qn('w:w'),str(widths[j]))
    while len(cell.paragraphs)>1:cell._tc.remove(cell.paragraphs[-1]._p)
    p=cell.paragraphs[0];inline(p,text[i][j],9 if land else 10,header=i==0)
    p.paragraph_format.space_before=Pt(1);p.paragraph_format.space_after=Pt(1);p.paragraph_format.line_spacing=1.0;p.paragraph_format.keep_with_next=(len(text)<12 and i<len(text)-1)
  spacer=OxmlElement('w:p');body.append(spacer);sp=Paragraph(spacer,d._body);sp.add_run('').font.size=Pt(1);sp.paragraph_format.space_after=Pt(6);sp.paragraph_format.line_spacing=Pt(1)
  if land and key=='audit':break_section(body,sect,True);land=False
 body.append(sect)
 assert ti==len(tables)
 xml=etree.tostring(d._element,xml_declaration=True,encoding='UTF-8',standalone=True)
 with ZipFile(src) as zin,ZipFile(dst,'w') as zout:
  for entry in zin.infolist():zout.writestr(entry,xml if entry.filename=='word/document.xml' else zin.read(entry.filename))
 with ZipFile(dst) as z:
  assert all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in inventory.items() if n!='word/document.xml')
 print(key,dst,'tables',ti,'blocks',len(bs),flush=True)
