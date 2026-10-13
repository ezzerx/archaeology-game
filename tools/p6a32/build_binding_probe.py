"""Offline closed-volume probe of the existing B-17 field, not Tripo art.
Run after export_b17_field.gd. Its silhouette/ceiling are the current game fixture.
"""
from pathlib import Path
import json
import numpy as np
from scipy.ndimage import distance_transform_edt, gaussian_filter
from skimage.measure import marching_cubes
import trimesh
root=Path(__file__).resolve().parents[2]
meta=json.loads((root/'work/p6a32/b17-field.json').read_text())
ids=np.fromfile(root/'work/p6a32/b17-components.bin',np.uint8).reshape(640,1024)
ceilings=np.fromfile(root/'work/p6a32/b17-ceilings.bin',np.float32).reshape(640,1024)
scene=trimesh.Scene(); stats=[]
(root/'assets/p6a32').mkdir(parents=True,exist_ok=True)
for component,name in enumerate(['skull','spine','ribs','hind-limb'],1):
 mask=ids==component
 yy,xx=np.nonzero(mask)
 x0=max(0,int(xx.min())-3);x1=min(1024,int(xx.max())+4)
 z0=max(0,int(yy.min())-3);z1=min(640,int(yy.max())+4)
 mask=mask[z0:z1,x0:x1]
 top=.018+ceilings[z0:z1,x0:x1]*.102
 # Preserve thin toes/ribs: only sub-cell contour relaxation, no bridging gaps.
 dist=distance_transform_edt(mask,sampling=(.7/640,1.1/1024))
 outside=distance_transform_edt(~mask,sampling=(.7/640,1.1/1024))
 sdf_xy=dist-outside
 weights=gaussian_filter(mask.astype(float),.65)
 smoothed=gaussian_filter(np.where(mask,top,0),.65)/np.maximum(weights,1e-6)
 top=np.where(mask,smoothed,top)
 thick=np.minimum(.016,np.maximum(.0018,dist*1.3))
 bottom=top-thick
 ymin=float(bottom[mask].min())-.002; ymax=float(top[mask].max())+.002
 h=np.arange(ymin,ymax,.00065)
 field=np.minimum(sdf_xy[:,:,None]-.0002,np.minimum(top[:,:,None]-h[None,None,:],h[None,None,:]-bottom[:,:,None]))
 verts,faces,normals,_=marching_cubes(field.astype(np.float32),level=0,spacing=(.7/640,1.1/1024,.00065),allow_degenerate=False)
 # skimage is row(Z), column(X), height(Y); centred Godot metre coordinates.
 v=np.column_stack((verts[:,1]+(x0+.5)/1024*1.1-.55,verts[:,2]+ymin,verts[:,0]+(z0+.5)/640*.7-.35))
 mesh=trimesh.Trimesh(v,faces,process=True)
 mesh.fix_normals()
 scene.add_geometry(mesh,node_name=name,geom_name=name)
 stats.append({'part':name,'vertices':len(mesh.vertices),'triangles':len(mesh.faces),'watertight':bool(mesh.is_watertight),'bounds':mesh.bounds.tolist()})
(root/'assets/p6a32/b17_binding_probe.glb').write_bytes(scene.export(file_type='glb'))
(root/'work/p6a32/probe-mesh.json').write_text(json.dumps(stats,indent=2))
print(json.dumps(stats,indent=2))
