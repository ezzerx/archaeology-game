"""Two restrained desk accessories + one fixture for the EXISTING task light.
Original authored geometry. Godot metres; Blender Z-up; no gameplay data read.
Run with Blender 5.2.2 --background --factory-startup --python-exit-code 1.
"""
from pathlib import Path
import math, json
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
assert bpy.app.version == (5, 2, 2)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1
bpy.context.preferences.filepaths.save_version = 0

def xyz(p): return Vector((p[0], -p[2], p[1]))
def material(name, color, rough=.6, metal=0):
    m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
    n=m.node_tree.nodes.get('Principled BSDF')
    n.inputs['Base Color'].default_value=(*color,1)
    n.inputs['Roughness'].default_value=rough
    n.inputs['Metallic'].default_value=metal
    return m
brass=material('aged_brass',(.24,.15,.065),.4,.7)
enamel=material('preparation_green_enamel',(.09,.14,.115),.32,.25)
reflector=material('warm_reflector',(.64,.57,.40),.5,.1)
paper=material('field_notebook_paper',(.57,.48,.32),.95)
leather=material('notebook_linen_cover',(.14,.18,.15),.9)
ceramic=material('earthware_brush_pot',(.27,.14,.07),.75)
wood=material('brush_wood',(.20,.095,.035),.65)
bristle=material('brush_bristle',(.43,.30,.14),.95)
ink=material('notebook_ink',(.075,.10,.075),1)
groups={"task_lamp":[],"brush_pot":[],"field_notebook":[]}

def finish(ob,name,mat,group,bevel=0):
    ob.name=name;ob.data.materials.append(mat)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        mod=ob.modifiers.new('Soft manufactured edges','BEVEL');mod.width=bevel;mod.segments=2
        bpy.ops.object.modifier_apply(modifier=mod.name)
    for p in ob.data.polygons:p.use_smooth=True
    groups[group].append(ob)
    return ob

def rod(name,a,b,r,mat,group,r2=None):
    a,b=xyz(a),xyz(b);d=b-a
    bpy.ops.mesh.primitive_cone_add(vertices=20,radius1=r,radius2=r if r2 is None else r2,depth=d.length,location=(a+b)/2)
    ob=bpy.context.object;ob.rotation_quaternion=d.to_track_quat('Z','Y');ob.rotation_mode='QUATERNION'
    # Assign again after choosing quaternion mode (keeps the explicit rotation).
    ob.rotation_quaternion=d.to_track_quat('Z','Y')
    return finish(ob,name,mat,group)

def box(name,p,size,mat,group,angle=0,bevel=.002):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p))
    ob=bpy.context.object;ob.dimensions=(size[0],size[2],size[1]);ob.rotation_euler.z=angle
    return finish(ob,name,mat,group,bevel)

# Slim articulated lamp. Shade opening is at the validated SpotLight origin.
rod('weighted_lamp_base',(-.705,.003,-.28),(-.705,.024,-.28),.077,enamel,'task_lamp')
rod('base_brass_reveal',(-.705,.019,-.28),(-.705,.024,-.28),.078,brass,'task_lamp')
for shift in [-.014,.014]:
    rod('lower_arm',(-.705+shift,.028,-.28),(-.755+shift,.41,-.35),.007,enamel,'task_lamp')
    rod('upper_arm',(-.755+shift,.41,-.35),(-.50+shift,.90,-.37),.006,enamel,'task_lamp')
rod('elbow_pin',(-.78,.41,-.35),(-.725,.41,-.35),.018,brass,'task_lamp')
rod('shade_pivot',(-.52,.90,-.37),(-.48,.90,-.37),.017,brass,'task_lamp')
origin=Vector((-.45,.80,-.30));direction=(Vector((-.06,.04,-.01))-origin).normalized()
opening=origin-direction*.04 # light source just ahead of the mouth; no occlusion
back=opening-direction*.083
# Hollow bell with a warm lining, radius kept small enough for the camera rays.
axis=xyz(direction);u=axis.cross(Vector((1,0,0))).normalized();v=axis.cross(u)
vertices=[];faces=[];matids=[]
for t,r in [(0,.017),(.40,.030),(1,.043),(1,.039),(.40,.026),(0,.013)]:
    c=xyz(back+direction*(t*.083))
    for i in range(40):vertices.append(c+u*(math.cos(i*math.tau/40)*r)+v*(math.sin(i*math.tau/40)*r))
for ring in range(6):
    for i in range(40):
        faces.append((ring*40+i,ring*40+(i+1)%40,((ring+1)%6)*40+(i+1)%40,((ring+1)%6)*40+i))
        matids.append(0 if ring<2 else 1)
mesh=bpy.data.meshes.new('hollow_lamp_shade');mesh.from_pydata(vertices,[],faces);mesh.update()
ob=bpy.data.objects.new('hollow_lamp_shade',mesh);bpy.context.collection.objects.link(ob)
ob.data.materials.append(enamel);ob.data.materials.append(reflector)
for p,idx in zip(mesh.polygons,matids):p.material_index=idx;p.use_smooth=True
groups['task_lamp'].append(ob)

# Accessory 1: open earthenware pot with three static brushes.
cx,cz=-.68,.23
verts=[];faces=[]
for height,r in [(0,.040),(.10,.048),(.10,.041),(.012,.033)]:
    for i in range(28):verts.append(xyz((cx+r*math.cos(i*math.tau/28),height,cz+r*math.sin(i*math.tau/28))))
for ring in range(3):
    for i in range(28):faces.append((ring*28+i,ring*28+(i+1)%28,(ring+1)*28+(i+1)%28,(ring+1)*28+i))
mesh=bpy.data.meshes.new('open_pot');mesh.from_pydata(verts,[],faces);mesh.update()
ob=bpy.data.objects.new('open_brush_pot',mesh);bpy.context.collection.objects.link(ob);ob.data.materials.append(ceramic)
for p in mesh.polygons:p.use_smooth=True
groups['brush_pot'].append(ob)
for i,(dx,dz,height) in enumerate([(-.02,-.015,.24),(.015,.014,.22),(.0,-.025,.27)]):
    end=(cx+dx,height,cz+dz)
    rod('brush_handle', (cx,.025,cz),end,.004,wood,'brush_pot')
    rod('brush_ferrule',end,(end[0],height+.022,end[2]),.006,brass,'brush_pot')
    rod('brush_hair',(end[0],height+.022,end[2]),(end[0],height+.054,end[2]),.006,bristle,'brush_pot',.005)

# Accessory 2: one closed field notebook + a pencil and ruled identification slip.
cx,cz=.683,.19
box('linen_notebook',(cx,.012,cz),(.12,.018,.19),leather,'field_notebook',-.10)
box('paper_edges',(cx,.024,cz),(.112,.011,.182),paper,'field_notebook',-.10,.001)
box('notebook_cover',(cx,.031,cz),(.12,.005,.19),leather,'field_notebook',-.10,.001)
box('specimen_label',(cx,.034,cz-.026),(.077,.001,.055),paper,'field_notebook',-.10,.0002)
for i in range(3):box('label_rule',(cx,.035,cz-.04+i*.012),(.055,.0006,.001),ink,'field_notebook',-.10,.0001)
rod('notebook_pencil',(.727,.041,.15),(.714,.041,.29),.003,wood,'field_notebook')

# One mesh per object family, shared material slots retained (no collision suffix).
for name,objects in groups.items():
    bpy.ops.object.select_all(action='DESELECT')
    for ob in objects:ob.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.object.join();bpy.context.object.name=name
    bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)

source=ROOT/'art/source/p6a2/meshes/preparation_desk.blend'
output=ROOT/'assets/p6a2/static/preparation_desk.glb'
bpy.ops.wm.save_as_mainfile(filepath=str(source))
bpy.ops.export_scene.gltf(filepath=str(output),export_format='GLB',export_yup=True,export_apply=True,
    export_normals=True,export_texcoords=True,export_materials='EXPORT',export_animations=False,
    export_cameras=False,export_lights=False)
counts={}
for ob in bpy.context.scene.objects:
    if ob.type=='MESH':ob.data.calc_loop_triangles();counts[ob.name]=len(ob.data.loop_triangles)
(ROOT/'art/source/p6a2/meshes/desk_manifest.json').write_text(json.dumps({
    'blender':bpy.app.version_string,'units':'metres','triangles':counts,'total_triangles':sum(counts.values()),
    'source':source.relative_to(ROOT).as_posix(),'runtime':output.relative_to(ROOT).as_posix(),
    'light_origin_godot':list(origin),'new_lights':0,'accessories':2,'gameplay_authority':False},indent=2)+'\n')
print('PLAYTEST_DESK_EXPORTED',counts)
