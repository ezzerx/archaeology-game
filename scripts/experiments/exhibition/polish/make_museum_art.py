"""Original vector artwork for the cabinet-room set. No online assets or fonts."""
from pathlib import Path
import math,random
ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'assets/museum/polish'
OUT.mkdir(parents=True,exist_ok=True)
def svg(w,h,body):
 return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">'+''.join(body)+'</svg>'
def ellipse(x,y,rx,ry,c,rotation=0):
 return f'<ellipse cx="{x:.2f}" cy="{y:.2f}" rx="{rx:.2f}" ry="{ry:.2f}" fill="{c}" transform="rotate({rotation:.2f} {x:.2f} {y:.2f})"/>'
def line(points,c,width):
 return f'<polyline points="'+ ' '.join(f'{x:.2f},{y:.2f}' for x,y in points)+f'" fill="none" stroke="{c}" stroke-width="{width}"/>'
# Cabinet prints: fern taxonomy, ammonoid study, leaf plate and inventory stationery.
body=['<rect width="1024" height="1024" fill="#d2c09a"/>']
for ox,oy in [(0,0),(512,0),(0,512),(512,512)]:
 body.append(f'<rect x="{ox+20}" y="{oy+20}" width="472" height="472" fill="none" stroke="#806c49" stroke-width="2"/>')
 body.append(line([(ox+49,oy+60),(ox+465,oy+60)],'#806c49',2))
 body.append(line([(ox+49,oy+450),(ox+465,oy+450)],'#806c49',1))
 # Typesetter's ruled catalogue marks, with no invented inscriptions.
 for i in range(3):body.append(line([(ox+49,oy+468+i*5),(ox+195-i*18,oy+468+i*5)],'#89734e',1))
for stem in range(5):
 base=(255,421); tip=(105+stem*66,95+abs(stem-2)*24)
 body.append(line([base,tip],'#655d38',3))
 for n in range(1,12):
  t=n/12;x=base[0]+(tip[0]-base[0])*t;y=base[1]+(tip[1]-base[1])*t
  for side in [-1,1]:
   ex=x+side*(30*(1-t)+9);ey=y-12
   body.append(ellipse(ex,ey,24*(1-t)+5,6,'#6b6844',side*35))
for n in range(260):
 t=n/259;a=t*math.tau*3;r=9+t*t*178
 x=768+math.cos(a)*r;y=251+math.sin(a)*r
 if n:body.append(line([(px,py),(x,y)],'#6a5a3b',4))
 if n%4==0 and t>.6:
  body.append(line([(x+math.cos(a)*18,y+math.sin(a)*18),(x-math.cos(a)*17,y-math.sin(a)*17)],'#80704b',2))
 px=x;py=y
for i in range(7):
 x=80+i*57;y=755+math.sin(i*1.4)*75
 body.append(ellipse(x,y,55,24,'#6a7149',-35+i*13))
 body.append(line([(x-40,y+12),(x+40,y-12)],'#bdb086',2))
for y in range(622,938,38):body.append(line([(555,y),(975,y)],'#9c8860',1))
rng=random.Random(5519)
for i in range(4000):
 x=rng.randrange(1024);y=rng.randrange(1024)
 body.append(f'<path d="M{x} {y}h1" stroke="#665338" opacity=".09"/>')
(OUT/'natural_history.svg').write_text(svg(1024,1024,body),encoding='utf-8')
# Dense original botanical rug: small arabesques, serrated palmettes, worn weave.
# Source resolution is retained; engine-generated mipmaps handle distance.
W,H=4096,2048
body=['<rect width="4096" height="2048" fill="#322f26"/>']
for inset,color,stroke in [(14,'#a17e49',5),(26,'#514934',7),(43,'#ad8c50',6),(60,'#3c4338',20),(83,'#b09155',5),(100,'#763e2b',0),(226,'#a18651',8),(242,'#344137',24),(268,'#ad8a53',6),(284,'#693e2c',0)]:
 body.append(f'<rect x="{inset}" y="{inset}" width="{W-2*inset}" height="{H-2*inset}" fill="{color}" stroke="#ae8b51" stroke-width="{stroke}"/>')
def path(d,fill,stroke='#b19155',sw=1):
 return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>'
def rosette(x,y,scale=1,angle=0):
 parts=[f'<g transform="translate({x:.2f} {y:.2f}) rotate({angle:.2f}) scale({scale:.3f})">']
 # Every petal has an internal teardrop, stem and hatch. No solid daisies.
 for n in range(8):
  parts.append(f'<g transform="rotate({n*45})">')
  parts.append(path('M0 -5 C-7 -14 -10 -21 0 -31 C10 -21 7 -14 0 -5','#b59154','#382f26',1.5))
  parts.append(path('M0 -10 Q-3 -17 0 -25 Q3 -17 0 -10','#693f2d','#bd9b61',.7))
  parts.append('</g>')
 parts.append('<circle r="8" fill="#344339" stroke="#ba9b5a" stroke-width="2"/><circle r="3" fill="#c0a16b"/>')
 parts.append('</g>');return ''.join(parts)
def palmette(x,y,scale=1,angle=0):
 parts=[f'<g transform="translate({x:.2f} {y:.2f}) rotate({angle:.2f}) scale({scale:.3f})">']
 parts.append(path('M0 34 C-18 22 -41 2 -34 -17 L-21 -10 L-27 -32 L-12 -21 L-12 -43 L0 -63 L12 -43 L12 -21 L27 -32 L21 -10 L34 -17 C41 2 18 22 0 34','#b38c4d','#3c392b',2))
 parts.append(path('M0 23 C-10 10 -22 -8 -15 -18 L-5 -12 L0 -42 L5 -12 L15 -18 C22 -8 10 10 0 23','#314237','#c2a96e',1.2))
 parts.append(path('M0 18 V-32 M0 0 L-10 -10 M0 -6 L9 -17','none','#bba069',1.6))
 parts.append('</g>');return ''.join(parts)
def sprig(x,y,scale=1,angle=0):
 parts=[f'<g transform="translate({x:.2f} {y:.2f}) rotate({angle:.2f}) scale({scale:.3f})">']
 parts.append(path('M-57 20 C-18 33 5 -37 56 -16','none','#a58b52',2.5))
 for n in range(5):
  px=-41+n*19;py=8-13*math.sin(n*.9)
  parts.append(path(f'M{px} {py} q-17 -27 -28 -18 q3 21 28 18','#284135','#9a814b',1.4))
  parts.append(path(f'M{px} {py} q20 20 26 8 q-8 -17 -26 -8','#9d7040','#c2a068',1))
 parts.append('</g>');return ''.join(parts)
# The broad ornamental border has alternating palmettes linked by winding vines.
for side in [0,1]:
 y=160 if side==0 else H-160
 for i,x in enumerate(range(160,W-140,116)):
  body.append(palmette(x,y,.82,90 if i%2 else -90))
  body.append(sprig(x+54,y,.57,180 if side else 0))
for side in [0,1]:
 x=160 if side==0 else W-160
 for i,y in enumerate(range(280,H-250,116)):
  body.append(palmette(x,y,.82,0 if i%2 else 180))
  body.append(sprig(x,y+54,.57,90))
# Fine guarded borders of interlocked buds.
for x in range(72,W-60,31):
 for y in [62,H-62,253,H-253]:
  body.append(rosette(x,y,.19))
for y in range(96,H-70,31):
 for x in [62,W-62,253,W-253]:body.append(rosette(x,y,.19))
# Small, irregularly staggered botanical field. Repetition is interrupted by scale/rotation.
for row in range(12):
 for col in range(26):
  x=350+col*136+(55 if row%2 else 0);y=337+row*124
  if x>W-320:continue
  d=((x-W/2)/490)**2+((y-H/2)/370)**2
  if d<1.0:continue
  body.append(sprig(x,y,.77,(-18 if row%2 else 18)+4*math.sin(col)))
  body.append(rosette(x+28,y-24,.47,13*col))
  if (row+col)%3==0:body.append(palmette(x-32,y+18,.40,45))
# A restrained, finely worked central medallion rather than an oversized flat flower.
for rx,ry,color in [(485,345,'#b09259'),(470,332,'#354338'),(448,309,'#ac894b'),(434,296,'#743f2b')]:
 points=[]
 for n in range(128):
  a=n*math.tau/128;r=1+.025*math.cos(a*16)
  points.append((W/2+math.cos(a)*rx*r,H/2+math.sin(a)*ry*r))
 body.append('<polygon points="'+' '.join(f'{x:.1f},{y:.1f}' for x,y in points)+f'" fill="{color}"/>')
for ring in range(3):
 for n in range(20-ring*6):
  count=20-ring*6;a=n*math.tau/count
  x=W/2+math.cos(a)*(385-ring*125);y=H/2+math.sin(a)*(249-ring*80)
  body.append(palmette(x,y,.64-ring*.08,a*180/math.pi+90))
  body.append(sprig(x,y,.48,a*180/math.pi))
body.append(rosette(W/2,H/2,1.35,22))
# Pigment and weave variation stays in a single opaque source atlas.
rng=random.Random(5520)
for i in range(68000):
 x=rng.randrange(W);y=rng.randrange(H)
 c='#dfbb7c' if i%2 else '#201a15'
 body.append(f'<path d="M{x} {y}h{rng.randrange(1,7)}" stroke="{c}" stroke-width="{rng.choice([1,1,2])}" opacity="{rng.uniform(.07,.23):.2f}"/>')
for y in range(1,H,3):body.append(f'<path d="M0 {y}H{W}" stroke="#211d18" opacity=".075" stroke-width=".55"/>')
for x in range(1,W,4):body.append(f'<path d="M{x} 0V{H}" stroke="#d4b77f" opacity=".06" stroke-width=".5"/>')
(OUT/'heritage_rug.svg').write_text(svg(W,H,body),encoding='utf-8')
print('Museum atlases authored: natural_history 1024x1024, rug 4096x2048')
