"""Original parametric skull + three rib pairs. Blender 5.2.2 -> Godot GLB.
The closed mesh is the source; its vertical ray projection authors pilot Bone.
No Tripo request, no imported Tripo geometry, no raster-derived display mesh.
"""
from pathlib import Path
import math, json, hashlib
import bpy, bmesh
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/p6a34'
WORK = ROOT / 'work/p6a34'
SOURCE = ROOT / 'art/source/p6a34'
for path in [OUT,WORK,SOURCE]: path.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
bpy.context.scene.unit_settings.system='METRIC'
assert bpy.app.version[:3] == (5,2,2)
SIZE=(1024,640)
objects=[]

def smooth_path(points, closed=False, steps=10):
    p=[Vector(v) for v in points]
    result=[]
    for i in range(len(p) if closed else len(p)-1):
        a=p[(i-1)%len(p)] if closed or i else p[0]
        b=p[i]; c=p[(i+1)%len(p)]
        d=p[(i+2)%len(p)] if closed or i+2<len(p) else p[-1]
        for j in range(steps):
            t=j/steps
            result.append((b*2+(c-a)*t+(a*2-b*5+c*4-d)*t*t+(-a+b*3-c*3+d)*t*t*t)*.5)
    if not closed:result.append(p[-1])
    return result

def world(point,height):
    return Vector(((point.x+.5)/1024*1.1-.55,-((point.y+.5)/640*.7-.35),height))

def tube(name,points,radius,depth,height,closed=False,detail=12):
    path=smooth_path(points,closed,detail)
    verts=[]; faces=[]; rings=20
    for i,p in enumerate(path):
        previous=path[(i-1)%len(path)] if closed or i else p
        following=path[(i+1)%len(path)] if closed or i+1<len(path) else p
        tangent=(following-previous).normalized()
        side=Vector((-tangent.y,tangent.x))
        u=i/(len(path)-1)
        # Deliberate anatomical taper, flared joints and restrained asymmetry.
        taper=1.0 if closed else .80+.30*math.exp(-((u-.07)/.12)**2)+.25*math.exp(-((u-.94)/.13)**2)
        taper*=1+.045*math.sin(u*math.tau*3+.7)
        plate = name in ['cranial_arch','cheek_strut','mandible']
        if name == 'cranial_arch':
            taper *= .70 if p.x < 236 else (1.10 if p.x > 278 else .95)
        h=height+.0012*math.sin(u*math.pi*1.6)
        for j in range(rings):
            angle=j/rings*math.tau
            lateral=math.cos(angle)*radius*taper
            xy=p+side*lateral
            vertical = math.sin(angle)
            if plate: vertical = math.copysign(abs(vertical)**.50,vertical)
            z=h+vertical*depth*taper
            verts.append(world(xy,z))
    count=len(path)
    for i in range(count if closed else count-1):
        for j in range(rings):
            a=i*rings+j; b=i*rings+(j+1)%rings
            c=((i+1)%count)*rings+(j+1)%rings; d=((i+1)%count)*rings+j
            faces.append((a,b,c,d))
    if not closed:
        # Rounded caps survive local remeshing, with no open underside.
        start=len(verts);verts.append(world(path[0],height))
        end=len(verts);verts.append(world(path[-1],height+.0012*math.sin(math.pi*1.6)))
        for j in range(rings):
            faces.append((start,(j+1)%rings,j))
            faces.append((end,(count-1)*rings+j,(count-1)*rings+(j+1)%rings))
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
    ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob)
    return ob

# Similar readable pose to the approved code anatomy, with a modeled cranial vault,
# separate mandible, antorbital opening, cheek strut and individual teeth.
skull_parts=[]
skull_parts.append(tube('cranial_arch',[(316,231),(307,207),(283,194),(256,198),(236,216),(183,227),(188,239),(242,239),(268,248),(297,245)],9.0,.0058,.0535,True))
skull_parts.append(tube('cheek_strut',[(239,217),(248,227),(263,239)],6.2,.0045,.052))
skull_parts.append(tube('mandible',[(192,260),(223,267),(258,271),(289,265),(312,250)],6.4,.0038,.050))
for n,x in enumerate([198,211,224,237]):
    skull_parts.append(tube('tooth_'+str(n),[(x,240),(x+1,244),(x+2,248)],2.0,.0033,.0505,detail=5))

mat=bpy.data.materials.new('Warm_Ivory_Production')
mat.diffuse_color=(.68,.60,.44,1)
mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.74


def finish(parts,name,component,voxel=None):
    bpy.ops.object.select_all(action='DESELECT')
    for ob in parts:ob.select_set(True)
    bpy.context.view_layer.objects.active=parts[0]
    if len(parts)>1:bpy.ops.object.join()
    ob=bpy.context.object;ob.name=name
    if voxel:
        ob.data.remesh_voxel_size=voxel
        bpy.ops.object.voxel_remesh()
        mod=ob.modifiers.new('Gentle anatomical smoothing','SMOOTH');mod.factor=.26;mod.iterations=3
        bpy.ops.object.modifier_apply(modifier=mod.name)
        mod=ob.modifiers.new('Production topology budget','DECIMATE');mod.ratio=.12
        bpy.ops.object.modifier_apply(modifier=mod.name)
    bm=bmesh.new();bm.from_mesh(ob.data)
    bmesh.ops.triangulate(bm,faces=list(bm.faces),quad_method='BEAUTY',ngon_method='BEAUTY')
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    assert all(e.is_manifold for e in bm.edges),(name,'open or nonmanifold mesh')
    bm.to_mesh(ob.data);bm.free()
    for face in ob.data.polygons:face.use_smooth=True
    uv=ob.data.uv_layers.new(name='UVMap')
    for loop in ob.data.loops:
        p=ob.data.vertices[loop.vertex_index].co
        uv.data[loop.index].uv=(p.x/.24,-p.y/.24)
    ob.data.materials.clear();ob.data.materials.append(mat)
    ob['bone_component']=component
    ob['source_method']='original parametric authoring, not Tripo'
    objects.append(ob)
    return ob

finish(skull_parts,'B17_Production_Skull',1,.00065)
old_paths=[]
for i in range(3):
    x=394+i*28
    length=57+math.sin(i/5*math.pi)*33
    lower=[(x,314),(x-10,340),(x-11,340+length*.55),(x+3,340+length),(x+21,351+length)]
    upper=[(x,290),(x-6,265),(x+1,243-length*.25),(x+17,232-length*.25)]
    old_paths.extend([(lower.copy(),4.3),(upper.copy(),4.0)])
    # Keep enough separation from neighboring native vertebrae at the joint.
    lower[0]=(x,316);upper[0]=(x,288)
    for side,path in [('Lower',lower),('Upper',upper)]:
        finish([tube('rib',path,4.0 if side=='Lower' else 3.7,.0032,.0475-i*.0008,detail=12)],f'B17_Rib_{i+1}_{side}',3)

# Bake from the finalized export meshes; no flattening or fitted raster geometry.
roof=np.zeros((640,1024),dtype='<f4')
components=np.zeros((640,1024),dtype='u1')
manifest={'blender':bpy.app.version_string,'source':'original local parametric Blender authoring','parts':[]}
for ob in objects:
    ob.data.calc_loop_triangles()
    verts=np.array([(v.co.x,v.co.z,-v.co.y) for v in ob.data.vertices],dtype=np.float32)
    faces=np.array([tuple(t.vertices) for t in ob.data.loop_triangles],dtype=np.int32)
    bvh=BVHTree.FromPolygons([Vector(v) for v in verts],faces.tolist(),all_triangles=True)
    lo=verts.min(0);hi=verts.max(0)
    x0=max(0,math.floor((lo[0]+.55)/1.1*1024-1));x1=min(1023,math.ceil((hi[0]+.55)/1.1*1024+1))
    y0=max(0,math.floor((lo[2]+.35)/.7*640-1));y1=min(639,math.ceil((hi[2]+.35)/.7*640+1))
    hits=0
    for y in range(y0,y1+1):
        z=(y+.5)/640*.7-.35
        for x in range(x0,x1+1):
            xx=(x+.5)/1024*1.1-.55
            hit,normal,face,distance=bvh.ray_cast(Vector((xx,.2,z)),Vector((0,-1,0)))
            if hit is None:continue
            value=(hit.y-.018)/.102
            assert .08<value<.7,(ob.name,value)
            if value>roof[y,x]:roof[y,x]=value;components[y,x]=ob['bone_component']
            hits+=1
    manifest['parts'].append({'name':ob.name,'component':ob['bone_component'],'triangles':len(faces),'closed':True,'baked_hits':hits,'bounds':[lo.tolist(),hi.tolist()]})
    np.savez(WORK/(ob.name+'.npz'),vertices=verts,faces=faces)
# Select exactly the original three rib pairs for replacement, independent of new outline.
selection=np.zeros((640,1024),dtype='u1')
for points,radius in old_paths:
    for a,b in zip(points,points[1:]):
        x0=max(0,int(min(a[0],b[0])-radius-1));x1=min(1024,int(max(a[0],b[0])+radius+2))
        y0=max(0,int(min(a[1],b[1])-radius-1));y1=min(640,int(max(a[1],b[1])+radius+2))
        yy,xx=np.mgrid[y0:y1,x0:x1];p=np.stack([xx+.5,yy+.5],axis=-1)
        aa=np.array(a);delta=np.array(b)-aa
        t=np.clip(((p-aa)*delta).sum(-1)/(delta*delta).sum(),0,1)
        inside=((p-aa-t[...,None]*delta)**2).sum(-1)<radius*radius
        selection[y0:y1,x0:x1]|=inside.astype('u1')
roof.tofile(WORK/'roof.rf');components.tofile(WORK/'components.bytes');selection.tofile(WORK/'old-rib-selection.bytes')
manifest['triangles']=sum(p['triangles'] for p in manifest['parts'])
manifest['baked_cells']=int((components>0).sum())
assert manifest['triangles']<=40000,manifest['triangles']
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'b17-production-patch.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'b17_production_patch.glb'),export_format='GLB',export_yup=True,export_extras=True,export_animations=False,export_cameras=False,export_lights=False)
manifest['glb_sha256']=hashlib.sha256((OUT/'b17_production_patch.glb').read_bytes()).hexdigest()
(OUT/'production-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('PRODUCTION_PATCH',json.dumps(manifest))
