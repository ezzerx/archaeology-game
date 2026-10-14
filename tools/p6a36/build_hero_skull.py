"""Authored volumetric skull: editable solid cages, subtractive windows and
sinuses, paired jaws, curved teeth and restrained surface sculpt. Blender 5.2.2.
Original stylized design, not a scan or a bitmap extrusion. P6A35 ribs reused.
"""
from pathlib import Path
import math,json,hashlib
import bpy,bmesh
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/p6a36'; WORK=ROOT/'work/p6a36'; SOURCE=ROOT/'art/source/p6a36'
for d in [OUT,WORK,SOURCE]:d.mkdir(parents=True,exist_ok=True)
assert bpy.app.version[:3]==(5,2,2)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
bpy.context.scene.unit_settings.system='METRIC'
authoring=bpy.data.collections.new('EDITABLE_ANATOMICAL_CAGES')
bpy.context.scene.collection.children.link(authoring)
authoring.hide_render=True;authoring.hide_viewport=True
mat=bpy.data.materials.new('Warm_Ivory_Hero_Skull');mat.diffuse_color=(.68,.60,.44,1)
mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.70

def ease(a,b,x):
    t=max(0,min(1,(x-a)/(b-a)));return t*t*(3-2*t)
def world(p,h):return Vector(((p[0]+.5)/1024*1.1-.55,-((p[1]+.5)/640*.7-.35),h))
def smooth(points,steps=4):
    p=[Vector(v) for v in points];out=[]
    for i,b in enumerate(p):
        a=p[(i-1)%len(p)];c=p[(i+1)%len(p)];d=p[(i+2)%len(p)]
        for j in range(steps):
            t=j/steps
            out.append((2*b+(c-a)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)*.5)
    return out

def orient(ob):
    bm=bmesh.new();bm.from_mesh(ob.data)
    bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(ob.data);bm.free()
def mesh_object(name,vertices,faces):
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
    ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob);orient(ob)
    return ob

def archive_cage(ob):
    saved=ob.copy();saved.data=ob.data.copy();saved.name=ob.name+'_EDITABLE_CAGE'
    authoring.objects.link(saved)

def near_height(p,jaw=False):
    x,y=p
    if jaw:return .052+.009*ease(205,310,x)+.0015*math.exp(-((x-268)/24)**2)
    return .057+.014*ease(205,290,x)+.0035*math.exp(-((x-281)/30)**2-((y-194)/30)**2)
def far_height(p,jaw=False):
    return .035+.002*ease(205,300,p[0]) if jaw else .034+.003*ease(205,300,p[0])

def prism(name,points,low,high,save=False):
    p=smooth(points);count=len(p)
    vertices=[world(v,low(v) if callable(low) else low) for v in p]+[world(v,high(v) if callable(high) else high) for v in p]
    faces=[tuple(reversed(range(count))),tuple(range(count,2*count))]
    faces += [(i,(i+1)%count,(i+1)%count+count,i+count) for i in range(count)]
    ob=mesh_object(name,vertices,faces)
    if save:archive_cage(ob)
    return ob

def active(ob):
    bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);bpy.context.view_layer.objects.active=ob

def subtract(ob,cutter):
    print('BOOLEAN',cutter.name,'faces',len(ob.data.polygons),flush=True)
    active(ob)
    modifier=ob.modifiers.new(cutter.name,'BOOLEAN');modifier.operation='DIFFERENCE'
    modifier.solver='EXACT';modifier.object=cutter
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    bpy.data.objects.remove(cutter,do_unlink=True)

def sinus(ob,name,p,radii,height,half_depth):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=48,ring_count=24,location=world(p,height))
    cut=bpy.context.object;cut.name=name
    cut.scale=(radii[0]*1.1/1024,radii[1]*.7/640,half_depth)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    archive_cage(cut);subtract(ob,cut)

outline=[(176,237),(175,227),(181,218),(190,213),(207,207),(229,200),(249,193),(270,184),(287,180),(296,185),(307,187),(318,196),(324,209),(322,230),(314,239),(301,242),(285,244),(269,245),(251,245),(233,247),(215,247),(198,245),(184,242)]
windows={
 'External_nares':[(183,226),(190,219),(203,216),(209,219),(204,224),(191,229)],
 'Antorbital_fenestra':[(217,215),(235,204),(251,199),(254,207),(250,226),(240,236),(222,231),(211,227)],
 'Orbital_fenestra':[(265,198),(275,190),(284,191),(288,201),(285,221),(277,237),(266,232),(259,221)],
 'Temporal_fenestra':[(300,198),(310,204),(315,215),(313,230),(305,234),(296,227),(295,213)]}
cranium=prism('Cranium_Maxilla_Jugal_Plate',outline,far_height,near_height,True)
for name,points in windows.items():subtract(cranium,prism(name,points,.02,.105,True))
# Hollow bilateral construction with a palate and cranial roof, not a solid slab.
sinus(cranium,'Anterior_sinus',(209,223),(34,12),.047,.0065)
sinus(cranium,'Posterior_braincase',(286,212),(29,25),.053,.011)
sinus(cranium,'Palatal_recess',(259,236),(36,8),.051,.008)

jaw_outline=[(182,267),(183,261),(189,260),(209,265),(233,267),(254,264),(276,257),(297,249),(305,244),(314,241),(315,247),(310,255),(301,264),(281,270),(259,278),(233,281),(210,279),(192,275)]
mandible=prism('Dentary_Surangular_Articular',jaw_outline,lambda p:far_height(p,True),lambda p:near_height(p,True),True)
subtract(mandible,prism('Mandibular_fenestra',[(264,267),(273,260),(287,257),(298,255),(294,261),(281,268),(269,272)],.02,.09,True))
sinus(mandible,'Medial_mandibular_recess',(240,272.5),(40,2.5),.044,.005)
# Open the medial space between the two dentaries, retaining near/far bony rails,
# the anterior symphysis and the articulated posterior end.
subtract(mandible,prism('Intermandibular_space',[(198,257),(221,257),(245,255),(276,247),(302,242),(307,252),(296,257),(276,264),(252,271),(230,275),(209,273),(198,270)],lambda p:far_height(p,True)+.003,lambda p:near_height(p,True)-.004,True))
# Modeled rounded margins, before sculpt/remesh, soften the subtractive cages.
for ob in [cranium,mandible]:
    active(ob)
    bevel=ob.modifiers.new('Rounded_bone_margins','BEVEL')
    bevel.width=.0018;bevel.segments=4;bevel.limit_method='ANGLE';bevel.angle_limit=.35
    bevel.use_clamp_overlap=True
    bpy.ops.object.modifier_apply(modifier=bevel.name)
parts=[cranium,mandible]

# Recurved elliptical teeth with variable crowns, collars and paired tooth rows.
def tooth(name,x,y,length,width,height,direction,seed):
    vertices=[];faces=[];rings=11;sides=14
    for i in range(rings):
        u=i/(rings-1)
        radius=width*(1-u)**.72*(1+.14*math.exp(-((u-.10)/.12)**2))+.10
        bend=(1.7+seed*.18)*u*u
        point=(x+bend,y+direction*length*u)
        for j in range(sides):
            a=j/sides*math.tau
            v=world((point[0]+math.cos(a)*radius,point[1]),height+math.sin(a)*radius*.00105*.75-.0006*u)
            vertices.append(v)
    for i in range(rings-1):
        for j in range(sides):
            faces.append((i*sides+j,i*sides+(j+1)%sides,(i+1)*sides+(j+1)%sides,(i+1)*sides+j))
    faces += [tuple(reversed(range(sides))),tuple(range((rings-1)*sides,rings*sides))]
    return mesh_object(name,vertices,faces)

for row in ['Near','Far']:
    for i,x in enumerate([183,191,200,209,218,227,236,245,254,263]):
        y=242.5+3*math.sin((x-180)/100*math.pi)
        length=[9.5,12.4,15,12.8,14.4,12.7,11.4,10.5,8.6,7.2][i]
        h=near_height((x,y))-.0023 if row=='Near' else far_height((x,y))+.003
        parts.append(tooth('Upper_'+row+'_'+str(i),x,y,length,2.0+.4*math.sin(i*1.9),h,1,i))
    for i,x in enumerate([190,199,208,217,226,235,244,253,262,271]):
        y=262.5+4.7*math.sin((x-180)/85*math.pi)
        length=[7.2,8.6,9.5,10,9.3,8.3,8.2,7.7,6.9,5.8][i]
        h=near_height((x,y),True)-.002 if row=='Near' else far_height((x,y),True)+.003
        parts.append(tooth('Lower_'+row+'_'+str(i),x,y,length,1.7+.3*math.sin(i*1.3),h,-1,i))

active(cranium)
for ob in parts:ob.select_set(True)
bpy.ops.object.join();skull=bpy.context.object;skull.name='B17_Production_Skull'
print('REMESH',len(skull.data.polygons),flush=True)
skull.data.remesh_voxel_size=.00052
bpy.ops.object.voxel_remesh()
print('REMESH_DONE',len(skull.data.polygons),flush=True)
modifier=skull.modifiers.new('Worn_bony_edges','SMOOTH');modifier.factor=.22;modifier.iterations=3
bpy.ops.object.modifier_apply(modifier=modifier.name)
# Fine physical surface variation plus shallow vascular pits, without damage-like cracks.
# Bulk access avoids recalculating Blender's lazy normals after each edited vertex.
coords=np.empty(len(skull.data.vertices)*3,dtype=np.float32)
normals=np.empty_like(coords)
skull.data.vertices.foreach_get('co',coords);skull.data.vertices.foreach_get('normal',normals)
coords=coords.reshape(-1,3);normals=normals.reshape(-1,3)
noise=np.sin(coords[:,0]*731+np.sin(coords[:,1]*347))*np.sin(coords[:,1]*613+coords[:,2]*277)
coords+=normals*(noise*.000035)[:,None]
x=(coords[:,0]+.55)/1.1*1024-.5;y=(-coords[:,1]+.35)/.7*640-.5
bulge=(.0020*np.exp(-((x-210)/35)**2-((y-238)/9)**2)
       +.0025*np.exp(-((x-270)/25)**2-((y-190)/8)**2)
       +.0023*np.exp(-((x-298)/14)**2-((y-236)/12)**2))
coords[:,2]+=bulge*np.maximum(normals[:,2],0)**2
mask=(coords[:,2]>.052)&(x>185)&(x<255)&(y>233)&(y<246)
for k,cx in enumerate([188,199,211,223,235,247]):
    cy=237+1.8*math.sin(k*1.2)
    d=((x-cx)/1.4)**2+((y-cy)/1.4)**2
    coords[mask,2]-=(.00075*np.exp(-d*1.9))[mask]
skull.data.vertices.foreach_set('co',coords.ravel())
skull.data.update()
# Exact target on the complete modeled skull; no automatic export LOD.
skull.data.calc_loop_triangles()
modifier=skull.modifiers.new('Hero_runtime_topology','DECIMATE')
print('DECIMATE',len(skull.data.loop_triangles),flush=True)
modifier.ratio=min(1,26800/len(skull.data.loop_triangles))
bpy.ops.object.modifier_apply(modifier=modifier.name)
modifier=skull.modifiers.new('Final_bone_surface_smoothing','SMOOTH');modifier.factor=.15;modifier.iterations=2
bpy.ops.object.modifier_apply(modifier=modifier.name)
bm=bmesh.new();bm.from_mesh(skull.data)
bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0000002)
bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.0000002)
bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
# Remove zero-volume sliver islands, which an exporter would otherwise cull
# differently. Real crowns and plates are many orders of magnitude larger.
remaining=set(bm.faces);tiny=[];removed_islands=0
while remaining:
    seed=remaining.pop();stack=[seed];component=[seed]
    while stack:
        f=stack.pop()
        for e in f.edges:
            for neighbor in e.link_faces:
                if neighbor in remaining:
                    remaining.remove(neighbor);stack.append(neighbor);component.append(neighbor)
    anchor=component[0].verts[0].co
    volume=abs(sum((f.verts[0].co-anchor).dot((f.verts[1].co-anchor).cross(f.verts[2].co-anchor))/6 for f in component))
    if volume<1e-12:tiny.extend(component);removed_islands+=1
if tiny:bmesh.ops.delete(bm,geom=tiny,context='FACES')
print('REMOVED_ZERO_VOLUME_ISLANDS',removed_islands,'faces',len(tiny),flush=True)
assert all(e.is_manifold for e in bm.edges),'Skull must remain closed'
bm.to_mesh(skull.data);bm.free()
for face in skull.data.polygons:face.use_smooth=True
uv=skull.data.uv_layers.new(name='UVMap')
for loop in skull.data.loops:
    p=skull.data.vertices[loop.vertex_index].co;uv.data[loop.index].uv=(p.x/.24,-p.y/.24)
skull.data.materials.clear();skull.data.materials.append(mat)
skull['bone_component']=1;skull['source_method']='original authored anatomical cages, subtractive modeling and surface sculpt'
objects=[skull]
# Preserve the validated P6A35 ribs exactly, including normals, UV and occlusion.
with bpy.data.libraries.load(str(ROOT/'art/source/p6a35/b17-production-patch.blend'),link=False) as (source,target):
    target.objects=[name for name in source.objects if name.startswith('B17_Rib_')]
for ob in target.objects:
    bpy.context.collection.objects.link(ob);objects.append(ob)

print('AO',len(skull.data.vertices),flush=True)
# Short-range geometric occlusion of the new skull, without touching the rib attributes.
verts=[v.co.copy() for v in skull.data.vertices]
skull.data.calc_loop_triangles();faces=[tuple(t.vertices) for t in skull.data.loop_triangles]
bvh=BVHTree.FromPolygons(verts,faces,all_triangles=True)
colors=skull.data.color_attributes.new(name='BoneOcclusion',type='FLOAT_COLOR',domain='POINT');skull.data.color_attributes.active_color=colors
for v in skull.data.vertices:
    n=v.normal.normalized();helper=Vector((0,0,1)) if abs(n.z)<.9 else Vector((1,0,0))
    tangent=n.cross(helper).normalized();bitangent=n.cross(tangent);occlusion=0.0
    for k in range(24):
        z=(k+.5)/24;angle=k*2.399963229728653;radial=math.sqrt(1-z*z)
        ray=tangent*(math.cos(angle)*radial)+bitangent*(math.sin(angle)*radial)+n*z
        hit,_,_,distance=bvh.ray_cast(v.co+n*.00015,ray,.012)
        if hit is not None:occlusion+=(1-distance/.012)*z
    ao=max(.38,1-occlusion/12);colors.data[v.index].color=(ao,ao,ao,1)

print('BAKE',flush=True)
# Finalized GLB triangles author the exact excavation roof and component mask.
roof=np.zeros((640,1024),dtype='<f4');components=np.zeros((640,1024),dtype='u1')
manifest={'blender':bpy.app.version_string,'source':'original volumetric anatomical cage modeling; P6A35 ribs retained','parts':[],'windows':list(windows)+['Mandibular_fenestra'],'editable_cages':len(authoring.objects),'removed_zero_volume_islands':removed_islands}
for ob in objects:
    ob.data.calc_loop_triangles()
    verts=np.array([(v.co.x,v.co.z,-v.co.y) for v in ob.data.vertices],dtype=np.float32)
    faces=np.array([tuple(t.vertices) for t in ob.data.loop_triangles],dtype=np.int32)
    # Analytic double-precision triangle projection avoids ill-conditioned
    # vertical BVH intersections on narrow, nearly vertical bone margins.
    sample_x=(verts[:,0].astype(np.float64)+.55)/1.1*1024
    sample_y=(verts[:,2].astype(np.float64)+.35)/.7*640
    part_present=np.zeros((640,1024),dtype=bool)
    lo=verts.min(0);hi=verts.max(0)
    for face in faces:
        a,b,c=np.stack([sample_x[face],sample_y[face]],axis=1)
        ab=b-a;ac=c-a;det=ab[0]*ac[1]-ab[1]*ac[0]
        if abs(det)<1e-12:continue
        low=np.maximum(0,np.floor(np.minimum(a,np.minimum(b,c))-.5).astype(int))
        high=np.minimum([1023,639],np.ceil(np.maximum(a,np.maximum(b,c))-.5).astype(int))
        if np.any(high<low):continue
        yy,xx=np.mgrid[low[1]:high[1]+1,low[0]:high[0]+1]
        px=xx+.5-a[0];py=yy+.5-a[1]
        u=(px*ac[1]-py*ac[0])/det;v=(ab[0]*py-ab[1]*px)/det
        inside=(u>=-1e-8)&(v>=-1e-8)&(u+v<=1+1e-8)
        z=(verts[face[0],1]+u*(float(verts[face[1],1])-verts[face[0],1])+v*(float(verts[face[2],1])-verts[face[0],1])-.018)/.102
        target=roof[low[1]:high[1]+1,low[0]:high[0]+1]
        winning=inside&(z>target)
        target[winning]=z[winning]
        components[low[1]:high[1]+1,low[0]:high[0]+1][winning]=ob['bone_component']
        part_present[low[1]:high[1]+1,low[0]:high[0]+1]|=inside
    hits=int(part_present.sum())
    manifest['parts'].append({'name':ob.name,'component':ob['bone_component'],'triangles':len(faces),'closed':True,'baked_hits':hits,'bounds':[lo.tolist(),hi.tolist()]})
    np.savez(WORK/(ob.name+'.npz'),vertices=verts,faces=faces)
# Historical replacement mask for exactly the same three rib pairs.
selection=np.zeros((640,1024),dtype='u1')
for i in range(3):
    x=394+i*28;length=57+math.sin(i/5*math.pi)*33
    paths=[([(x,314),(x-10,340),(x-11,340+length*.55),(x+3,340+length),(x+21,351+length)],4.3),([(x,290),(x-6,265),(x+1,243-length*.25),(x+17,232-length*.25)],4.0)]
    for points,radius in paths:
        for a,b in zip(points,points[1:]):
            x0=max(0,int(min(a[0],b[0])-radius-1));x1=min(1024,int(max(a[0],b[0])+radius+2))
            y0=max(0,int(min(a[1],b[1])-radius-1));y1=min(640,int(max(a[1],b[1])+radius+2))
            yy,xx=np.mgrid[y0:y1,x0:x1];p=np.stack([xx+.5,yy+.5],axis=-1);aa=np.array(a);delta=np.array(b)-aa
            t=np.clip(((p-aa)*delta).sum(-1)/(delta*delta).sum(),0,1)
            selection[y0:y1,x0:x1]|=(((p-aa-t[...,None]*delta)**2).sum(-1)<radius*radius).astype('u1')
roof.tofile(WORK/'roof.rf');components.tofile(WORK/'components.bytes');selection.tofile(WORK/'old-rib-selection.bytes')
manifest['triangles']=sum(p['triangles'] for p in manifest['parts']);manifest['baked_cells']=int((components>0).sum())
assert manifest['triangles']<=40000,manifest['triangles']
# Source cages are present only in the editable master, never in runtime export.
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'b17-hero-skull.blend'))
bpy.ops.object.select_all(action='DESELECT')
for ob in objects:ob.select_set(True)
bpy.context.view_layer.objects.active=skull
bpy.ops.export_scene.gltf(filepath=str(OUT/'b17_production_patch.glb'),use_selection=True,export_format='GLB',export_yup=True,export_extras=True,export_animations=False,export_cameras=False,export_lights=False,export_vertex_color='ACTIVE',export_vertex_color_name='BoneOcclusion',export_all_vertex_colors=False)
manifest['glb_sha256']=hashlib.sha256((OUT/'b17_production_patch.glb').read_bytes()).hexdigest()
(OUT/'production-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('HERO_SKULL',json.dumps(manifest))
