"""Requer Python 3 + reportlab. Gera somente identificação e links exigidos."""
import argparse
from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
p=argparse.ArgumentParser()
p.add_argument('--grupo',default='MateusPierro')
p.add_argument('--github',required=True)
p.add_argument('--video',required=True)
p.add_argument('--integrante',action='append',help='Nome - RM; repita para cada integrante')
a=p.parse_args()
for url in (a.github,a.video):
    if not url.startswith('https://'): p.error('Use links completos https://')
name=''.join(c for c in a.grupo if c.isalnum() or c in '-_')
if not name: p.error('Nome do grupo inválido')
out=Path(__file__).resolve().parent.parent/'entrega'/f'{name}_webapp.pdf'
out.parent.mkdir(exist_ok=True)
styles=getSampleStyleSheet()
# Fonte incorporada quando disponível, inclusive no Windows.
fonts=[Path('C:/Windows/Fonts/arial.ttf'), Path('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf')]
for font in fonts:
    if font.exists():
        pdfmetrics.registerFont(TTFont('Entrega', str(font)))
        for style in styles.byName.values(): style.fontName='Entrega'
        break
styles['Title'].textColor=colors.HexColor('#17382d')
story=[Paragraph(escape(a.grupo),styles['Title']),Spacer(1,25)]
for person in (a.integrante or ['Mateus Teni Pierro - RM 555125']):
    story.extend([Paragraph(escape(person),styles['Normal']),Spacer(1,12)])
for label,url in [('GitHub',a.github),('Vídeo',a.video)]:
    story.extend([Spacer(1,18),Paragraph(label,styles['Heading2']),Paragraph(f'<link href="{escape(url, {chr(34): "&quot;"})}">{escape(url)}</link>',styles['Normal'])])
SimpleDocTemplate(str(out),pagesize=(595.28,841.89),rightMargin=52,leftMargin=52,topMargin=60,bottomMargin=60).build(story)
print(out)
