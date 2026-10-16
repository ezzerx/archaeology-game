"""Original planispiral shell. Continuous closed loft, modeled costae, eroded
aperture and concave umbilicus. Blender source stays editable; no external assets.
The four coverage regions describe shell anatomy, never B-17 component names.
"""
from pathlib import Path
import math,json,hashlib,struct
import bpy,bmesh
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/p6a50';WORK=ROOT/'work/p6a50';SOURCE=ROOT/'art/source/p6a50'
for d in [OUT,WORK,SOURCE]:d.mkdir(parents=True,exist_ok=True)
assert bpy.app.version[:3]==(5,2,2)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
bpy.context.scene.unit_settings.system='METRIC'
mat=bpy.data.materials.new('M08_Warm_fossil_ivory');mat.diffuse_color=(.68,.60,.44,1)
mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.78
N=1100;SIDES=40;END=23.6;ROT=-1.05
verts=[];faces=[];regions=[]
def point(t,a,inner=False,depth=0):
    r=4.0*math.exp(.13*t)
    scale=(r/88)**.72
    # Open a real spiral sulcus between successive whorls. Their shoulders no
    # longer almost touch; the existing Pick can work the recessed matrix.
    w=r*.345*(1+.012*math.sin(t*3.7)+.008*math.sin(t*7.1))
    theta=t+ROT+.006*math.sin(t*2.3)
    # Lower inner turns into a bowl while keeping the outer crest under the
    # original sealed block. Full rounded flanks replace the former shallow loft.
    height=.027+.008*scale
    dz=.003+.026*scale
    phase=t*27+.9*math.sin(a)+.22*math.sin(t*6)+.28*math.sin(2*a)
    ridge=max(0,math.cos(phase))**2.5
    rib=(.0006+.0038*scale)*(.88+.12*math.sin(t*9.3))
    weather=1-.48*math.exp(-((t-15.45)/.28)**2)*max(0,math.sin(a))**5
    lateral=math.cos(a)*w
    h=height+math.sin(a)*dz+rib*ridge*max(0,math.sin(a))**.55*weather
    # Worn lip and fine asymmetry are modeled, not painted crack lines.
    h-=.004*max(0,min(1,(t-(END-.28))/.28))**2*max(0,math.sin(a))**2
    h+=.00016*math.sin(t*83+a*11)*math.sin(t*39-a*17)
    if inner:
        lateral*=.79*(1-depth*.56)
        h=height+(h-height)*.73*(1-depth*.6)-.003*depth
    x=532+(r+lateral)*math.cos(theta)
    y=333+(r+lateral)*math.sin(theta)
    return ((x+.5)/1024*1.1-.55,-((y+.5)/640*.7-.35),h)

for k in range(N+1):
    t=END*k/N
    for j in range(SIDES):verts.append(point(t,j/SIDES*math.tau))
for k in range(N):
    for j in range(SIDES):
        faces.append((k*SIDES+j,k*SIDES+(j+1)%SIDES,(k+1)*SIDES+(j+1)%SIDES,(k+1)*SIDES+j))
        regions.append(4 if k>N*.965 else (1 if k>N*.65 else (2 if k>N*.30 else 3)))
faces.append(tuple(reversed(range(SIDES))));regions.append(3)
# Turn the terminal margin inward instead of closing the shell with a flat disc.
for step in range(1,10):
    start=len(verts)
    for j in range(SIDES):
        a=j/SIDES*math.tau
        p=list(point(END-.010*step,a,True,(step-1)/8))
        p[2]-=.0007*math.sin(a*3+.5)**2*(1-(step-1)/8)
        verts.append(p)
    previous=(N*SIDES if step==1 else start-SIDES)
    for j in range(SIDES):
        faces.append((previous+j,previous+(j+1)%SIDES,start+(j+1)%SIDES,start+j));regions.append(4)
faces.append(tuple(range(len(verts)-SIDES,len(verts))));regions.append(4)
mesh=bpy.data.meshes.new('M08_Costate_shell');mesh.from_pydata(verts,[],faces);mesh.update()
ob=bpy.data.objects.new('M08_Ammonite',mesh);bpy.context.collection.objects.link(ob)
bpy.context.view_layer.objects.active=ob;ob.select_set(True)
cage=ob.copy();cage.data=mesh.copy();cage.name='EDITABLE_M08_LOFT'
col=bpy.data.collections.new('EDITABLE_SHELL_SOURCE');bpy.context.scene.collection.children.link(col);col.objects.link(cage);col.hide_render=True;col.hide_viewport=True
# Preserve an attribute through triangulation so the baked regions follow geometry.
attr=mesh.attributes.new(name='preparation_region',type='INT',domain='FACE')
for i,c in enumerate(regions):attr.data[i].value=c
bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
assert all(e.is_manifold for e in bm.edges),'Shell must be a closed manifold'
bm.to_mesh(mesh);bm.free()
for f in mesh.polygons:f.use_smooth=True
uv=mesh.uv_layers.new(name='UVMap')
for loop in mesh.loops:
    p=mesh.vertices[loop.vertex_index].co;uv.data[loop.index].uv=(p.x/.24,-p.y/.24)
mesh.materials.append(mat)
ob['source_method']='original deep-whorled planispiral loft with modeled costae, open sulcus and recessed aperture'
# Short-range vertex AO enhances actual folds; no painted uniform cracks.
print('BAKE AO',len(mesh.vertices),flush=True)
mesh.calc_loop_triangles();bvh=BVHTree.FromPolygons([v.co for v in mesh.vertices],[tuple(t.vertices) for t in mesh.loop_triangles],all_triangles=True)
colors=mesh.color_attributes.new(name='BoneOcclusion',type='FLOAT_COLOR',domain='POINT');mesh.color_attributes.active_color=colors
for v in mesh.vertices:
    n=v.normal.normalized();helper=Vector((0,0,1)) if abs(n.z)<.9 else Vector((1,0,0))
    tangent=n.cross(helper).normalized();bitangent=n.cross(tangent);occ=0.0
    for k in range(16):
        z=(k+.5)/16;angle=k*2.39996323;r=math.sqrt(1-z*z)
        ray=tangent*(math.cos(angle)*r)+bitangent*(math.sin(angle)*r)+n*z
        hit,_,_,dist=bvh.ray_cast(v.co+n*.00012,ray,.010)
        if hit is not None:occ+=(1-dist/.010)*z
    ao=max(.34,1-occ/8);colors.data[v.index].color=(ao,ao,ao,1)
print('RASTER FIELD',flush=True)
roof=np.zeros((640,1024),dtype='<f4');components=np.zeros((640,1024),dtype='u1')
v=np.array([(v.co.x,v.co.z,-v.co.y) for v in mesh.vertices],dtype=np.float32)
f=np.array([tuple(t.vertices) for t in mesh.loop_triangles],dtype=np.int32)
sx=(v[:,0].astype(np.float64)+.55)/1.1*1024;sy=(v[:,2].astype(np.float64)+.35)/.7*640
for triangle,face in zip(mesh.loop_triangles,f):
    a,b,c=np.stack([sx[face],sy[face]],axis=1);ab=b-a;ac=c-a;det=ab[0]*ac[1]-ab[1]*ac[0]
    if abs(det)<1e-12:continue
    low=np.maximum(0,np.floor(np.minimum(a,np.minimum(b,c))-.5).astype(int));high=np.minimum([1023,639],np.ceil(np.maximum(a,np.maximum(b,c))-.5).astype(int))
    if np.any(high<low):continue
    yy,xx=np.mgrid[low[1]:high[1]+1,low[0]:high[0]+1];px=xx+.5-a[0];py=yy+.5-a[1]
    u=(px*ac[1]-py*ac[0])/det;w=(ab[0]*py-ab[1]*px)/det
    inside=(u>=-1e-8)&(w>=-1e-8)&(u+w<=1+1e-8)
    z=(v[face[0],1]+u*(float(v[face[1],1])-v[face[0],1])+w*(float(v[face[2],1])-v[face[0],1])-.018)/.102
    target=roof[low[1]:high[1]+1,low[0]:high[0]+1];winning=inside&(z>target)
    target[winning]=z[winning];components[low[1]:high[1]+1,low[0]:high[0]+1][winning]=mesh.attributes['preparation_region'].data[triangle.polygon_index].value
roof.tofile(WORK/'roof.rf');components.tofile(WORK/'components.bytes')
np.ones((640,1024),dtype='u1').tofile(WORK/'old-rib-selection.bytes')
np.savez(WORK/'M08_Ammonite.npz',vertices=v,faces=f)
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'m08-ammonite.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'m08_ammonite.glb'),use_selection=True,export_format='GLB',export_yup=True,export_extras=True,export_animations=False,export_cameras=False,export_lights=False,export_vertex_color='ACTIVE',export_vertex_color_name='BoneOcclusion',export_all_vertex_colors=False)
glb=(OUT/'m08_ammonite.glb').read_bytes();length=struct.unpack_from('<I',glb,12)[0];doc=json.loads(glb[20:20+length])
tris=sum(doc['accessors'][p['indices']]['count']//3 for m in doc['meshes'] for p in m['primitives'])
manifest={'blender':bpy.app.version_string,'source':'Original stylized ammonite, no asserted species','triangles':tris,'closed':True,'baked_cells':int((components>0).sum()),'component_cells':{str(i):int((components==i).sum()) for i in range(1,5)},'bounds':[v.min(0).tolist(),v.max(0).tolist()],'highest_ceiling':float(roof.max()),'glb_sha256':hashlib.sha256(glb).hexdigest()}
assert tris<100000 and min(manifest['component_cells'].values())>0
(OUT/'production-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('M08 BUILT',json.dumps(manifest),flush=True)
