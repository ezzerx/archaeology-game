"""Convert museum stationery lettering to SVG paths for Godot's SVG importer.
Offline dependency: fontTools. Uses a local licensed font; no font file ships.
Usage: python outline_atlas.py --font C:/Windows/Fonts/georgia.ttf
"""
import argparse, pathlib, xml.etree.ElementTree as ET
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
args=argparse.ArgumentParser(); args.add_argument('--font',required=True); options=args.parse_args()
base=pathlib.Path(__file__).resolve().parent
font=TTFont(options.font); glyphs=font.getGlyphSet(); cmap=font.getBestCmap(); upem=font['head'].unitsPerEm
ET.register_namespace('', 'http://www.w3.org/2000/svg')
root=ET.parse(base/'source/field_notes.svg.in').getroot()
def walk(element, inherited):
    state=dict(inherited); state.update(element.attrib)
    for child in list(element):
        if child.tag.endswith('}text'):
            props=dict(state); props.update(child.attrib)
            size=float(props.get('font-size',16)); scale=size/upem
            spacing=float(props.get('letter-spacing',0)); text=''.join(child.itertext())
            names=[cmap.get(ord(c),'.notdef') for c in text]
            width=sum(glyphs[name].width*scale+spacing for name in names)-spacing
            x=float(props.get('x',0)); y=float(props.get('y',0))
            if props.get('text-anchor')=='middle': x-=width*.5
            paths=[]
            for name in names:
                pen=SVGPathPen(glyphs)
                glyphs[name].draw(TransformPen(pen,(scale,0,0,-scale,x,y)))
                paths.append(pen.getCommands()); x+=glyphs[name].width*scale+spacing
            replacement=ET.Element('{http://www.w3.org/2000/svg}path')
            replacement.set('d',' '.join(paths))
            for prop in ['fill','stroke','opacity','transform']:
                if prop in child.attrib: replacement.set(prop,child.attrib[prop])
            index=list(element).index(child); element.remove(child); element.insert(index,replacement)
        else: walk(child,state)
walk(root,{})
ET.ElementTree(root).write(base.parents[2]/'assets/workshop/polish/field_notes.svg',encoding='utf-8',xml_declaration=True)
