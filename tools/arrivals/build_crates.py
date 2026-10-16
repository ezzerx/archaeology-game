"""Original workshop crates, editable Blender source; no external assets."""
import bpy, math, random
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
random.seed(2701)
def material(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);return m
wood=[material('wood_%d'%n,(.32+n*.012,.255+n*.010,.17+n*.008)) for n in range(6)]
iron=material('aged_iron',(.12,.13,.11));rust=material('iron_wear',(.23,.18,.11));dark=material('interior',(.08,.06,.035))
def cube(name,loc,size,mat,bevel=.006):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.dimensions=size
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:
  mod=o.modifiers.new('Soft worked edges','BEVEL');mod.width=bevel;mod.segments=2
  bpy.ops.object.modifier_apply(modifier=mod.name)
  mod=o.modifiers.new('Weighted face normals','WEIGHTED_NORMAL');mod.keep_sharp=True
  bpy.ops.object.modifier_apply(modifier=mod.name)
 o.data.materials.append(mat)
 return o
# Blender Z-up, Y-depth; exporter converts to Godot Y-up.
def nail(x,y,z):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=8,ring_count=4,radius=1,location=(x,y,z))
 o=bpy.context.object;o.name='worn_nail';o.scale=(.009,.009,.003);o.data.materials.append(iron)
for code,w,d in [('M08',1.45,1.10),('B17',2.0,1.30)]:
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
 cube('dark_interior',(0,0,.17),(w-.05,d-.05,.30),dark,.005)
 for side in [-1,1]:
  for row in range(3):
   cube('front_board',(0,side*d*.5,.064+row*.113),(w,.042,.108),wood[(row+2)%6])
   cube('end_board',(side*w*.5,0,.064+row*.113),(.046,d,.108),wood[row])
  for x in [-w*.38,w*.38]:
   cube('upright_batten',(x,side*(d*.5+.022),.19),(.10,.042,.38),wood[4])
 # Lid planks with minute offsets and rounded, worn edges; no holes or contents.
 for n in range(6):
  y=(-.5+(n+.5)/6)*d
  cube('lid_board_%02d'%n,(0,y,.368+random.uniform(-.001,.001)),(w+.035,d/6-.005,.036),wood[n])
 for x in [-w*.34,w*.34]:
  cube('lid_batten',(x,0,.405),(.105,d+.05,.035),wood[5],.009)
  for y in [-d*.40,d*.40]:nail(x,y,.425)
 for x in [-w*.5+.065,w*.5-.065]:
  cube('metal_lid_band',(x,0,.390),(.075,d+.09,.012),iron,.004)
  for side in [-1,1]:
   cube('metal_corner',(x,side*(d*.5+.039),.25),(.075,.016,.27),iron,.004)
   for z in [.14,.34]:
    head=cube('corner_rivet',(x,side*(d*.5+.050),z),(.014,.006,.014),rust,.005)
  for y in [-d*.42,d*.42]:nail(x,y,.399)
 # Curved iron handle, projecting just enough to cast a readable contact shadow.
 for side in [-1,1]:
  for x in [-.17,.17]:cube('handle_foot',(x,side*(d*.5+.05),.22),(.05,.022,.075),iron,.01)
  curve=bpy.data.curves.new('handle','CURVE');curve.dimensions='3D';curve.bevel_depth=.012;curve.bevel_resolution=2
  spline=curve.splines.new('BEZIER');spline.bezier_points.add(3)
  for point,co in zip(spline.bezier_points,[(-.17,side*(d*.5+.065),.22),(-.11,side*(d*.5+.105),.17),(.11,side*(d*.5+.105),.17),(.17,side*(d*.5+.065),.22)]):
   point.co=co;point.handle_left_type='AUTO';point.handle_right_type='AUTO'
  obj=bpy.data.objects.new('iron_carry_handle',curve);bpy.context.collection.objects.link(obj);obj.data.materials.append(iron)
 # A narrow lid seal adds a material break without resembling a game rarity badge.
 cube('seal_plate',(0,d*.5+.015,.35),(.11,.022,.13),iron,.008)
 bpy.ops.object.select_all(action='SELECT')
 bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/arrivals'/f'{code.lower()}-crate.blend'))
 bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/arrivals'/f'{code.lower()}_crate.glb'),export_format='GLB',use_selection=True,export_apply=True,export_yup=True)
print('Original crate assets exported')
