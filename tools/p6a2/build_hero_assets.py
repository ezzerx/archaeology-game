"""P6A2 targeted jacket correction. Static shell only; never reads/writes excavation.
Blender 5.2.2; original construction, fixed seed; no rejected atlas or data plates.
"""
from pathlib import Path
import math, random
import bpy, bmesh

assert bpy.app.version == (5, 2, 2), bpy.app.version_string
ROOT = Path(__file__).resolve().parents[2]
rng = random.Random(627207)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1
bpy.context.preferences.filepaths.save_version = 0

# Deliberately asymmetric outline, not an offset rectangle. Coordinates Godot XZ.
OUTLINE = [(.601,.018),(.624,.151),(.610,.280),(.579,.381),(.428,.406),
 (.264,.386),(.094,.409),(-.095,.380),(-.272,.402),(-.444,.416),
 (-.586,.379),(-.611,.258),(-.586,.108),(-.599,-.078),(-.622,-.245),
 (-.592,-.382),(-.451,-.410),(-.268,-.379),(-.126,-.399),(.059,-.376),
 (.229,-.413),(.442,-.390),(.586,-.376),(.608,-.268),(.582,-.117)]
def cross(a,b): return a[0]*b[1]-a[1]*b[0]
def radii(t):
    d=(math.cos(t),math.sin(t))
    inner=min(.55015/max(abs(d[0]),1e-9),.35015/max(abs(d[1]),1e-9))
    outer=10
    for a,b in zip(OUTLINE,OUTLINE[1:]+OUTLINE[:1]):
        v=(b[0]-a[0],b[1]-a[1]); den=cross(d,v)
        if abs(den)<1e-10: continue
        r=cross(a,v)/den; u=cross(a,d)/den
        if r>0 and 0<=u<=1: outer=min(outer,r)
    assert outer>inner+.014,(t,outer,inner)
    return inner,outer

def vertex(t,r,y):
    x,z=r*math.cos(t),r*math.sin(t)
    # Keep every point outside the footprint. A leaning front wall clears the
    # actual 84-degree camera ray all the way down to Y=.018 (excavation floor).
    # Include the corner shoulder: triangles between the lip and outer ring
    # also need to clear the camera ray, not only the inner-ring vertices.
    if z>.28 and abs(x)<.58:
        z=max(z,.35015+max(y-.017,0)*math.tan(math.radians(6))+.00025)
    return (x,-z,y) # Blender +Z up -> Godot +Y up

def material(name,color):
    m=bpy.data.materials.new(name);m.diffuse_color=(*color,1)
    node=m.node_tree.nodes.get('Principled BSDF')
    node.inputs['Roughness'].default_value=.96
    vc=m.node_tree.nodes.new('ShaderNodeVertexColor');vc.layer_name='Color'
    m.node_tree.links.new(vc.outputs['Color'],node.inputs['Base Color'])
    return m
plaster=material('jacket_plaster_v02',(.48,.46,.40))
contact=material('jacket_dirty_fibre',(.26,.22,.16))
fabric=material('jacket_burlap',(.30,.23,.14))

def mesh_object(name,verts,faces,colors,mat,bevel=0):
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
    bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
    attr=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='POINT')
    for i,col in enumerate(colors): attr.data[i].color=(*col,1)
    uv=mesh.uv_layers.new(name='UVMap')
    for loop in mesh.loops:
        p=mesh.vertices[loop.vertex_index].co
        uv.data[loop.index].uv=((p.x+.75)/1.5,(p.y+.45)/.9)
    ob=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);bpy.context.view_layer.objects.active=ob
    if bevel:
        mod=ob.modifiers.new('Small worn fracture edges','BEVEL');mod.width=bevel;mod.segments=2;mod.angle_limit=.55
        bpy.ops.object.modifier_apply(modifier=mod.name)
    for p in ob.data.polygons:p.use_smooth=True
    return ob

def blend(a,b,k):return tuple(a[i]*(1-k)+b[i]*k for i in range(3))

# Continuous dirty plaster/fibre support, with no clean bright inner line.
angles=sorted(set([math.tau*i/192 for i in range(192)]+[math.atan2(z,x)%math.tau for x in [-.55015,.55015] for z in [-.35015,.35015]]))
N=len(angles);v=[];f=[];cols=[]
for ring in range(6):
    for i in range(N):
        t=angles[i];ri,ro=radii(t)
        lip=.055+.013*math.sin(t*3+.3)+.009*math.sin(t*11)
        rr,yy=[(ri,.003),(ri,lip-.011),(ri+(ro-ri)*.42,lip),
               (ro-.008,lip-.008),(ro+.002,.017),(ro-.009,.002)][ring]
        v.append(vertex(t,rr,yy))
        cols.append(blend((.20,.17,.125),(.34,.295,.22),.35+.25*math.sin(t*5+ring)))
for r in range(6):
    for i in range(N):
        j=(i+1)%N;f.append((r*N+i,r*N+j,((r+1)%6)*N+j,((r+1)%6)*N+i))
mesh_object('jacket_contact',v,f,cols,contact)

# Coherent plaster mass, eroded locally. No radial planks or decorative rim.
notches=[(rng.uniform(0,math.tau),rng.uniform(.025,.09),rng.uniform(.012,.038)) for _ in range(23)]
def erosion(t):
    return max(depth*math.exp(-((math.atan2(math.sin(t-c),math.cos(t-c)))/width)**2) for c,width,depth in notches)
def lip_profile(t):
    erode=erosion(t)
    return .067+.021*math.sin(3*t+.4)+.010*math.sin(7*t)-erode*.70
def worn_through(t):
    # Long asymmetric missing shoulders. The lower dirty fibre body survives;
    # the pale plaster must not form a continuous ring of comparable width.
    return max(depth*math.exp(-(math.atan2(math.sin(t-c),math.cos(t-c))/span)**2)
               for c,span,depth in [(1.25,.20,.88),(3.22,.30,.82),(4.52,.13,.70),(.15,.13,.65)])
angles=sorted(set([math.tau*i/256 for i in range(256)]+[math.atan2(z,x)%math.tau for x in [-.55015,.55015] for z in [-.35015,.35015]]))
N=len(angles);v=[];f=[];cols=[]
for ring in range(6):
    for i in range(N):
        t=angles[i];ri,ro=radii(t)
        ro+=.002*math.sin(37*t)+.0015*math.sin(67*t+.7)
        ro=ri+(ro-ri)*(1-worn_through(t))
        width=ro-ri
        erode=erosion(t)
        retreat=min(width*.72,.001+.008*(.5+.5*math.sin(9*t+1))+.6*erode)
        lip=lip_profile(t)
        irregular=.002*math.sin(47*t)+.0015*math.sin(73*t+.4)
        rr,yy=[(ri,.005),(ri,lip-.008),(ri+retreat,lip+irregular),
               (ro,lip-.006+irregular),(ro+.001,.019),(max(ri+.0005,ro-.008),.004)][ring]
        v.append(vertex(t,rr,yy))
        tone=.50+.13*math.sin(11*t)+.08*math.sin(29*t)
        chalk=blend((.33,.345,.35),(.50,.505,.50),tone)
        dirt=(.68 if ring==1 else .24 if ring==2 else .18 if ring==4 else .30 if ring==5 else .5)
        dirt=min(.85,dirt+erode*6)
        cols.append(blend(chalk,(.26,.22,.17),dirt))
for r in range(6):
    for i in range(N):
        j=(i+1)%N;f.append((r*N+i,r*N+j,((r+1)%6)*N+j,((r+1)%6)*N+i))
plaster_ob=mesh_object('jacket_shell',v,f,cols,plaster)
edge_split=plaster_ob.modifiers.new('Broken plaster crease normals','EDGE_SPLIT')
edge_split.split_angle=.65
bpy.ops.object.modifier_apply(modifier=edge_split.name)

# Local volumetric broken plaster chips, short in both directions; no flakes.
chips=[]
for k in range(38):
    t=rng.uniform(0,math.tau);ri,ro=radii(t)
    rad=ri+(ro-ri)*rng.uniform(.40,.86)
    x,z=rad*math.cos(t),rad*math.sin(t)
    y=lip_profile(t)-.006
    # Avoid projecting over the working footprint at the near wall.
    if abs(x)<.565 and z>0:z=max(z,.3508+(y+.012-.017)*math.tan(math.radians(6)))
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=(x,-z,y))
    chip=bpy.context.object;chip.name='plaster_chip'
    chip.scale=(rng.uniform(.004,.013),rng.uniform(.004,.009),rng.uniform(.003,.009))
    chip.rotation_euler=(rng.uniform(-.3,.3),rng.uniform(-.3,.3),rng.uniform(0,math.tau))
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
    attr=chip.data.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='POINT')
    for c in attr.data:c.color=(.43,.445,.44,1)
    chip.data.materials.append(plaster)
    for face in chip.data.polygons:face.use_smooth=False
    chips.append(chip)
bpy.ops.object.select_all(action='DESELECT');plaster_ob.select_set(True)
for chip in chips:chip.select_set(True)
bpy.context.view_layer.objects.active=plaster_ob;bpy.ops.object.join()

# Two localized folded strips on the OUTSIDE shoulders, not evenly spaced tabs.
v=[];f=[];cols=[]
for center,width in [(2.18,.11),(5.69,.08)]:
    base=len(v);cols_n=7;rows=8
    for row in range(rows):
        u=row/(rows-1)
        for col in range(cols_n):
            t=center+(col/(cols_n-1)-.5)*width;ri,ro=radii(t)
            r=ro-.007+.021*math.sin(u*math.pi)
            y=.006+u*.071+.001*math.sin(col*2.2+row)
            v.append(vertex(t,r,y));cols.append((.29,.23,.145))
    for row in range(rows-1):
        for col in range(cols_n-1):
            a=base+row*cols_n+col;f.append((a,a+1,a+1+cols_n,a+cols_n))
mesh_object('jacket_burlap',v,f,cols,fabric)

source=ROOT/'art/source/p6a2/meshes/b17_jacket.blend'
bpy.ops.wm.save_as_mainfile(filepath=str(source))
output=ROOT/'assets/p6a2/static/b17_jacket.glb'
bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',export_yup=True,
 export_apply=True,export_normals=True,export_texcoords=True,export_materials='EXPORT',
 export_animations=False,export_cameras=False,export_lights=False)
print('P6A2_JACKET_CORRECTION_SAVED',output)
