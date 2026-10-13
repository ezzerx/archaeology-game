"""Conservative coverage keeps native Bone wherever the fitted mesh has a gap."""
from pathlib import Path
import json
import numpy as np
from scipy.ndimage import binary_erosion
from PIL import Image,ImageDraw
root=Path(__file__).resolve().parents[2];out=root/'work/p6a32'
a=np.load(out/'skull-runtime.npz');v=a['vertices'];faces=a['faces']
xy=(v[:,[0,2]]/np.array([1.1,.7])+.5)*np.array([1024,640])
im=Image.new('L',(4096,2560));draw=ImageDraw.Draw(im)
for face in faces:draw.polygon([tuple(p*4) for p in xy[face]],fill=255)
covered=np.asarray(im).reshape(640,4,1024,4).min(axis=(1,3))==255
ids=np.fromfile(out/'b17-components.bin',np.uint8).reshape(640,1024)
mask=binary_erosion(covered,iterations=1)&(ids==1)
Image.fromarray(mask.astype(np.uint8)*255).save(root/'assets/p6a32/b17_skull_coverage.png')
report={'skull_cells':int((ids==1).sum()),'replacement_cells':int(mask.sum()),'fallback_cells':int(((ids==1)&~mask).sum()),'supersampling':4,'edge_erosion_cells':1}
(out/'skull-coverage.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
