"""B-17: original postcranial solid modeling; approved P6A36 skull unchanged.
Blender metres/Z-up. No scan, remote generation or render-only raster geometry.
"""
from pathlib import Path
import math,json,hashlib,ast,struct
import bpy,bmesh
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/p6a37';WORK=ROOT/'work/p6a37';SOURCE=ROOT/'art/source/p6a37'
for d in [OUT,WORK,SOURCE]:d.mkdir(parents=True,exist_ok=True)
assert bpy.app.version[:3]==(5,2,2)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0
bpy.context.scene.unit_settings.system='METRIC'
authoring=bpy.data.collections.new('EDITABLE_POSTCRANIAL_CAGES')
bpy.context.scene.collection.children.link(authoring)
authoring.hide_render=True;authoring.hide_viewport=True
mat=bpy.data.materials.new('Warm_Ivory_B17');mat.diffuse_color=(.68,.60,.44,1)
mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.70
# Reuse pure modeling helpers, without executing the skull generator or changing it.
tree=ast.parse((ROOT/'tools/p6a36/build_hero_skull.py').read_text(encoding='utf-8-sig'))
helpers={'ease','world','smooth','orient','mesh_object','archive_cage','prism','active','subtract','sinus'}
exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in helpers],type_ignores=[]),'<approved modeling helpers>','exec'))
objects=[]
with bpy.data.libraries.load(str(ROOT/'art/source/p6a36/b17-hero-skull.blend'),link=False) as (src,dst):
    dst.objects=[n for n in src.objects if n=='B17_Production_Skull']
skull=dst.objects[0];bpy.context.collection.objects.link(skull);objects.append(skull)
def geometry_hash(ob):
    ob.data.calc_loop_triangles()
    p=np.array([tuple(v.co) for v in ob.data.vertices],dtype='<f4')
    t=np.array([tuple(f.vertices) for f in ob.data.loop_triangles],dtype='<i4')
    c=np.array([tuple(v.color) for v in ob.data.color_attributes['BoneOcclusion'].data],dtype='<f4')
    return hashlib.sha256(p.tobytes()+t.tobytes()+c.tobytes()).hexdigest()
skull_hash=geometry_hash(skull)

# Open Catmull-Rom shafts with deliberately authored cross-sections, crests and
# a tapered costal blade. Profiles are elliptical rather than round pipework.
def shaft(name,stations,steps=4,sides=18,groove=0):
    # station = map x,y, centre height metres, lateral radius px, depth radius metres
    samples=[]
    for i in range(len(stations)-1):
        a=np.array(stations[max(0,i-1)],float);b=np.array(stations[i],float)
        c=np.array(stations[i+1],float);d=np.array(stations[min(len(stations)-1,i+2)],float)
        for j in range(steps):
            t=j/steps
            samples.append((2*b+(c-a)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)*.5)
    samples.append(np.array(stations[-1],float));vertices=[];faces=[]
    for i,s in enumerate(samples):
        tangent=Vector((samples[min(i+1,len(samples)-1)][0]-samples[max(0,i-1)][0],samples[min(i+1,len(samples)-1)][1]-samples[max(0,i-1)][1])).normalized()
        side=Vector((-tangent.y,tangent.x))
        u=i/(len(samples)-1)
        for j in range(sides):
            angle=j/sides*math.tau
            # One continuous shallow costal groove and a gentle outer ridge.
            dent=groove*math.exp(-((math.atan2(math.sin(angle-.6),math.cos(angle-.6)))/.3)**2)*math.sin(math.pi*u)**2
            lateral=math.cos(angle)*max(.18,s[3])*(1-dent)
            h=s[2]+math.sin(angle)*max(.00025,s[4])*(1-dent)
            vertices.append(world((s[0]+side.x*lateral,s[1]+side.y*lateral),h))
    for i in range(len(samples)-1):
        for j in range(sides):faces.append((i*sides+j,i*sides+(j+1)%sides,(i+1)*sides+(j+1)%sides,(i+1)*sides+j))
    faces += [tuple(reversed(range(sides))),tuple(range((len(samples)-1)*sides,len(samples)*sides))]
    return mesh_object(name,vertices,faces)

def ellipsoid(name,p,radii,h):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=12,location=world(p,h))
    ob=bpy.context.object;ob.name=name;ob.scale=(radii[0]*1.1/1024,radii[1]*.7/640,radii[2])
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return ob

def finalize(parts,name,component,budget,voxel=.00052):
    ob=parts[0];active(ob)
    for part in parts:part.select_set(True)
    bpy.ops.object.join();ob=bpy.context.object;ob.name=name
    archive_cage(ob)
    ob.data.remesh_voxel_size=voxel
    bpy.ops.object.voxel_remesh()
    m=ob.modifiers.new('Soft_fossil_margins','SMOOTH');m.factor=.26;m.iterations=3
    bpy.ops.object.modifier_apply(modifier=m.name)
    # Restrained surface sculpt, never procedural cracks or uniform damage.
    coords=np.empty(len(ob.data.vertices)*3,dtype=np.float32);normals=np.empty_like(coords)
    ob.data.vertices.foreach_get('co',coords);ob.data.vertices.foreach_get('normal',normals)
    coords=coords.reshape(-1,3);normals=normals.reshape(-1,3)
    noise=np.sin(coords[:,0]*631+np.sin(coords[:,1]*317))*np.sin(coords[:,1]*503+coords[:,2]*277)
    coords+=normals*(noise*.000025)[:,None]
    ob.data.vertices.foreach_set('co',coords.ravel());ob.data.update();ob.data.calc_loop_triangles()
    m=ob.modifiers.new('Runtime_topology','DECIMATE');m.ratio=min(1,budget/len(ob.data.loop_triangles))
    bpy.ops.object.modifier_apply(modifier=m.name)
    bm=bmesh.new();bm.from_mesh(ob.data)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0000002)
    bmesh.ops.dissolve_degenerate(bm,edges=list(bm.edges),dist=.0000002)
    bmesh.ops.triangulate(bm,faces=list(bm.faces));bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    assert all(e.is_manifold for e in bm.edges),name+' must remain closed'
    bm.to_mesh(ob.data);bm.free()
    for face in ob.data.polygons:face.use_smooth=True
    uv=ob.data.uv_layers.new(name='UVMap')
    for loop in ob.data.loops:
        p=ob.data.vertices[loop.vertex_index].co;uv.data[loop.index].uv=(p.x/.24,-p.y/.24)
    ob.data.materials.clear();ob.data.materials.append(mat)
    ob['bone_component']=component;ob['source_method']='original solid anatomical postcranial modeling'
    objects.append(ob)
    print('MODELED',name,len(ob.data.polygons),flush=True)
    return ob

# Twelve individual ribs. A broad flattened shaft, a bifid proximal articulation
# (capitulum/tubercle), changing curvature and a pointed distal blade.
for i in range(6):
    x=394+i*28;length=57+math.sin(i/5*math.pi)*33
    for upper in [True,False]:
        tag='Upper' if upper else 'Lower'
        if upper:
            stations=[(x,289,.049,4.5,.0048),(x-6,272,.0475,3.9,.0035),(x-5,253,.047,3.2,.0029),(x+1,243-length*.25,.0455,3.3,.0025),(x+12,232-length*.25,.043,2.6,.002),(x+19,230-length*.25,.0415,.55,.0007)]
            joint=(x+4,291)
        else:
            stations=[(x,315,.050,4.7,.0051),(x-8,335,.0475,4.2,.0039),(x-11,340+length*.40,.045,3.6,.003),(x-5,340+length*.76,.043,3.6,.0026),(x+7,342+length,.0415,2.7,.0023),(x+24,351+length,.0395,.55,.0007)]
            joint=(x+5,312)
        parts=[shaft('Costal_blade',stations,5,22,.18),ellipsoid('Costal_head',stations[0][:2],(5.3,5.3,.0054),stations[0][2])]
        first=stations[0]
        parts += [shaft('Costal_neck',[(first[0],first[1],first[2],2.8,.0027),(joint[0],joint[1],.052,2.4,.0025)],4),ellipsoid('Costal_tubercle',joint,(3.5,3.2,.0038),.052)]
        finalize(parts,f'B17_Rib_{i+1:02}_{tag}',3,1500)

# Twenty individually modeled vertebrae along the existing B-17 articulation.
# Spool centra, paired neural laminae enclosing a real opening, facet pads and
# tapered transverse/spinous processes. Tail changes proportion continuously.
spine=[(329,251),(349,266),(371,282),(396,293),(423,300),(451,305),(480,307),(510,307),(540,309),(570,311),(600,311),(629,307),(657,298),(682,286),(706,271),(730,255),(754,241),(777,232),(799,228),(819,229)]
for i,(x,y) in enumerate(spine):
    taper=1 if i<11 else 1-.60*(i-10)/9
    h=.053-.004*max(0,(i-10)/9)
    # Centre endplates are broad, the middle waist narrower.
    parts=[shaft('Centrum_spool',[(x-8*taper,y,h,5.6*taper,.0047*taper),(x-5*taper,y,h+.0003,6.8*taper,.0057*taper),(x,y,h,4.8*taper,.0049*taper),(x+5*taper,y,h,6.6*taper,.0056*taper),(x+8*taper,y,h,5.3*taper,.0044*taper)],3,22)]
    # An open arch drawn in the exposed plane, keeping the canal readable.
    arch=[(x-5*taper,y-2*taper,h+.003,2.1*taper,.0029*taper),(x-6*taper,y-7*taper,h+.005,2*taper,.003*taper),(x,y-10*taper,h+.006,2.4*taper,.0031*taper),(x+6*taper,y-7*taper,h+.005,2*taper,.003*taper),(x+5*taper,y-2*taper,h+.003,2.1*taper,.0029*taper)]
    parts.append(shaft('Neural_arch',arch,3,16))
    process_length=(15 if i<11 else 10)*taper
    for sign in [-1,1]:
        parts.append(shaft('Transverse_process',[(x+1,y+sign*3*taper,h+.002,3.1*taper,.003*taper),(x-1,y+sign*9*taper,h+.004,2.6*taper,.0028*taper),(x+2,y+sign*process_length,h+.0015,1.7*taper,.002*taper)],3,16))
    parts.append(ellipsoid('Zygapophysis',(x-4*taper,y-5*taper),(3.4*taper,2.7*taper,.0025*taper),h+.006))
    parts.append(ellipsoid('Zygapophysis',(x+5*taper,y-5*taper),(3.0*taper,2.5*taper,.0023*taper),h+.006))
    parts.append(shaft('Spinous_crest',[(x,y-8*taper,h+.006,2.8*taper,.0028*taper),(x+1,y-13*taper,h+.009,2.8*taper,.003*taper),(x+3,y-17*taper,h+.005,1.6*taper,.0018*taper)],3,16))
    ob=finalize(parts,f'B17_Vertebra_{i+1:02}',2,1100 if i<12 else 800,.00048 if taper<.7 else .00055)
    # Orient each vertebral body along its actual articulated spine tangent.
    before=spine[max(0,i-1)];after=spine[min(len(spine)-1,i+1)]
    angle=-math.atan2(after[1]-before[1],after[0]-before[0])
    centre=world((x,y),0);ca=math.cos(angle);sa=math.sin(angle)
    for target in [ob,authoring.objects.get(ob.name+'_EDITABLE_CAGE')]:
        if target is None:continue
        for vertex in target.data.vertices:
            dx=vertex.co.x-centre.x;dy=vertex.co.y-centre.y
            vertex.co.x=centre.x+ca*dx-sa*dy;vertex.co.y=centre.y+sa*dx+ca*dy
        target.data.update()

# Pelvic blade with a true acetabular opening, crested rim and open pelvic forks.
ilium=prism('Ilium_blade',[(560,335),(563,328),(577,323),(596,324),(616,329),(624,335),(620,342),(606,345),(590,343),(576,342)],.041,.054,True)
subtract(ilium,prism('Acetabulum',[(589,334),(592,330),(598,330),(602,334),(600,339),(594,340),(590,338)],.02,.09,True))
parts=[ilium,shaft('Iliac_crest',[(565,330,.053,2.3,.0028),(581,326,.056,2.8,.0034),(600,328,.057,2.8,.0035),(619,334,.053,2,.0025)],4),shaft('Pubis',[(589,340,.046,4.2,.0045),(579,355,.043,3.4,.0035),(578,370,.041,2.5,.003),(583,378,.041,3.8,.0032)],4),shaft('Ischium',[(603,341,.046,4.0,.0042),(615,354,.043,3.0,.003),(623,365,.041,2.2,.0026)],4)]
finalize(parts,'B17_Pelvis_Ilium_Pubis_Ischium',4,3900,.00048)

# Femur: offset head, curved shaft, trochanter and separated distal condyles.
parts=[shaft('Femoral_shaft',[(605,354,.050,7,.006),(612,367,.049,5.6,.0052),(628,383,.048,5.2,.005),(645,400,.046,6.4,.0056),(657,411,.046,8,.0056)],5,24),ellipsoid('Femoral_head',(601,351),(8,8,.0064),.052),ellipsoid('Greater_trochanter',(613,355),(5,7,.0054),.052),shaft('Fourth_trochanter',[(618,371,.052,2.4,.0025),(624,380,.054,2.6,.003),(631,388,.049,1.6,.002)],4),ellipsoid('Distal_condyle_medial',(653,415),(5.4,6,.0057),.048),ellipsoid('Distal_condyle_lateral',(663,408),(5.1,5.5,.0053),.048)]
finalize(parts,'B17_Femur',4,3400)
# Tibia and fibula remain separate, with a slender gap between them.
parts=[shaft('Tibia_shaft',[(659,429,.048,6.7,.0056),(647,440,.047,5.3,.0047),(626,462,.045,4.1,.0042),(605,483,.043,4.8,.0044),(596,493,.043,5.8,.0047)],5,24),ellipsoid('Tibial_plateau',(660,427),(7.8,6.5,.0054),.049),shaft('Cnemial_crest',[(654,431,.053,3.2,.003),(645,444,.053,3,.003),(639,452,.047,1.6,.0018)],4),ellipsoid('Distal_malleolus',(593,494),(5.9,5.3,.0048),.043)]
finalize(parts,'B17_Tibia',4,2700)
parts=[shaft('Fibula_shaft',[(674,428,.047,3.2,.003),(670,440,.044,2.5,.0025),(651,461,.042,1.8,.002),(630,482,.041,1.8,.002),(615,494,.040,2.6,.0023)],5,18),ellipsoid('Fibular_head',(674,428),(3.6,4.8,.0032),.048)]
finalize(parts,'B17_Fibula',4,1600,.00042)
# Three toes with distinct phalanges, joint gaps and recurved ungual tips.
toe_paths=[[(596,508),(615,513),(635,515),(652,513),(670,509),(679,503)],[(604,516),(623,520),(641,525),(657,531),(674,532)],[(609,522),(626,530),(642,543),(657,549)]]
for digit,points in enumerate(toe_paths):
    for j,(a,b) in enumerate(zip(points,points[1:])):
        aa=np.array(a,float);bb=np.array(b,float);direction=(bb-aa)/np.linalg.norm(bb-aa)
        aa+=direction*1.0;bb-=direction*1.0
        r=max(1.8,4.0-digit*.5-j*.45);h=.043-.001*j
        claw=j==len(points)-2
        if claw:
            stations=[(*aa,h,r,.003),(float((aa[0]+bb[0])*.5),float((aa[1]+bb[1])*.5-2),h+.002,r*.7,.0025),(*bb,h-.001,.35,.0005)]
        else:
            mid=(aa+bb)*.5
            stations=[(*aa,h,r,.003),(*mid,h-.0005,r*.72,.0026),(*bb,h,r*.93,.0029)]
        toe_parts=[shaft('Ungual' if claw else 'Phalanx',stations,4,18)]
        if not claw:
            # Rounded articular ends and a narrower waist, separated by real gaps.
            toe_parts += [ellipsoid('Proximal_articulation',aa,(r*.85,r*.85,.003),h),ellipsoid('Distal_articulation',bb,(r*.80,r*.80,.0029),h)]
        finalize(toe_parts,f'B17_Toe_{digit+1}_'+('Claw' if claw else f'Phalanx_{j+1}'),4,620,.0004)

# Geometric short-range AO for newly modeled bones. The skull attributes remain exact.
for ob in objects[1:]:
    print('AO',ob.name,flush=True)
    ob.data.calc_loop_triangles();verts=[v.co.copy() for v in ob.data.vertices]
    faces=[tuple(t.vertices) for t in ob.data.loop_triangles];bvh=BVHTree.FromPolygons(verts,faces,all_triangles=True)
    colors=ob.data.color_attributes.new(name='BoneOcclusion',type='FLOAT_COLOR',domain='POINT');ob.data.color_attributes.active_color=colors
    for v in ob.data.vertices:
        n=v.normal.normalized();helper=Vector((0,0,1)) if abs(n.z)<.9 else Vector((1,0,0))
        tangent=n.cross(helper).normalized();bitangent=n.cross(tangent);occ=0.0
        for k in range(16):
            z=(k+.5)/16;angle=k*2.399963229728653;r=math.sqrt(1-z*z)
            ray=tangent*(math.cos(angle)*r)+bitangent*(math.sin(angle)*r)+n*z
            hit,_,_,dist=bvh.ray_cast(v.co+n*.00015,ray,.010)
            if hit is not None:occ+=(1-dist/.010)*z
        ao=max(.38,1-occ/8);colors.data[v.index].color=(ao,ao,ao,1)
assert geometry_hash(skull)==skull_hash,'Approved skull geometry/AO must stay exact'

roof=np.zeros((640,1024),dtype='<f4');components=np.zeros((640,1024),dtype='u1')
manifest={'blender':bpy.app.version_string,'source':'original postcranial solid modeling; approved P6A36 skull unchanged','parts':[],'approved_skull_geometry_ao_sha256':skull_hash,'editable_cages':len(authoring.objects)}
for ob in objects:
    print('BAKE',ob.name,flush=True)
    ob.data.calc_loop_triangles()
    verts=np.array([(v.co.x,v.co.z,-v.co.y) for v in ob.data.vertices],dtype=np.float32)
    faces=np.array([tuple(t.vertices) for t in ob.data.loop_triangles],dtype=np.int32)
    sx=(verts[:,0].astype(np.float64)+.55)/1.1*1024;sy=(verts[:,2].astype(np.float64)+.35)/.7*640
    present=np.zeros((640,1024),dtype=bool)
    for face in faces:
        a,b,c=np.stack([sx[face],sy[face]],axis=1);ab=b-a;ac=c-a;det=ab[0]*ac[1]-ab[1]*ac[0]
        if abs(det)<1e-12:continue
        low=np.maximum(0,np.floor(np.minimum(a,np.minimum(b,c))-.5).astype(int));high=np.minimum([1023,639],np.ceil(np.maximum(a,np.maximum(b,c))-.5).astype(int))
        if np.any(high<low):continue
        yy,xx=np.mgrid[low[1]:high[1]+1,low[0]:high[0]+1];px=xx+.5-a[0];py=yy+.5-a[1]
        u=(px*ac[1]-py*ac[0])/det;v=(ab[0]*py-ab[1]*px)/det
        inside=(u>=-1e-8)&(v>=-1e-8)&(u+v<=1+1e-8)
        z=(verts[face[0],1]+u*(float(verts[face[1],1])-verts[face[0],1])+v*(float(verts[face[2],1])-verts[face[0],1])-.018)/.102
        target=roof[low[1]:high[1]+1,low[0]:high[0]+1];winning=inside&(z>target)
        target[winning]=z[winning];components[low[1]:high[1]+1,low[0]:high[0]+1][winning]=ob['bone_component']
        present[low[1]:high[1]+1,low[0]:high[0]+1]|=inside
    manifest['parts'].append({'name':ob.name,'component':ob['bone_component'],'triangles':len(faces),'closed':True,'baked_hits':int(present.sum()),'bounds':[verts.min(0).tolist(),verts.max(0).tolist()]})
    np.savez(WORK/(ob.name+'.npz'),vertices=verts,faces=faces)
roof.tofile(WORK/'roof.rf');components.tofile(WORK/'components.bytes')
np.ones((640,1024),dtype='u1').tofile(WORK/'old-rib-selection.bytes')
manifest['triangles']=sum(p['triangles'] for p in manifest['parts']);manifest['baked_cells']=int((components>0).sum());manifest['component_cells']={str(i):int((components==i).sum()) for i in range(1,5)}
assert manifest['triangles']<=100000,manifest['triangles']
assert float(roof.max())<.7
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'b17-modeled-skeleton.blend'))
bpy.ops.object.select_all(action='DESELECT')
for ob in objects:ob.select_set(True)
bpy.context.view_layer.objects.active=skull
bpy.ops.export_scene.gltf(filepath=str(OUT/'b17_skeleton.glb'),use_selection=True,export_format='GLB',export_yup=True,export_extras=True,export_animations=False,export_cameras=False,export_lights=False,export_vertex_color='ACTIVE',export_vertex_color_name='BoneOcclusion',export_all_vertex_colors=False)
glb=(OUT/'b17_skeleton.glb').read_bytes()
length=struct.unpack_from('<I',glb,12)[0];document=json.loads(glb[20:20+length])
by_name={p['name']:p for p in manifest['parts']}
manifest['source_triangles']=manifest['triangles'];exported=0
for node in document['nodes']:
    if 'mesh' not in node:continue
    count=sum(document['accessors'][p['indices']]['count']//3 for p in document['meshes'][node['mesh']]['primitives'])
    part=by_name[node['name']];part['source_triangles']=part['triangles'];part['triangles']=count;exported+=count
manifest['triangles']=exported
manifest['export_culled_degenerate_triangles']=manifest['source_triangles']-exported
manifest['glb_sha256']=hashlib.sha256(glb).hexdigest()
(OUT/'production-manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('MODELED_SKELETON',json.dumps(manifest),flush=True)
