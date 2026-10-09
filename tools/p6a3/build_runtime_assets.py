"""Tripo retopo -> metre-scale, UV-preserving static Godot assets.

Run Blender 5.2.2 headlessly with --python-exit-code 1 --python this_file -- <asset>.
Sources are immutable GLBs. No excavation/gameplay resource is read or modified.
Whole rigid meshes preserve UVs and silhouette; Godot uses bounded surface probes
to stand tools upright in cavities. No runtime mesh rebuild or collider.
"""
import bpy
import bmesh
import json
import math
import sys
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[2]
ASSET = sys.argv[sys.argv.index('--')+1]
assert bpy.app.version == (5, 2, 2)
assert ASSET in ('brush', 'chisel', 'pick', 'blower', 'lamp')
SOURCE = ROOT / f'art/source/p6a3/meshes/tripo/{ASSET}_low.glb'
OUT = ROOT / 'assets/p6a3/models'
BLENDS = ROOT / 'art/source/p6a3/meshes/blender'
PREVIEWS = ROOT / 'work/p6a3-art'
for p in (OUT, BLENDS, PREVIEWS): p.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version = 0
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
objects = [o for o in bpy.context.scene.objects if o.type == 'MESH']
assert objects and all(o.data.uv_layers for o in objects)
for o in objects:
    o.data.transform(o.matrix_world)
    o.matrix_world = Matrix.Identity(4)
    o.parent = None
bpy.ops.object.select_all(action='DESELECT')
for o in objects: o.select_set(True)
bpy.context.view_layer.objects.active = objects[0]
bpy.ops.object.join()
ob = bpy.context.object
ob.data.calc_loop_triangles()
source_tris = len(ob.data.loop_triangles)
source_dims = list(ob.dimensions)

if ASSET == 'chisel':
    # Human-found Janus defect: the source hallucinates a second splayed blade.
    # Keep the reference-facing branch and its UVs, remove the mirrored branch,
    # straighten its centreline and seat it inside the unchanged brass ferrule.
    source_mesh = ob.data
    cutoff = .475
    corrected = []
    for handle in (True, False):
        mesh = source_mesh.copy(); bm=bmesh.new(); bm.from_mesh(mesh)
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
        bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),
            plane_co=(0,0,cutoff),plane_no=(0,0,1),dist=.000001,
            clear_inner=handle,clear_outer=not handle)
        if not handle:
            bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),
                plane_co=(0,0,0),plane_no=(0,1,0),dist=.000001,clear_outer=True)
            # Edge intersections, rather than vertex sampling, handle long faces.
            levels=[cutoff*i/100 for i in range(101)]
            centers=[]
            for z in levels:
                ys=[]
                for e in bm.edges:
                    a,b=(v.co for v in e.verts)
                    if min(a.z,b.z)-.000001<=z<=max(a.z,b.z)+.000001:
                        t=(z-a.z)/(b.z-a.z) if abs(b.z-a.z)>.0000001 else 0
                        ys.append(a.y+(b.y-a.y)*t)
                centers.append((min(ys)+max(ys))/2 if ys else (centers[-1] if centers else -.14))
            for v in bm.verts:
                t=max(0,min(100,v.co.z/cutoff*100));i=min(99,int(t));f=t-i
                center_y=centers[i]*(1-f)+centers[i+1]*f
                v.co.y=(v.co.y-center_y)*.52
        boundaries=[e for e in bm.edges if e.is_boundary]
        if boundaries: bmesh.ops.holes_fill(bm,edges=boundaries,sides=0)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(mesh);bm.free();mesh.update()
        part=bpy.data.objects.new('ChiselHandle' if handle else 'SingleCorrectedBlade',mesh)
        bpy.context.collection.objects.link(part);corrected.append(part)
    bpy.data.objects.remove(ob,do_unlink=True)
    bpy.ops.object.select_all(action='DESELECT')
    for o in corrected:o.select_set(True)
    bpy.context.view_layer.objects.active=corrected[0]
    bpy.ops.object.join();ob=bpy.context.object

if ASSET != 'lamp':
    # Source images: Brush/Pick/Blower tips point upward; Chisel points downward.
    if ASSET != 'chisel': ob.data.transform(Matrix.Rotation(math.pi, 4, 'Y'))
    coords = [v.co.copy() for v in ob.data.vertices]
    lo = min(v.z for v in coords); hi = max(v.z for v in coords)
    # Exact source silhouette, pivot centred on the actual terminal tip section.
    section = [v for v in coords if v.z < lo + (hi-lo)*.015]
    center = sum(section, Vector()) / len(section)
    length = {'brush':.108, 'chisel':.104, 'pick':.096, 'blower':.105}[ASSET]
    scale = length/(hi-lo)
    for v in ob.data.vertices:
        v.co = (v.co-Vector((center.x,center.y,lo)))*scale
    # Front of source is Blender -Y. Turn it toward the fixed gameplay camera.
    # Retain actual width; do not taper the source into the old debug proxy.
    ob.name = 'Body'
    parts = [ob]
else:
    # Small shade/base, extended lower arm: match the existing lamp origin
    # without a dinner-plate-sized shade obscuring the playable top-down view.
    # The high/retopo sources stay untouched; UVs on the dark lower arm stretch.
    for v in ob.data.vertices:
        t = max(0, min(1, (v.co.z-.24)/.26))
        v.co = v.co*.30 + Vector((.18,0,.60))*t
    ob.name = 'PreparationLampArt'
    parts = [ob]

for material in ob.data.materials:
    shader=material.node_tree.nodes.get('Principled BSDF')
    if ASSET == 'lamp' and shader:
        shader.inputs['Specular IOR Level'].default_value=.25
        rough=shader.inputs['Roughness']
        if rough.is_linked:
            link=rough.links[0].from_socket
            node=material.node_tree.nodes.new('ShaderNodeMath');node.operation='MAXIMUM'
            node.inputs[1].default_value=.60
            material.node_tree.links.new(link,node.inputs[0]);material.node_tree.links.new(node.outputs[0],rough)

for o in list(bpy.context.scene.objects):
    if o not in parts: bpy.data.objects.remove(o,do_unlink=True)

textures = []
for img in bpy.data.images:
    if img.type != 'IMAGE' or not img.size[0]: continue
    original = list(img.size)
    # One 1K PBR set per small tabletop prop; original 2K set stays in source GLB.
    if max(img.size) > 1024: img.scale(1024,1024)
    img.pack()
    textures.append({'name':img.name,'source_dimensions':original,'runtime_dimensions':list(img.size)})

for o in parts:
    o.data.calc_loop_triangles()
    assert all(math.isfinite(x) for v in o.data.vertices for x in v.co)
    assert o.data.uv_layers
    o.select_set(True)

bpy.ops.wm.save_as_mainfile(filepath=str(BLENDS/f'{ASSET}.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/f'{ASSET}.glb'), export_format='GLB',
    export_yup=True,export_apply=True,export_normals=True,export_texcoords=True,
    export_materials='EXPORT',export_animations=False,export_cameras=False,
    export_lights=False,export_image_format='AUTO')
counts = {o.name:len(o.data.loop_triangles) for o in parts}
stats = {'asset':ASSET,'blender':bpy.app.version_string,'source':str(SOURCE.relative_to(ROOT)),
    'source_triangles':source_tris,'source_dimensions':source_dims,'runtime_triangles':sum(counts.values()),
    'parts':counts,'textures':textures,'units':'metres','axis':'Blender Z up -> Godot Y up',
    'pivot':'actual contact tip' if ASSET!='lamp' else 'source base','colliders':0}
(BLENDS/f'{ASSET}.json').write_text(json.dumps(stats,indent=2)+'\n')
print('P6A3_ASSET',json.dumps(stats))

# Diagnostic camera orbit: actual exported material, four views for hidden sides.
scene=bpy.context.scene
scene.render.engine='CYCLES'; scene.cycles.samples=12
scene.render.resolution_x=640;scene.render.resolution_y=800;scene.render.resolution_percentage=100
scene.world=bpy.data.worlds.new('InspectionWorld');scene.world.use_nodes=True
scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.16,.18,.20,1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value=.65
scene.view_settings.view_transform='AgX'
allv=[o.matrix_world@v.co for o in parts for v in o.data.vertices]
low=Vector(tuple(min(v[i] for v in allv) for i in range(3)))
high=Vector(tuple(max(v[i] for v in allv) for i in range(3)))
center=(low+high)/2; extent=max(high-low)
for i,where in enumerate([(-2,-3,3),(3,-1,2),(-1,3,3)]):
    data=bpy.data.lights.new('Inspect'+str(i),'AREA');data.energy=300*extent*extent;data.shape='DISK';data.size=extent*2
    o=bpy.data.objects.new(data.name,data);scene.collection.objects.link(o);o.location=center+Vector(where)*extent
    o.rotation_euler=(center-o.location).to_track_quat('-Z','Y').to_euler()
camdata=bpy.data.cameras.new('Inspection');camdata.type='ORTHO';camdata.ortho_scale=extent*1.25
cam=bpy.data.objects.new('Inspection',camdata);scene.collection.objects.link(cam);scene.camera=cam
for name,where in [('front',(0,-4,1)),('back',(0,4,1)),('side',(4,0,1)),('top',(0,-.1,4))]:
    cam.location=center+Vector(where)*extent
    cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(PREVIEWS/f'{ASSET}-{name}.png')
    bpy.ops.render.render(write_still=True)
