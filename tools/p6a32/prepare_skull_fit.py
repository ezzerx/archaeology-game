"""Register the uploaded Tripo skull to immutable B-17, without editing the field."""
from pathlib import Path
import json,struct
import numpy as np
from scipy.interpolate import RBFInterpolator
from scipy.ndimage import distance_transform_edt

root=Path(__file__).resolve().parents[2];out=root/'work/p6a32';out.mkdir(parents=True,exist_ok=True)
config=json.loads((root/'tools/p6a32/b17_skull_fit.json').read_text())
b=(root/'art/source/p6a32/b17-tripo-original.glb').read_bytes();n=struct.unpack_from('<I',b,12)[0]
j=json.loads(b[20:20+n]);start=28+n;primitive=j['meshes'][0]['primitives'][0]
def accessor(index,cols):
    a=j['accessors'][index];bv=j['bufferViews'][a['bufferView']]
    dt=np.dtype({5126:'<f4',5125:'<u4',5123:'<u2'}[a['componentType']])
    return np.ndarray((a['count'],cols),dtype=dt,buffer=b,offset=start+bv.get('byteOffset',0)+a.get('byteOffset',0),strides=(bv.get('byteStride',dt.itemsize*cols),dt.itemsize)).copy()
v=accessor(primitive['attributes']['POSITION'],3)
xy=np.column_stack((v[:,0],-v[:,1]));lo=xy.min(0);hi=xy.max(0)
pixels=(xy-lo)/(hi-lo)*np.array([920,535])+np.array([50,50])
warp=RBFInterpolator(np.array(config['source_pixels']),np.array(config['target_cells']),kernel='thin_plate_spline',smoothing=config['registration_smoothing'])
points=warp(pixels)
ids=np.fromfile(out/'b17-components.bin',np.uint8).reshape(640,1024)
ceilings=np.fromfile(out/'b17-ceilings.bin',np.float32).reshape(640,1024)
nearest=distance_transform_edt(ids!=1,return_distances=False,return_indices=True)
cell=np.rint(points).astype(int);cell[:,0]=np.clip(cell[:,0],0,1023);cell[:,1]=np.clip(cell[:,1],0,639)
support=ceilings[nearest[0,cell[:,1],cell[:,0]],nearest[1,cell[:,1],cell[:,0]]]
fitted=np.column_stack(((points[:,0]+.5)/1024*1.1-.55,.018+support*.102+config['depth_offset']+v[:,2]*config['depth_scale'],(points[:,1]+.5)/640*.7-.35))
np.savez(out/'skull-fit.npz',original=v,fitted=fitted)
print('Registered source vertices:',len(v))
