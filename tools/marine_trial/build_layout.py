"""Marine-only placement of the approved M08 sculpt; rebake exact contact field.
Run with Blender 5.2.2 --background --python-exit-code 1 --python this_file.
The original sculpt and the other preparations are never overwritten.
"""
from pathlib import Path
import math, json, hashlib
import bpy
import numpy as np
from mathutils import Vector, Matrix
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/experiments/marine_trial';WORK=ROOT/'work/issue41/journey'
OUT.mkdir(parents=True,exist_ok=True);WORK.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/source/p6a50/m08-ammonite.blend'))
ob=bpy.data.objects['M08_Ammonite'];mesh=ob.data
pivot=Vector(((532.5/1024)*1.1-.55,-((333.5/640)*.7-.35),.044))
rotation=Matrix.Rotation(.075,3,'Y')
for vertex in mesh.vertices:
 vertex.co=pivot+rotation@((vertex.co-pivot)*1.4)+Vector((0,0,-.004))
mesh.update();mesh.calc_loop_triangles()
roof=np.zeros((640,1024),dtype='<f4');components=np.zeros((640,1024),dtype='u1')
v=np.array([(v.co.x,v.co.z,-v.co.y) for v in mesh.vertices],dtype=np.float32)
sx=(v[:,0].astype(np.float64)+.55)/1.1*1024;sy=(v[:,2].astype(np.float64)+.35)/.7*640
for tri in mesh.loop_triangles:
 face=np.array(tri.vertices);a,b,c=np.stack([sx[face],sy[face]],axis=1)
 ab=b-a;ac=c-a;det=ab[0]*ac[1]-ab[1]*ac[0]
 if abs(det)<1e-12:continue
 low=np.maximum(0,np.floor(np.minimum(a,np.minimum(b,c))-.5).astype(int));high=np.minimum([1023,639],np.ceil(np.maximum(a,np.maximum(b,c))-.5).astype(int))
 if np.any(high<low):continue
 yy,xx=np.mgrid[low[1]:high[1]+1,low[0]:high[0]+1];px=xx+.5-a[0];py=yy+.5-a[1]
 u=(px*ac[1]-py*ac[0])/det;w=(ab[0]*py-ab[1]*px)/det
 inside=(u>=-1e-8)&(w>=-1e-8)&(u+w<=1+1e-8)
 z=(v[face[0],1]+u*(float(v[face[1],1])-v[face[0],1])+w*(float(v[face[2],1])-v[face[0],1])-.018)/.102
 target=roof[low[1]:high[1]+1,low[0]:high[0]+1];winning=inside&(z>target)
 target[winning]=z[winning];components[low[1]:high[1]+1,low[0]:high[0]+1][winning]=mesh.attributes['preparation_region'].data[tri.polygon_index].value
roof.tofile(WORK/'roof.rf');components.tofile(WORK/'components.bytes')
bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);bpy.context.view_layer.objects.active=ob
bpy.ops.export_scene.gltf(filepath=str(OUT/'m08_marine.glb'),use_selection=True,export_format='GLB',export_yup=True,export_extras=True,export_animations=False,export_cameras=False,export_lights=False,export_vertex_color='ACTIVE',export_vertex_color_name='BoneOcclusion',export_all_vertex_colors=False)
manifest={'source':'art/source/p6a50/m08-ammonite.blend','source_sha256':hashlib.sha256((ROOT/'art/source/p6a50/m08-ammonite.blend').read_bytes()).hexdigest(),'scale':1.4,'tilt_radians':.075,'offset_m':-.004,'cells':int((components>0).sum()),'roof_range':[float(roof[components>0].min()),float(roof.max())],'component_cells':{str(i):int((components==i).sum()) for i in range(1,5)},'glb_sha256':hashlib.sha256((OUT/'m08_marine.glb').read_bytes()).hexdigest()}
assert min(manifest['component_cells'].values())>0
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('MARINE LAYOUT',json.dumps(manifest),flush=True)
