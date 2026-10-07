"""P6A2 authored prototype. Fixed composition; no excavation/Bone input.
Run with Blender 5.2.2 --background --factory-startup --python this_file.
"""
from pathlib import Path
import math, random, json, hashlib
import bpy
import numpy as np

assert bpy.app.version == (5, 2, 2), bpy.app.version_string

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art/source/p6a2/meshes'
SOURCE.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1
bpy.context.preferences.filepaths.save_version = 0

def material(name, color):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    node = m.node_tree.nodes.get('Principled BSDF')
    node.inputs['Base Color'].default_value = (*color, 1)
    node.inputs['Roughness'].default_value = .87
    return m

plaster = material('jacket_plaster', (.70, .64, .49))
fabric = material('jacket_canvas', (.26, .19, .105))

# Work in Godot coordinates, convert to Blender (x,-z,y) before saving.
# Every shell vertex is outside |x|<=.55 AND |z|<=.35; front extra clearance
# preserves the fixed 84-degree camera's access even at the excavation floor.
N = 256
vertices, faces = [], []
for ring in range(6):
    for i in range(N):
        t = i * math.tau / N
        c, s = math.cos(t), math.sin(t)
        inner = min(.553 / max(abs(c), 1e-8), (.369 if s > 0 else .357) / max(abs(s), 1e-8))
        width = .027 + .026*(.5+.5*math.sin(5*t+.4)) + .021*(.5+.5*math.sin(9*t+1.1))
        width = min(width, max(.018, .411/max(abs(s),1e-8)-inner))
        ripple = .003*math.sin(31*t)+.0025*math.sin(53*t+.7)
        chip = .020*max(0, math.sin(17*t+.3))**6
        lip = .075 + .009*math.sin(3*t+.8)+.006*math.sin(11*t)-chip
        retreat=.008*(.5+.5*math.sin(19*t))+.003*(.5+.5*math.sin(43*t))
        radius, height = [(inner,.009), (inner+retreat,lip-.016), (inner+.012+retreat,lip),
                          (inner+width,lip-.010+ripple), (inner+width+.003,.028),
                          (inner+width*.70,.009)][ring]
        vertices.append((radius*c, -radius*s, height))
for ring in range(6):
    for i in range(N):
        j = (i+1)%N
        faces.append((ring*N+i, ring*N+j, ((ring+1)%6)*N+j, ((ring+1)%6)*N+i))
mesh = bpy.data.meshes.new('jacket_shell')
mesh.from_pydata(vertices, [], faces)
mesh.update()
obj = bpy.data.objects.new('jacket_shell', mesh)
bpy.context.collection.objects.link(obj)
obj.data.materials.append(plaster)
bpy.context.view_layer.objects.active=obj
obj.select_set(True)
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.uv.smart_project(angle_limit=1.1519, island_margin=.02)
bpy.ops.object.mode_set(mode='OBJECT')
bevel=obj.modifiers.new('Soft broken plaster edges','BEVEL')
bevel.width=.0018; bevel.segments=2
bpy.ops.object.modifier_apply(modifier=bevel.name)
for p in obj.data.polygons: p.use_smooth=True

# Small overlapping plaster flakes break the cast rim into hand-laid sheets.
# All are on the shell's outer half, never over the dynamic work footprint.
rng_shell=random.Random(62722)
flakes=[]
for i in range(72):
    t=i*math.tau/72+rng_shell.uniform(-.018,.018)
    c,s=math.cos(t),math.sin(t)
    inner=min(.553/max(abs(c),1e-8),(.369 if s>0 else .357)/max(abs(s),1e-8))
    width=.027+.026*(.5+.5*math.sin(5*t+.4))+.021*(.5+.5*math.sin(9*t+1.1))
    width=min(width,max(.018,.411/max(abs(s),1e-8)-inner))
    chip=.020*max(0,math.sin(17*t+.3))**6
    lip=.075+.009*math.sin(3*t+.8)+.006*math.sin(11*t)-chip
    radius=inner+width*.60
    outline=[]
    length=rng_shell.uniform(.009,.023); depth=width*.22
    for j in range(6):
        a=j*math.tau/6
        along=math.cos(a)*length*rng_shell.uniform(.75,1.1)
        across=math.sin(a)*depth*rng_shell.uniform(.75,1.0)
        outline.append(((radius+across)*c-along*s,-((radius+across)*s+along*c)))
    thick=rng_shell.uniform(.001,.003)
    vv=[(x,y,lip-.004+k*thick) for k in [0,1] for x,y in outline]
    ff=[tuple(range(5,-1,-1)),tuple(range(6,12))]+[(j,(j+1)%6,(j+1)%6+6,j+6) for j in range(6)]
    mm=bpy.data.meshes.new('plaster_flake');mm.from_pydata(vv,[],ff);mm.update()
    flake=bpy.data.objects.new('plaster_flake',mm);bpy.context.collection.objects.link(flake)
    mm.materials.append(plaster);flakes.append(flake)
bpy.ops.object.select_all(action='DESELECT')
obj.select_set(True)
for flake in flakes: flake.select_set(True)
bpy.context.view_layer.objects.active=obj
bpy.ops.object.join()

# Small external canvas reinforcement tabs; never bridge the digging area.
for x in [-.34,.29]:
    for z, side in [(-.389,-1),(.398,1)]:
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x,-z,.028))
        tab=bpy.context.object; tab.name='canvas_tab'
        tab.dimensions=(.049,.050,.010)
        bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
        tab.data.materials.append(fabric)
        mod=tab.modifiers.new('Rounded folded cloth','BEVEL'); mod.width=.003; mod.segments=3
        bpy.ops.object.modifier_apply(modifier=mod.name)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'b17_jacket.blend'))
runtime=ROOT/'assets/p6a2/static';runtime.mkdir(parents=True,exist_ok=True)
bpy.ops.export_scene.gltf(filepath=str(runtime/'b17_jacket.glb'),export_format='GLB',export_yup=True,
    export_apply=True,export_normals=True,export_texcoords=True,export_materials='EXPORT',
    export_animations=False,export_cameras=False,export_lights=False)

# Non-repeating data plates, authored for the full 1.1 x .7 m dynamic core.
# R broad brush values, G tiny surface height, B roughness variation, A inclusions.
# No concept-image pixels, baked lights, albedo, fossil masks, or geometry input.
W,H=1024,640
yy,xx=np.mgrid[0:H,0:W].astype(np.float32)
def field(rng, nx, ny):
    grid=rng.random((ny+1,nx+1)).astype(np.float32)
    x=xx/W*nx; y=yy/H*ny
    ix=x.astype(int);iy=y.astype(int);fx=x-ix;fy=y-iy
    fx=fx*fx*(3-2*fx);fy=fy*fy*(3-2*fy)
    return (grid[iy,ix]*(1-fx)+grid[iy,ix+1]*fx)*(1-fy)+(grid[iy+1,ix]*(1-fx)+grid[iy+1,ix+1]*fx)*fy
manifest=[]
for index,name in enumerate(['soil','clay','sandstone','bone']):
    rng=np.random.default_rng(62720+index)
    broad=field(rng,11,7); medium=field(rng,85,53); fine=field(rng,460,288)
    value=.52+.40*(broad-.5)+.30*(medium-.5)
    detail=.5+.38*(fine-.5)
    inclusion=np.zeros((H,W),dtype=np.float32)
    # Deliberately different mark families: clustered granules / dragged dabs /
    # angular mineral flecks / sparse elongated ivory mottles.
    for n in range([1100,230,780,100][index]):
        cx,cy=rng.uniform(0,W),rng.uniform(0,H)
        rx,ry=([rng.uniform(1,4),rng.uniform(1,3)] if index==0 else
               [rng.uniform(4,19),rng.uniform(1,5)] if index==1 else
               [rng.uniform(1,7),rng.uniform(1,5)] if index==2 else
               [rng.uniform(3,12),rng.uniform(2,7)])
        x0=max(0,int(cx-rx*2));x1=min(W,int(cx+rx*2+1))
        y0=max(0,int(cy-ry*2));y1=min(H,int(cy+ry*2+1))
        dx=(xx[y0:y1,x0:x1]-cx)/rx;dy=(yy[y0:y1,x0:x1]-cy)/ry
        d=np.abs(dx+.3*dy)+np.abs(dy) if index==2 else dx*dx+dy*dy
        mark=np.clip(1-d,0,1)
        value[y0:y1,x0:x1]+=mark*rng.uniform(-.30,.14)
        detail[y0:y1,x0:x1]+=mark*rng.uniform(-.14,.10)
        inclusion[y0:y1,x0:x1]=np.maximum(inclusion[y0:y1,x0:x1],mark)
    rough=.5+.4*(medium-.5)+.15*(fine-.5)
    data=np.stack((value,detail,rough,.5+.5*inclusion),axis=-1)
    data=np.clip(data,0,1).astype(np.float32)
    path=ROOT/f'assets/p6a2/textures/{name}/p6a2_{name}_surface_data.png'
    path.parent.mkdir(parents=True,exist_ok=True)
    img=bpy.data.images.new(name,W,H,alpha=True)
    img.colorspace_settings.name='Non-Color'
    img.pixels.foreach_set(data.ravel())
    img.file_format='PNG';img.filepath_raw=str(path);img.save()
    bpy.data.images.remove(img)
    manifest.append({'file':str(path.relative_to(ROOT)).replace('\\','/'),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
(SOURCE/'asset_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('P6A2_ASSETS_SAVED',manifest)
